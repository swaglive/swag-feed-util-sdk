/// Wire shape of one element of `GET /sessions?include=livestream_detail`
/// (BE API GENP-3379).
///
/// The endpoint returns an array of active sessions; each element carries the
/// existing session fields plus the `include=livestream_detail` additions
/// (`mode`, `exclusive`, `categories`, `devices`, `snapshot`, `title`,
/// `current_rating[_count]`, `funding_target`, `funding_progress`). Streamers
/// whose `user_id` was requested but do not appear in the array are offline.
///
/// Every field is nullable (defensive against backend changes); the mapper
/// supplies the render-facing shape. Hand-written (no freezed/json_serializable)
/// so the package builds without a codegen step, matching the plain-model style
/// of the rest of `livestream_sdk_core`.
class SessionResponse {
  const SessionResponse({
    this.id,
    this.streamer,
    this.preset,
    this.streamType,
    this.pricing,
    this.viewerCount,
    this.mode,
    this.exclusive,
    this.categories,
    this.devices,
    this.snapshot,
    this.title,
    this.currentRating,
    this.currentRatingCount,
    this.fundingTarget,
    this.fundingProgress,
  });

  /// Session id.
  final String? id;

  /// Streamer (user) id — the key used to map a session back to a feed entry.
  final String? streamer;

  final String? preset;
  final String? streamType;

  /// `pricing: { preview, sd }` — price per preset.
  final Map<String, int?>? pricing;

  /// `metadata.viewer_count: { preview, sd }` — viewers per preset.
  final Map<String, int?>? viewerCount;

  /// Raw `mode` wire value (see [LivestreamMode] for the parsed enum).
  final String? mode;

  final bool? exclusive;
  final List<String>? categories;
  final List<String>? devices;

  /// Encrypted snapshot (cover) path; `null` when none.
  final String? snapshot;

  final String? title;

  /// 0–100 raw rating; `null` below the rating threshold.
  final double? currentRating;
  final int? currentRatingCount;

  /// Reflects an in-progress funding/show goal only; `null` otherwise.
  final int? fundingTarget;
  final int? fundingProgress;

  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    final metadata = (json['metadata'] as Map?)?.cast<String, dynamic>();
    return SessionResponse(
      id: json['id'] as String?,
      streamer: json['streamer'] as String?,
      preset: json['preset'] as String?,
      streamType: json['streamType'] as String?,
      pricing: _intMap(json['pricing']),
      viewerCount: _intMap(metadata?['viewer_count']),
      mode: json['mode'] as String?,
      exclusive: json['exclusive'] as bool?,
      categories: _stringList(json['categories']),
      devices: _stringList(json['devices']),
      snapshot: json['snapshot'] as String?,
      title: json['title'] as String?,
      currentRating: (json['current_rating'] as num?)?.toDouble(),
      currentRatingCount: (json['current_rating_count'] as num?)?.toInt(),
      fundingTarget: (json['funding_target'] as num?)?.toInt(),
      fundingProgress: (json['funding_progress'] as num?)?.toInt(),
    );
  }
}

Map<String, int?>? _intMap(dynamic value) {
  if (value is! Map) return null;
  return {
    for (final entry in value.entries)
      entry.key.toString(): (entry.value as num?)?.toInt(),
  };
}

List<String>? _stringList(dynamic value) =>
    value is List ? value.whereType<String>().toList() : null;
