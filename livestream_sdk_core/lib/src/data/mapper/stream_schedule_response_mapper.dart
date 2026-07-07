import '../../model/stream_schedule.dart';
import '../model/stream_schedule_response.dart';

/// Maps a `stream.online` DTO to the pure [StreamSchedule] domain model.
///
/// Rating / viewers / funding values that arrive on sibling retained events
/// (`session.rating.updated`, `stream.viewers.updated`, `goal.*`) are layered
/// on by the repository via [StreamSchedule.copyWith]; this mapper only reads
/// what the `stream.online` payload itself carries.
extension StreamScheduleResponseMapper on StreamScheduleResponse {
  StreamSchedule toStreamSchedule() {
    return StreamSchedule(
      sessionId: sessionId,
      preset: preset,
      price: price,
      snapshot: snapshot,
      exclusive: exclusive,
      title: title,
      categories: categories,
      devices: devices,
      currentRating: currentRating,
      currentRatingCount: currentRatingCount,
    );
  }
}
