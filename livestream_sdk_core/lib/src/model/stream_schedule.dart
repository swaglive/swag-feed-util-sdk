import 'livestream_mode.dart';

/// Known stream preset names (the backend's `preset` field).
///
/// A tiny local constant rather than importing packages/model's
/// `StreamPresets` enum — this package is pure Dart and app-independent.
abstract final class StreamPreset {
  static const sd = 'sd';
  static const preview = 'preview';
}

/// The live state of a streamer.
///
/// Populated from a `GET /sessions?include=livestream_detail` element (BE API
/// GENP-3379). Pure-Dart counterpart of packages/model's `StreamSchedule`,
/// carrying only the fields the feed needs to render and classify a card. A
/// `null` [StreamSchedule] for a streamer means "offline" (the streamer's
/// user_id was not returned by `/sessions`).
class StreamSchedule {
  const StreamSchedule({
    this.sessionId,
    this.preset,
    this.price,
    this.mode,
    this.snapshot,
    this.exclusive,
    this.title,
    this.categories,
    this.devices,
    this.currentRating,
    this.currentRatingCount,
    this.viewers,
    this.fundingTarget,
    this.fundingProgress,
  });

  /// The live session id (maps from the `/sessions` element's `id` field).
  final String? sessionId;

  /// `sd` (private) or `preview` (public) — see [StreamPreset].
  final String? preset;

  /// Authoritative session mode from the backend (`/sessions` `mode` field).
  /// Preferred over the legacy `preset` / `price` derivation for classifying
  /// the card status; `null` only when the backend omits it.
  final LivestreamMode? mode;

  /// Ticket price for the current preset; `null` on a show stream.
  final int? price;

  /// Encrypted snapshot path (cover). Kept internal to the SDK.
  final String? snapshot;

  /// Whether the stream is exclusive (subscriber-only).
  final bool? exclusive;

  /// Current show title (from the goal's first level, when present).
  final String? title;

  final List<String>? categories;

  /// Connected toy device ids, if any.
  final List<String>? devices;

  /// Raw session rating (0–100 scale from the backend).
  final double? currentRating;

  final int? currentRatingCount;

  /// Live viewer count accumulated from `stream.viewers.updated`.
  final int? viewers;

  /// Funding-show goal target (ticket count).
  final int? fundingTarget;

  /// Funding-show goal progress (tickets collected so far).
  final int? fundingProgress;

  /// A "show" stream: `sd` preset with no per-view price.
  bool get isShow => preset == StreamPreset.sd && price == null;

  /// A funding show still collecting tickets.
  bool get isFundingShow {
    final target = fundingTarget;
    final progress = fundingProgress;
    return target != null && progress != null && progress < target;
  }

  StreamSchedule copyWith({
    String? sessionId,
    String? preset,
    int? price,
    LivestreamMode? mode,
    String? snapshot,
    bool? exclusive,
    String? title,
    List<String>? categories,
    List<String>? devices,
    double? currentRating,
    int? currentRatingCount,
    int? viewers,
    int? fundingTarget,
    int? fundingProgress,
  }) {
    return StreamSchedule(
      sessionId: sessionId ?? this.sessionId,
      preset: preset ?? this.preset,
      price: price ?? this.price,
      mode: mode ?? this.mode,
      snapshot: snapshot ?? this.snapshot,
      exclusive: exclusive ?? this.exclusive,
      title: title ?? this.title,
      categories: categories ?? this.categories,
      devices: devices ?? this.devices,
      currentRating: currentRating ?? this.currentRating,
      currentRatingCount: currentRatingCount ?? this.currentRatingCount,
      viewers: viewers ?? this.viewers,
      fundingTarget: fundingTarget ?? this.fundingTarget,
      fundingProgress: fundingProgress ?? this.fundingProgress,
    );
  }
}
