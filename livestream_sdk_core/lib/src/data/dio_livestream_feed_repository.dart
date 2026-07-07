import 'package:dio/dio.dart';

import '../model/livestream.dart';
import '../model/stream_schedule.dart';
import '../repository/livestream_feed_repository.dart';
import 'livestream_feed_path_normalizer.dart';
import 'mapper/livestream_info_response_mapper.dart';
import 'mapper/stream_schedule_response_mapper.dart';
import 'model/livestream_info_response.dart';
import 'model/stream_schedule_response.dart';

/// Plain-Dio [LivestreamFeedRepository] for consumers without packages/core
/// (feed_util). Endpoint paths, query parameters and 404-as-empty semantics
/// mirror packages/data's `LivestreamPageRepository` /
/// `RetainedEventsRepository` — the difference is the base host, which here
/// comes from the domain-tracker-resolved [apiBase] rather than RemoteConfig.
final class DioLivestreamFeedRepository implements LivestreamFeedRepository {
  DioLivestreamFeedRepository({required Uri apiBase, required Dio httpClient})
    : _apiBase = apiBase,
      _http = httpClient;

  final Uri _apiBase;
  final Dio _http;

  /// Retained-events channel prefix for a user (mirrors the app's
  /// `ServerPushRepository.privateUserChannel`).
  static const _privateUserChannel = 'private-enc-user@';

  /// Server accepts at most 10 channels per retained-events request.
  static const _channelBatchSize = 10;

  // Query-parameter keys (mirror packages/core `Parameter`).
  static const _paramLimit = 'limit';
  static const _paramPage = 'page';
  static const _paramSorting = 'sorting';
  static const _paramChannels = 'channels';

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
      for (int i = 0; i < streamerIds.length; i += _channelBatchSize)
        streamerIds.sublist(
          i,
          (i + _channelBatchSize).clamp(0, streamerIds.length),
        ),
    ];
    final results = await Future.wait(
      batches.map((batch) => _fetchScheduleBatch(batch, cancelToken)),
    );
    return {for (final batch in results) ...batch};
  }

  Future<Map<String, StreamSchedule>> _fetchScheduleBatch(
    List<String> streamerIds,
    CancelToken? cancelToken,
  ) async {
    final channels = [for (final id in streamerIds) '$_privateUserChannel$id'];
    try {
      final response = await _http.fetch<dynamic>(
        RequestOptions(
          path: _buildUri('pusher/retained-events', {
            _paramChannels: channels,
          }).toString(),
          method: 'GET',
          cancelToken: cancelToken,
        ),
      );
      final data = response.data;
      if (data is! Map) return const {};
      final result = <String, StreamSchedule>{};
      for (int i = 0; i < streamerIds.length; i++) {
        final events = data[channels[i]];
        final schedule = _parseStreamOnline(events is List ? events : null);
        if (schedule != null) result[streamerIds[i]] = schedule;
      }
      return result;
    } catch (_) {
      return const {};
    }
  }

  /// Reduces a channel's retained-event list into a [StreamSchedule].
  ///
  /// Finds the `stream.online` event and layers on rating, summed viewers and
  /// goal (title / funding target / progress) accumulated across events.
  /// Returns `null` when there is no `stream.online` (streamer offline).
  /// Mirrors `RetainedEventsRepository._parseStreamOnline`.
  StreamSchedule? _parseStreamOnline(List<dynamic>? events) {
    if (events == null || events.isEmpty) return null;

    StreamScheduleResponse? online;
    double? currentRating;
    int? currentRatingCount;
    int? viewersSum;
    String? showTitle;
    int? fundingTarget;
    int? fundingProgress;

    for (final event in events) {
      if (event is! Map) continue;
      final name = event['event'];
      final payload = event['data'];
      if (payload is! Map<String, dynamic>) continue;

      // if/else-if (rather than switch) to mirror the app's
      // RetainedEventsRepository._parseStreamOnline and keep the `goal.*`
      // group as a single OR-branch.
      if (name == _Event.streamOnline) {
        online = StreamScheduleResponse.fromJson(payload);
      } else if (name == _Event.sessionRatingUpdated) {
        currentRating = (payload['current_rating'] as num?)?.toDouble();
        currentRatingCount = (payload['current_rating_count'] as num?)?.toInt();
      } else if (name == _Event.streamViewersUpdated) {
        final v = (payload['viewers'] as num?)?.toInt() ?? 0;
        viewersSum = (viewersSum ?? 0) + v;
      } else if (name == _Event.goalAdded ||
          name == _Event.goalUpdated ||
          name == _Event.goalStarted ||
          name == _Event.goalProgressUpdated ||
          name == _Event.goalMetadataUpdated) {
        final goal = GoalEventResponse.fromJson(payload);
        final level = goal.levels?.isNotEmpty == true
            ? goal.levels!.first
            : null;
        // Accumulate individually: lightweight events (e.g.
        // goal.progress.updated) omit `levels`, so a wholesale overwrite
        // would drop the title / target captured earlier.
        if (level?.title != null) showTitle = level!.title;
        if (level?.target != null) fundingTarget = level!.target;
        if (goal.progress != null) fundingProgress = goal.progress;
      }
    }

    if (online == null) return null;
    final base = online.toStreamSchedule();
    return base.copyWith(
      title: (showTitle != null && showTitle.isNotEmpty)
          ? showTitle
          : base.title,
      currentRating: currentRating,
      currentRatingCount: currentRatingCount,
      viewers: viewersSum,
      fundingTarget: fundingTarget,
      fundingProgress: fundingProgress,
    );
  }

  /// Builds a URL from [_apiBase], appending [path] to any base path.
  ///
  /// Every value is normalized to a `List<String>` and passed via
  /// `queryParameters`, which emits one `key=value` pair per list element —
  /// so multi-value keys (e.g. `channels` on retained-events) stay as repeated
  /// query params instead of a single stringified list. Null values and keys
  /// with no values are dropped.
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

/// Retained-event names consumed by [_parseStreamOnline] (mirror the app's
/// `PusherEventNames`).
abstract final class _Event {
  static const streamOnline = 'stream.online';
  static const sessionRatingUpdated = 'session.rating.updated';
  static const streamViewersUpdated = 'stream.viewers.updated';
  static const goalAdded = 'goal.added';
  static const goalUpdated = 'goal.updated';
  static const goalStarted = 'goal.started';
  static const goalProgressUpdated = 'goal.progress.updated';
  static const goalMetadataUpdated = 'goal.metadata.updated';
}
