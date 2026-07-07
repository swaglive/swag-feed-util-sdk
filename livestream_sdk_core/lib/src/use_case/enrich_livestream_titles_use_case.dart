import 'package:dio/dio.dart';

import '../model/livestream.dart';
import '../repository/livestream_feed_repository.dart';

/// Enriches a page of [Livestream]s with their live schedules.
///
/// Batch-fetches every streamer's `stream.online` state and attaches it, so
/// each entry gains its live title, snapshot, session id, viewers, rating,
/// funding progress and derived [Livestream.status]. Pure-Dart counterpart of
/// packages/data's `EnrichLivestreamTitlesUseCase`.
///
/// Best-effort: if enrichment fails the original (unenriched) list is
/// returned so the feed still renders.
class EnrichLivestreamTitlesUseCase {
  const EnrichLivestreamTitlesUseCase(this._repository);

  final LivestreamFeedRepository _repository;

  Future<List<Livestream>> call(
    List<Livestream> livestreams, {
    CancelToken? cancelToken,
  }) async {
    if (livestreams.isEmpty) return livestreams;
    try {
      final schedules = await _repository.fetchStreamSchedules(
        livestreams.map((e) => e.id).toList(),
        cancelToken: cancelToken,
      );
      return [
        for (final livestream in livestreams)
          livestream.withSchedule(schedules[livestream.id]),
      ];
    } catch (_) {
      return livestreams;
    }
  }
}
