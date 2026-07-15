/// What a stream is doing right now — drives the card's status badge.
enum LivestreamStatus {
  /// Live and free to watch.
  free,

  /// Live with an exclusive (paid) show.
  exclusive,

  /// Live with a show in progress.
  performing,

  /// Live and raising funds toward a goal show — see
  /// [LivestreamItem.fundingTarget] / [LivestreamItem.fundingProgress].
  funding,

  /// Not currently live.
  offline,
}

/// One livestream card from the feed. Render the fields however fits your UI.
///
/// The cover image is not carried here — fetch it lazily per visible card
/// with `LivestreamSdk.getCoverImage(id)`.
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

  /// Unique stream id — the value to pass to `getCoverImage` and
  /// `buildLivestreamUrl`.
  final String id;

  /// The streamer's account handle.
  final String username;

  /// The streamer's display name. For the card subtitle, prefer this and fall
  /// back to [username] when `null`.
  final String? displayName;

  /// Stream title, if the streamer set one.
  final String? title;

  /// Identifier of the current live session, if any.
  final String? sessionId;

  /// See [LivestreamStatus].
  final LivestreamStatus status;

  /// Current viewer count.
  final int viewers;

  /// Average rating, 0.0–5.0; `null` when the stream has no ratings yet.
  final double? score;

  /// Number of ratings behind [score] — typically shown next to the stars,
  /// e.g. `⭐ 4.8 (312)`.
  final int reviewCount;

  /// Raw badge tags from the backend. The common ones are already surfaced as
  /// typed fields ([countryFlag], [isVipSponsor], [isNewbie], [hasToy]); use
  /// this only if you need something beyond those.
  final List<String> badges;

  /// The streamer's country code (e.g. `jp`) for a flag icon, when known.
  final String? countryFlag;

  /// Badge flag: VIP-sponsored streamer.
  final bool isVipSponsor;

  /// Badge flag: new streamer.
  final bool isNewbie;

  /// Badge flag: interactive toy connected.
  final bool hasToy;

  /// Funding shows only: the ticket goal. Remaining tickets =
  /// `fundingTarget - fundingProgress` (clamp at 0).
  final int? fundingTarget;

  /// Funding shows only: tickets sold so far.
  final int? fundingProgress;

  /// Internal wire form used by the SDK's native bridge — not needed when
  /// calling the Dart API directly.
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
