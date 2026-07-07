import 'package:dio/dio.dart';

import '../model/livestream.dart';
import '../model/stream_schedule.dart';

/// Product defaults for the livestream feed (business policy, not transport).
abstract final class LivestreamFeedPaging {
  /// Feed page size. Matches the app's `LivestreamFeedRequest` default.
  static const int defaultPageSize = 20;

  /// Default sort order (`desc:s_score`) applied when the caller passes none.
  static const String defaultSorting = 'desc:s_score';
}

/// Data source for the livestream feed and its live enrichment.
///
/// Two implementations exist:
///  * `DioLivestreamFeedRepository` — plain Dio against a tracker-resolved
///    api base, used by the feed_util SDK (no get_it / packages/core).
///  * an `HttpRequestable`-backed adapter in packages/data — used by the
///    in-app home feed through the app's HTTP stack.
abstract interface class LivestreamFeedRepository {
  /// Resolves an entrypoint/config feed path to the real feed path by
  /// following the backend redirect (returns its `Location` header value).
  ///
  /// Returns `null` when the redirect cannot be resolved.
  Future<String?> resolveFeedPath(
    String configPath, {
    CancelToken? cancelToken,
  });

  /// Fetches one page of the feed at [feedPath] (base [Livestream] entries,
  /// not yet enriched with live schedules).
  ///
  /// A `404` is treated as an empty page (matching web behavior).
  Future<List<Livestream>> getLivestreamList({
    required String feedPath,
    String? sorting,
    int page = 1,
    int limit = LivestreamFeedPaging.defaultPageSize,
    CancelToken? cancelToken,
  });

  /// Batch-fetches the live [StreamSchedule] for each of [streamerIds]
  /// (chunked to the backend's per-request channel limit). Missing/offline
  /// streamers are simply absent from the returned map.
  Future<Map<String, StreamSchedule>> fetchStreamSchedules(
    List<String> streamerIds, {
    CancelToken? cancelToken,
  });
}
