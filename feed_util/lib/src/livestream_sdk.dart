import 'dart:typed_data';

import 'model/livestream_page.dart';

import 'livestream_sdk_impl.dart';

/// SDK configuration (spec §07 — minimal injection).
///
/// Only [trackerServers] is caller-required. The tracker auth token is baked
/// into the SDK at build time (CI secret, never a source literal) and can
/// optionally be overridden; labels are truly optional.
class LivestreamSdkConfig {
  const LivestreamSdkConfig({
    required this.trackerServers,
    this.trackerAuthToken,
    this.trackerLabels,
  });

  /// Domain tracker candidate config-server hosts (required, spec-mandated
  /// external injection).
  final List<String> trackerServers;

  /// `null` = use the SDK's built-in Swag token.
  final String? trackerAuthToken;

  /// `null` = no resource filtering.
  final List<String>? trackerLabels;
}

/// Dart-side facade of the Livestream SDK (spec §03, GENP-3261).
///
/// Three core features behind one contract:
///
/// 1. Domain tracker — resolved lazily on the first [getLivestreamList] call
///    and cached; callers never see domains.
/// 2. Livestream feed — [getLivestreamList] (+ lazy [getCoverImage]).
/// 3. Livestream URL — [buildLivestreamUrl] from the cached frontend base.
///
/// The native `FeedUtil` entry points call these methods over the
/// `feed_util/method` MethodChannel (bridge contract in spec §03).
abstract interface class LivestreamSdk {
  /// Applies caller configuration. Must be called before any other method.
  factory LivestreamSdk(LivestreamSdkConfig config) = LivestreamSdkImpl;

  /// Fetches one page of the livestream feed.
  ///
  /// First call resolves and caches domains internally. Pass [pageToken]
  /// from the previous page's [LivestreamPage.nextToken] (or `null` for the
  /// first page). [bustCache] appends a timestamp cache-buster so the CDN
  /// edge cache is bypassed.
  ///
  /// Throws [DomainTrackerServerNotFoundException] when every tracker server
  /// is unreachable.
  Future<LivestreamPage> getLivestreamList(
    String feedId, {
    PageToken? pageToken,
    bool bustCache = false,
  });

  /// Decrypts and returns the cover image for [livestreamId], or `null` when
  /// the livestream has no snapshot.
  ///
  /// Lazy by design (call when the card scrolls into view): the encrypted
  /// snapshot path is SDK-internal, decryption happens in memory, and plaintext
  /// never touches disk (spec §03). Covers change as the stream goes on, so
  /// results are cached in memory following the origin's HTTP cache directives
  /// (revalidated when stale) rather than pinned — repeated calls stay fresh.
  Future<Uint8List?> getCoverImage(String livestreamId);

  /// Builds the livestream web-view URL (spec §06):
  /// `{frontendBase}/user/{livestreamId}/livestream`.
  ///
  /// Requires domains to be resolved (a prior successful
  /// [getLivestreamList]).
  String buildLivestreamUrl(String livestreamId);
}

/// Thrown when no domain tracker config server responds (spec §04 step 1).
class DomainTrackerServerNotFoundException implements Exception {
  const DomainTrackerServerNotFoundException([this.message]);

  final String? message;

  @override
  String toString() =>
      'DomainTrackerServerNotFoundException(${message ?? 'all tracker servers unreachable'})';
}
