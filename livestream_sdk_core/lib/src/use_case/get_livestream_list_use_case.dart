import 'package:dio/dio.dart';

import '../model/livestream.dart';
import '../repository/livestream_feed_repository.dart';

/// Fetches one page of the livestream feed at the config feed path.
///
/// Pure-Dart counterpart of packages/data's `GetLivestreamListUseCase`. The
/// backend's 302 to the current real feed is followed per fetch, never
/// captured (see [LivestreamFeedRepository.getLivestreamList]). The returned
/// entries are NOT yet enriched with live schedules — pass them through
/// [EnrichLivestreamTitlesUseCase] for that.
class GetLivestreamListUseCase {
  const GetLivestreamListUseCase(this._repository);

  final LivestreamFeedRepository _repository;

  Future<List<Livestream>> call({
    required String configPath,
    String? sorting,
    int page = 1,
    int limit = LivestreamFeedPaging.defaultPageSize,
    CancelToken? cancelToken,
  }) {
    return _repository.getLivestreamList(
      feedPath: configPath,
      sorting: sorting,
      page: page,
      limit: limit,
      cancelToken: cancelToken,
    );
  }
}
