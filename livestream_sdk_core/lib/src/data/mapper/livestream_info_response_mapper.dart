import '../../model/livestream.dart';
import '../../model/livestream_metadata.dart';
import '../model/livestream_info_response.dart';

/// Maps a feed-list DTO to the pure [Livestream] domain model (base entry,
/// no live schedule yet — enrichment attaches that later).
extension LivestreamInfoResponseMapper on LivestreamInfoResponse {
  Livestream toLivestream() {
    final resolvedId = id;
    if (resolvedId == null || resolvedId.isEmpty) {
      throw const FormatException('LivestreamInfoResponse: missing id');
    }
    final resolvedUsername = username;
    if (resolvedUsername == null || resolvedUsername.isEmpty) {
      throw const FormatException('LivestreamInfoResponse: missing username');
    }
    return Livestream(
      id: resolvedId,
      username: resolvedUsername,
      displayName: displayName,
      biography: biography ?? '',
      badges: badges ?? const [],
      metadata: _metadataFromMap(metadata),
    );
  }
}

/// Parses the feed's raw `metadata` map. Mirrors the app's
/// `LivestreamMetadata.fromMap` (including the `s_score`/`score` and
/// `newbie`/`is_new` fallbacks).
LivestreamMetadata _metadataFromMap(Map<String, dynamic>? json) {
  if (json == null) return LivestreamMetadata.empty;
  final score = ((json['s_score'] ?? json['score'] ?? 0.0) as num).toDouble();
  return LivestreamMetadata(
    viewers: (json['viewers'] as num?)?.toInt() ?? 0,
    score: score,
    reviews: (json['reviews'] as num?)?.toInt() ?? 0,
    newbie: json['newbie'] == true || json['is_new'] == true,
    toy: json['toy'] == true,
    lovense: json['lovense'] == true,
    vip: json['vip'] == true,
    vipSponsor: json['vip_sponsor'] == true,
    rank: (json['rank'] as num?)?.toInt(),
  );
}
