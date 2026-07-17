import 'package:dio/dio.dart';

import '../model/livestream.dart';
import '../model/stream_schedule.dart';
import '../repository/livestream_feed_repository.dart';
import 'livestream_feed_path_normalizer.dart';
import 'mapper/livestream_info_response_mapper.dart';
import 'mapper/session_response_mapper.dart';
import 'model/livestream_info_response.dart';
import 'model/session_response.dart';

/// Plain-Dio [LivestreamFeedRepository] for consumers without packages/core
/// (feed_util). Endpoint paths, query parameters and 404-as-empty semantics
/// mirror packages/data's `LivestreamPageRepository` — the difference is the
/// base host, which here comes from the domain-tracker-resolved [apiBase]
/// rather than RemoteConfig.
///
/// Live enrichment uses the merged `GET /sessions?include=livestream_detail`
/// endpoint (BE API GENP-3379): a single request per batch of streamers
/// returns each active session's live detail, replacing the old per-streamer
/// `/pusher/retained-events` fan-out.
final class DioLivestreamFeedRepository implements LivestreamFeedRepository {
  DioLivestreamFeedRepository({
    required Uri apiBase,
    required Dio httpClient,
    void Function(String message)? onWarning,
    void Function(String stage, Uri uri, Response<dynamic> response)?
    onResponse,
  }) : _apiBase = apiBase,
       _http = httpClient,
       _onWarning = onWarning,
       _onResponse = onResponse;

  final Uri _apiBase;
  final Dio _http;

  /// Optional sink for swallowed, non-fatal errors (the schedule batch fetch
  /// is best-effort — see [_fetchScheduleBatch]). No-op when null, keeping
  /// this package free of any logger dependency; feed_util bridges it to its
  /// SDK-wide log.
  final void Function(String message)? _onWarning;

  /// Optional debugging hook receiving the raw dio [Response] of the
  /// feed-list fetch ([onResponseStageFeedList]) and each `/sessions`
  /// enrichment batch ([onResponseStageSchedules]). `uri` is the full request
  /// URL as built here (more reliable than `response.requestOptions`); the
  /// response carries status, headers and the decoded body exactly as the
  /// backend sent it — invoked *before* mapping, so entries the mappers
  /// silently skip are still visible.
  ///
  /// Passed structured (not pre-formatted) so the sink decides per stage what
  /// is worth stringifying (e.g. feed_util condenses the `/sessions` body to
  /// its id list). No-op when null; like [_onWarning], this keeps the package
  /// free of any logger dependency.
  final void Function(String stage, Uri uri, Response<dynamic> response)?
  _onResponse;

  /// Stage names handed to the `onResponse` hook, public so sinks can branch
  /// on them without duplicating string literals.
  static const onResponseStageFeedList = 'getLivestreamList';
  static const onResponseStageSchedules = 'fetchStreamSchedules';

  /// `/sessions` accepts 1–100 `user_id` values per request (BE API GENP-3379).
  static const _sessionBatchSize = 100;

  // Query-parameter keys (mirror packages/core `Parameter`).
  static const _paramLimit = 'limit';
  static const _paramPage = 'page';
  static const _paramSorting = 'sorting';
  static const _paramUserId = 'user_id';
  static const _paramInclude = 'include';

  /// `include` value that appends the live-detail fields to `/sessions`.
  static const _includeLivestreamDetail = 'livestream_detail';

  @override
  Future<String?> resolveFeedPath(
    String configPath, {
    CancelToken? cancelToken,
  }) async {
    final source = Uri.parse(configPath);
    final uri = _buildUri(
      normalizeLivestreamFeedPath(source.path),
      _multiValueQuery(source.queryParametersAll),
    );
    final response = await _http.fetch<void>(
      RequestOptions(
        path: uri.toString(),
        method: 'GET',
        cancelToken: cancelToken,
        followRedirects: false,
        // Accept 3xx so the redirect Location can be read from the headers.
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );
    final location = response.headers.value('location');
    return (location == null || location.isEmpty) ? null : location;
  }

  @override
  Future<List<Livestream>> getLivestreamList({
    required String feedPath,
    String? sorting,
    int page = 1,
    int limit = LivestreamFeedPaging.defaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final source = Uri.parse(feedPath);
    // Preserve any query already on the feed path, but drop the keys we
    // override so the backend doesn't see duplicates.
    final query = _multiValueQuery(source.queryParametersAll)
      ..remove(_paramSorting)
      ..remove(_paramLimit)
      ..remove(_paramPage)
      ..[_paramLimit] = [limit.toString()]
      ..[_paramPage] = [page.toString()]
      ..[_paramSorting] = [sorting ?? LivestreamFeedPaging.defaultSorting];

    final uri = _buildUri(normalizeLivestreamFeedPath(source.path), query);
    try {
      final response = await _http.fetch<dynamic>(
        RequestOptions(
          path: uri.toString(),
          method: 'GET',
          cancelToken: cancelToken,
        ),
      );
      // Emitted before shape validation/mapping so a malformed body (or an
      // entry the lenient mapping below drops) is still observable.
      _onResponse?.call(onResponseStageFeedList, uri, response);
      final data = response.data;
      if (data is! List) {
        throw const FormatException(
          'getLivestreamList response is not a JSON array',
        );
      }
      final result = <Livestream>[];
      for (final element in data.whereType<Map<String, dynamic>>()) {
        try {
          result.add(LivestreamInfoResponse.fromJson(element).toLivestream());
        } catch (_) {
          // Skip malformed entries rather than failing the whole page.
        }
      }
      return result;
    } on DioException catch (e) {
      // Bypass 404 as empty results, matching web behavior.
      if (e.response?.statusCode == 404) return const [];
      rethrow;
    }
  }

  @override
  Future<Map<String, StreamSchedule>> fetchStreamSchedules(
    List<String> streamerIds, {
    CancelToken? cancelToken,
  }) async {
    if (streamerIds.isEmpty) return const {};
    final batches = <List<String>>[
      for (int i = 0; i < streamerIds.length; i += _sessionBatchSize)
        streamerIds.sublist(
          i,
          (i + _sessionBatchSize).clamp(0, streamerIds.length),
        ),
    ];
    final results = await Future.wait(
      batches.map((batch) => _fetchScheduleBatch(batch, cancelToken)),
    );
    return {for (final batch in results) ...batch};
  }

  /// Fetches one batch of live details via
  /// `GET /sessions?user_id=…&include=livestream_detail`.
  ///
  /// `/sessions` returns only active sessions, so a requested streamer that is
  /// absent from the response is offline and simply omitted from the map.
  /// `limit` is set to the batch size so every requested streamer fits on a
  /// single page (`/sessions` paginates its own response).
  Future<Map<String, StreamSchedule>> _fetchScheduleBatch(
    List<String> streamerIds,
    CancelToken? cancelToken,
  ) async {
    try {
      final uri = _buildUri('sessions', {
        _paramUserId: streamerIds,
        _paramInclude: [_includeLivestreamDetail],
        _paramLimit: [streamerIds.length.toString()],
      });
      final response = await _http.fetch<dynamic>(
        RequestOptions(
          path: uri.toString(),
          method: 'GET',
          cancelToken: cancelToken,
        ),
      );
      // Same pre-mapping raw dump as the feed-list fetch: sessions this
      // method skips (missing streamer) or drops (non-List body) stay visible.
      _onResponse?.call(onResponseStageSchedules, uri, response);
      final data = response.data;
      if (data is! List) return const {};
      final result = <String, StreamSchedule>{};
      for (final element in data.whereType<Map<String, dynamic>>()) {
        final session = SessionResponse.fromJson(element);
        final streamer = session.streamer;
        if (streamer == null || streamer.isEmpty) continue;
        result[streamer] = session.toStreamSchedule();
      }
      return result;
    } on DioException catch (e) {
      // Treat a 404 as "no active sessions" rather than an error.
      if (e.response?.statusCode == 404) return const {};
      // Cancellation is expected control-flow; don't surface it as a warning.
      if (e.type == DioExceptionType.cancel) return const {};
      // Best-effort: the batch is dropped (its streamers stay unenriched and
      // classify as offline) — surface the cause so this isn't silent.
      _onWarning?.call(
        'fetchStreamSchedules: batch of ${streamerIds.length} failed — $e',
      );
      return const {};
    } catch (e) {
      _onWarning?.call(
        'fetchStreamSchedules: batch of ${streamerIds.length} failed — $e',
      );
      return const {};
    }
  }

  /// Builds a URL from [_apiBase], appending [path] to any base path.
  ///
  /// Every value is normalized to a `List<String>` and passed via
  /// `queryParameters`, which emits one `key=value` pair per list element —
  /// so multi-value keys (e.g. repeated `user_id` on `/sessions`) stay as
  /// repeated query params instead of a single stringified list. Null values
  /// and keys with no values are dropped.
  Uri _buildUri(String path, Map<String, List<String>> query) {
    final cleaned = <String, List<String>>{};
    query.forEach((key, values) {
      if (values.isNotEmpty) cleaned[key] = values;
    });
    final basePath = _apiBase.path.replaceAll(RegExp(r'/+$'), '');
    return _apiBase.replace(
      path: basePath.isEmpty ? '/$path' : '$basePath/$path',
      queryParameters: cleaned.isEmpty ? null : cleaned,
    );
  }

  /// Copies `queryParametersAll` into a mutable `key -> List<String>` map so
  /// callers can override individual keys before building the URL.
  static Map<String, List<String>> _multiValueQuery(
    Map<String, List<String>> all,
  ) {
    return {
      for (final entry in all.entries) entry.key: [...entry.value],
    };
  }
}
