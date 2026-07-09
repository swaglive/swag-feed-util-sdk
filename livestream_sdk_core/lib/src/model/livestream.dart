import 'livestream_metadata.dart';
import 'livestream_status.dart';
import 'stream_schedule.dart';

/// A single livestream feed entry.
///
/// Combines the static feed payload (identity, badges, [metadata]) with the
/// optional live [schedule] parsed from retained events. All render-facing
/// values (status, viewers, score, title, …) are derived here so the SDK and
/// the in-app home feed classify a stream identically (see the app's
/// `LivestreamModelX`).
class Livestream {
  const Livestream({
    required this.id,
    required this.username,
    this.displayName,
    this.biography = '',
    this.badges = const [],
    this.metadata = LivestreamMetadata.empty,
    this.schedule,
  });

  /// Streamer id (also the retained-event channel key).
  final String id;
  final String username;
  final String? displayName;
  final String biography;
  final List<String> badges;

  /// Static feed metrics (fallback before/without live enrichment).
  final LivestreamMetadata metadata;

  /// Live state; `null` means the streamer is offline.
  final StreamSchedule? schedule;

  /// Rating comes from the backend on a 0–100 scale; the UI shows 0.0–5.0.
  static const double _scoreScaleFactor = 20.0;

  /// Returns a copy with the live [schedule] attached (used by enrichment).
  Livestream withSchedule(StreamSchedule? schedule) => Livestream(
    id: id,
    username: username,
    displayName: displayName,
    biography: biography,
    badges: badges,
    metadata: metadata,
    schedule: schedule,
  );

  /// Card status (spec §05).
  ///
  /// The backend's `/sessions` `mode` (BE API GENP-3379) is authoritative and
  /// used whenever present. The legacy `preset` / `price` / `exclusive`
  /// derivation is kept only as a fallback for a schedule without a `mode`
  /// (ordering matches the app's `itemType`: exclusive → show → private →
  /// funding → public, else offline).
  LivestreamStatus get status {
    final s = schedule;
    if (s == null) return LivestreamStatus.offline;
    final mode = s.mode;
    if (mode != null) return mode.toStatus();
    if (s.exclusive == true) return LivestreamStatus.exclusive;
    if (s.isShow) return LivestreamStatus.performing;
    if (s.preset == StreamPreset.sd) return LivestreamStatus.performing;
    if (s.isFundingShow) return LivestreamStatus.funding;
    if (s.preset == StreamPreset.preview) return LivestreamStatus.free;
    return LivestreamStatus.offline;
  }

  String? get title => schedule?.title;
  String? get snapshot => schedule?.snapshot;
  String? get sessionId => schedule?.sessionId;

  int get viewers => schedule?.viewers ?? metadata.viewers;

  /// 0.0–5.0. Live rating (rescaled) when present and positive, otherwise the
  /// static feed score, otherwise `null`.
  double? get score {
    final live = schedule?.currentRating;
    if (live != null && live > 0) return live / _scoreScaleFactor;
    return metadata.score > 0 ? metadata.score : null;
  }

  int get reviewCount => schedule?.currentRatingCount ?? metadata.reviews;

  int? get fundingTarget => schedule?.fundingTarget;
  int? get fundingProgress => schedule?.fundingProgress;

  bool get isNewbie => metadata.newbie || badges.contains('new');

  bool get isVipSponsor =>
      metadata.vip || metadata.vipSponsor || badges.contains('vip_recommend');

  bool get hasToy =>
      metadata.toy ||
      metadata.lovense ||
      schedule?.categories?.any((c) => c == 'toy' || c == 'lovense') == true ||
      schedule?.devices?.isNotEmpty == true;

  /// Two-letter ISO country code from a `country:xx` badge, if present.
  String? get countryCode {
    for (final badge in badges) {
      if (badge.startsWith('country:')) {
        return badge.substring('country:'.length);
      }
    }
    return null;
  }

  /// The [countryCode] rendered as a flag emoji (regional-indicator pair).
  String? get countryFlag {
    final code = countryCode;
    if (code == null || code.length != 2) return null;
    final upper = code.toUpperCase();
    final first = upper.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final second = upper.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(first) + String.fromCharCode(second);
  }
}
