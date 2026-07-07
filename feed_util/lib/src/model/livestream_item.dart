/// Card status shown by the caller's UI.
///
/// Spec §05: derived from `preset` / `price` / `exclusive` / funding
/// target-progress (or returned directly by the merged feed API as `status`).
enum LivestreamStatus { free, exclusive, performing, funding, offline }

/// One livestream card from the feed (spec §03 / §05 merged-API shape).
///
/// Note: the cover image is deliberately NOT here — the snapshot path is
/// encrypted and kept SDK-internal; callers fetch decrypted bytes lazily via
/// `LivestreamSdk.getCoverImage(id)`.
///
/// Serialization (hand-written `toMap`/`fromMap` + round-trip tests) is
/// task B2 — not part of the interface definition.
class LivestreamItem {
  const LivestreamItem({
    required this.id,
    required this.username,
    this.displayName,
    this.title,
    this.sessionId,
    required this.status,
    required this.viewers,
    this.score,
    required this.reviewCount,
    this.badges = const [],
    this.countryFlag,
    this.isVipSponsor = false,
    this.isNewbie = false,
    this.hasToy = false,
    this.fundingTarget,
    this.fundingProgress,
  });

  // Identity
  final String id;
  final String username;
  final String? displayName;

  // Content
  final String? title;

  // Session
  final String? sessionId;
  final LivestreamStatus status;

  // Metrics
  final int viewers;

  /// 0.0–5.0 (unit to be finalized with backend, spec §05 note 2).
  final double? score;
  final int reviewCount;

  // Badges
  final List<String> badges;

  /// Derived from a `country:xx` entry in [badges].
  final String? countryFlag;
  final bool isVipSponsor;
  final bool isNewbie;
  final bool hasToy;

  // Funding shows only
  final int? fundingTarget;
  final int? fundingProgress;

  /// Wire form sent to native over the MethodChannel (bridge contract).
  /// `status` is the enum name; `fromMap` + round-trip tests are task B2.
  Map<String, Object?> toMap() => {
    'id': id,
    'username': username,
    'displayName': displayName,
    'title': title,
    'sessionId': sessionId,
    'status': status.name,
    'viewers': viewers,
    'score': score,
    'reviewCount': reviewCount,
    'badges': badges,
    'countryFlag': countryFlag,
    'isVipSponsor': isVipSponsor,
    'isNewbie': isNewbie,
    'hasToy': hasToy,
    'fundingTarget': fundingTarget,
    'fundingProgress': fundingProgress,
  };
}
