/// Static, feed-supplied metrics for a livestream card.
///
/// These come from the feed list payload's `metadata` object (NOT the live
/// `stream.online` event). They are the fallback values used before — or
/// when there is no — retained-event enrichment. Field parsing mirrors the
/// app's `LivestreamMetadata.fromMap`.
class LivestreamMetadata {
  const LivestreamMetadata({
    this.viewers = 0,
    this.score = 0.0,
    this.reviews = 0,
    this.newbie = false,
    this.toy = false,
    this.lovense = false,
    this.vip = false,
    this.vipSponsor = false,
    this.rank,
  });

  final int viewers;
  final double score;
  final int reviews;
  final bool newbie;
  final bool toy;
  final bool lovense;
  final bool vip;
  final bool vipSponsor;
  final int? rank;

  static const empty = LivestreamMetadata();
}
