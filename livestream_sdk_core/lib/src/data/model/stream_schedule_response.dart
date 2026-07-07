/// Wire shape of a `stream.online` retained-event `data` payload.
///
/// Only the fields the feed needs are modelled; the repository layers on
/// rating / viewers / goal data accumulated from sibling retained events.
///
/// Hand-written (no freezed/json_serializable) so the package builds without a
/// codegen step.
class StreamScheduleResponse {
  const StreamScheduleResponse({
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
  });

  final String? sessionId;
  final String? preset;
  final int? price;
  final String? snapshot;
  final bool? exclusive;
  final String? title;
  final List<String>? categories;
  final List<String>? devices;
  final double? currentRating;
  final int? currentRatingCount;

  factory StreamScheduleResponse.fromJson(Map<String, dynamic> json) {
    return StreamScheduleResponse(
      sessionId: json['session'] as String?,
      preset: json['preset'] as String?,
      price: (json['price'] as num?)?.toInt(),
      snapshot: json['snapshot'] as String?,
      exclusive: json['exclusive'] as bool?,
      title: json['title'] as String?,
      categories: _stringList(json['categories']),
      devices: _stringList(json['devices']),
      currentRating: (json['current_rating'] as num?)?.toDouble(),
      currentRatingCount: (json['current_rating_count'] as num?)?.toInt(),
    );
  }
}

/// Wire shape of a `goal.*` retained event.
///
/// The feed reads the first level's `title` / `target` (funding target and
/// show title) and the rolling `progress`. Lightweight events such as
/// `goal.progress.updated` omit `levels`, so the repository accumulates each
/// field independently rather than overwriting wholesale.
class GoalEventResponse {
  const GoalEventResponse({this.progress, this.levels});

  final int? progress;
  final List<GoalLevelResponse>? levels;

  factory GoalEventResponse.fromJson(Map<String, dynamic> json) {
    final rawLevels = json['levels'];
    return GoalEventResponse(
      progress: (json['progress'] as num?)?.toInt(),
      levels: rawLevels is List
          ? rawLevels
                .whereType<Map>()
                .map(
                  (e) => GoalLevelResponse.fromJson(e.cast<String, dynamic>()),
                )
                .toList()
          : null,
    );
  }
}

class GoalLevelResponse {
  const GoalLevelResponse({this.title, this.target});

  final String? title;
  final int? target;

  factory GoalLevelResponse.fromJson(Map<String, dynamic> json) {
    return GoalLevelResponse(
      title: json['title'] as String?,
      target: (json['target'] as num?)?.toInt(),
    );
  }
}

List<String>? _stringList(dynamic value) =>
    value is List ? value.whereType<String>().toList() : null;
