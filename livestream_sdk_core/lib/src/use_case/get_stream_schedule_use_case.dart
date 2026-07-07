import 'package:dio/dio.dart';

import '../model/stream_schedule.dart';
import '../repository/livestream_feed_repository.dart';

/// Fetches the live [StreamSchedule] for a single streamer.
///
/// Pure-Dart counterpart of packages/data's `GetStreamScheduleUseCase`.
/// Returns `null` when the streamer is offline (no `stream.online` event).
class GetStreamScheduleUseCase {
  const GetStreamScheduleUseCase(this._repository);

  final LivestreamFeedRepository _repository;

  Future<StreamSchedule?> call(
    String streamerId, {
    CancelToken? cancelToken,
  }) async {
    final schedules = await _repository.fetchStreamSchedules([
      streamerId,
    ], cancelToken: cancelToken);
    return schedules[streamerId];
  }
}
