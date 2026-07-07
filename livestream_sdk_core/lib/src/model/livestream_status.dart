/// Card status shown by a livestream feed item (spec §05).
///
/// Derived from the enriching [StreamSchedule]'s `preset` / `price` /
/// `exclusive` fields and its funding target-progress. Mirrors the app's
/// `LivestreamCardStatus` derivation (`LivestreamModelX.cardStatus`) so the
/// SDK and the in-app home feed classify a stream identically.
enum LivestreamStatus {
  /// Public preview stream — free to watch.
  free,

  /// Exclusive (subscriber-only) stream.
  exclusive,

  /// A private / show stream that is actively performing.
  performing,

  /// A funding show still collecting tickets (`progress < target`).
  funding,

  /// No live session (no schedule, or an unrecognized preset).
  offline,
}
