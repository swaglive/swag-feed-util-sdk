/// Known stream preset names (the backend's `preset` field).
///
/// A tiny local constant rather than importing packages/model's
/// `StreamPresets` enum — this package is pure Dart and app-independent.
abstract final class StreamPreset {
  static const sd = 'sd';
  static const preview = 'preview';
}

/// The live state of a streamer, parsed from the `stream.online` retained
/// event (plus accumulated `session.rating.updated`, `stream.viewers.updated`
/// and `goal.*` events).
///
/// Pure-Dart counterpart of packages/model's `StreamSchedule`, carrying only
/// the fields the feed needs to render and classify a card. A `null`
/// [StreamSchedule] for a streamer means "offline".
class StreamSchedule {
  const StreamSchedule({
    this.sessionId,
    this.preset,
    this.price,
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

  /// The live session id (maps from the event's `session` field).
  final String? sessionId;

  /// `sd` (private) or `preview` (public) — see [StreamPreset].
  final String? preset;

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
