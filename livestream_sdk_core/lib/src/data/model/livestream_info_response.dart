/// Wire shape of one entry in the livestream feed list response.
///
/// Every field is nullable (defensive against backend changes); the mapper
/// supplies defaults. `metadata` is kept as a raw map because its keys vary
/// by feed and are parsed by `LivestreamMetadata` in the mapper.
///
/// Hand-written (no freezed/json_serializable) so the package builds without a
/// codegen step, matching the plain-model style of `ResolvedDomains`.
class LivestreamInfoResponse {
  const LivestreamInfoResponse({
    this.id,
    this.username,
    this.biography,
    this.displayName,
    this.metadata,
    this.badges,
  });

  final String? id;
  final String? username;
  final String? biography;
  final String? displayName;
  final Map<String, dynamic>? metadata;
  final List<String>? badges;

  factory LivestreamInfoResponse.fromJson(Map<String, dynamic> json) {
    final rawBadges = json['badges'];
    return LivestreamInfoResponse(
      id: json['id'] as String?,
      username: json['username'] as String?,
      biography: json['biography'] as String?,
      displayName: json['displayName'] as String?,
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>(),
      badges: rawBadges is List ? rawBadges.whereType<String>().toList() : null,
    );
  }
}
