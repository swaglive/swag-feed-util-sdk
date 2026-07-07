import 'package:dio/dio.dart';

import '../model/livestream.dart';
import '../repository/livestream_feed_repository.dart';

/// Thrown when the entrypoint/config feed path cannot be resolved to a real
/// feed path (the backend redirect returned no usable `Location`).
class FeedPathResolutionException implements Exception {
  const FeedPathResolutionException([this.configPath]);

  final String? configPath;

  @override
  String toString() =>
      'FeedPathResolutionException(failed to resolve feed path'
      '${configPath == null ? '' : ' for $configPath'})';
}

/// Resolves a config feed path and fetches one page of the livestream feed.
///
/// Pure-Dart counterpart of packages/data's `GetLivestreamListUseCase`:
/// step 1 follows the backend redirect to the real feed path, step 2 fetches
/// the page at that path. The returned entries are NOT yet enriched with live
/// schedules — pass them through [EnrichLivestreamTitlesUseCase] for that.
class GetLivestreamListUseCase {
  const GetLivestreamListUseCase(this._repository);

  final LivestreamFeedRepository _repository;

  Future<List<Livestream>> call({
    required String configPath,
    String? sorting,
    int page = 1,
    int limit = LivestreamFeedPaging.defaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final realPath = await _repository.resolveFeedPath(
      configPath,
      cancelToken: cancelToken,
    );
    if (realPath == null || realPath.isEmpty) {
      throw FeedPathResolutionException(configPath);
    }
    return _repository.getLivestreamList(
      feedPath: realPath,
      sorting: sorting,
      page: page,
      limit: limit,
      cancelToken: cancelToken,
    );
  }
}
