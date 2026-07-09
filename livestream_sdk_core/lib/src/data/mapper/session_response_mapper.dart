import '../../model/livestream_mode.dart';
import '../../model/stream_schedule.dart';
import '../model/session_response.dart';

/// Maps a `/sessions?include=livestream_detail` element (BE API GENP-3379) to
/// the pure [StreamSchedule] domain model.
///
/// Unlike the old retained-events flow — which folded several pusher events
/// together — the merged endpoint already returns each card's live state in a
/// single object, so this is a straight field copy. Two shapes are collapsed
/// to the model's flat form:
///  * `pricing: { preview, sd }` → the [StreamSchedule.price] for the active
///    [SessionResponse.preset] (kept for the legacy status fallback).
///  * `metadata.viewer_count: { preview, sd }` → a single summed viewer count.
extension SessionResponseMapper on SessionResponse {
  StreamSchedule toStreamSchedule() {
    return StreamSchedule(
      sessionId: id,
      preset: preset,
      price: _priceForPreset,
      // Only parse when the backend actually sent `mode`. Passing a null wire
      // value through `fromWire` would yield `LivestreamMode.unknown` (→
      // `offline`), making a missing `mode` authoritative and defeating the
      // legacy `preset`/`price`/`exclusive` fallback in `Livestream.status`
      // (a present-but-unrecognized value still maps to `unknown`).
      mode: mode == null ? null : LivestreamMode.fromWire(mode),
      snapshot: snapshot,
      exclusive: exclusive,
      title: title,
      categories: categories,
      devices: devices,
      currentRating: currentRating,
      currentRatingCount: currentRatingCount,
      viewers: _totalViewers,
      fundingTarget: fundingTarget,
      fundingProgress: fundingProgress,
    );
  }

  /// The price of the currently-active preset (`pricing[preset]`), or `null`
  /// when pricing / the preset key is absent.
  int? get _priceForPreset {
    final p = pricing;
    if (p == null) return null;
    final key = preset;
    return key == null ? null : p[key];
  }

  /// Sum of the per-preset `viewer_count`, or `null` when absent so the model
  /// falls back to the feed's static metadata viewers.
  int? get _totalViewers {
    final counts = viewerCount;
    if (counts == null || counts.isEmpty) return null;
    var total = 0;
    for (final value in counts.values) {
      total += value ?? 0;
    }
    return total;
  }
}
