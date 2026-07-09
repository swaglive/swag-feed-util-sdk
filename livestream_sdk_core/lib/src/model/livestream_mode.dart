import 'livestream_status.dart';

/// The live `mode` returned by `GET /sessions?include=livestream_detail`
/// (BE API GENP-3379). Authoritative session state as classified by the
/// backend, replacing the client-side derivation from `preset` / `price` /
/// `exclusive` that the old retained-events flow relied on.
enum LivestreamMode {
  free,
  show,
  private,
  exclusive,
  crowdfunding,
  performing,
  encoring,
  performancePreparing,
  exclusiveEnd,

  /// Value not recognized by this SDK version (forward-compatibility).
  unknown;

  /// Parses the backend wire value. Unknown / null values map to [unknown]
  /// rather than throwing, so a newly added backend mode never crashes the
  /// feed — it simply renders as [LivestreamStatus.offline].
  static LivestreamMode fromWire(String? value) => switch (value) {
    'free' => free,
    'show' => show,
    'private' => private,
    'exclusive' => exclusive,
    'crowdfunding' => crowdfunding,
    'performing' => performing,
    'encoring' => encoring,
    'performance_preparing' => performancePreparing,
    'exclusiveEnd' => exclusiveEnd,
    _ => unknown,
  };

  /// Collapses the backend mode into the coarser [LivestreamStatus] the card
  /// UI renders. `show` / `private` / `performing` / `encoring` /
  /// `performance_preparing` all present as a performing show; `exclusiveEnd`
  /// and [unknown] are treated as not-live and hidden.
  LivestreamStatus toStatus() => switch (this) {
    free => LivestreamStatus.free,
    exclusive => LivestreamStatus.exclusive,
    crowdfunding => LivestreamStatus.funding,
    show ||
    private ||
    performing ||
    encoring ||
    performancePreparing => LivestreamStatus.performing,
    exclusiveEnd || unknown => LivestreamStatus.offline,
  };
}
