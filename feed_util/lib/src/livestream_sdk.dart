import 'dart:typed_data';

import 'model/livestream_page.dart';
import 'log/feed_util_log.dart';
import 'log/log_entry.dart';

import 'livestream_sdk_impl.dart';

/// Configuration for [LivestreamSdk].
///
/// Only [trackerServers] is required; the other fields are optional overrides
/// you normally leave unset.
class LivestreamSdkConfig {
  const LivestreamSdkConfig({
    required this.trackerServers,
    this.trackerAuthToken,
    this.trackerLabels,
  });

  /// Servers the SDK contacts at startup to discover working service domains
  /// (required). Use the list provided by Swag during onboarding; entries may
  /// be full URLs (`https://t1.example.com`) or bare hosts (`t1.example.com`).
  final List<String> trackerServers;

  /// Overrides the SDK's built-in access token for the servers above.
  /// Leave `null` unless Swag instructs otherwise.
  final String? trackerAuthToken;

  /// Optional filter labels provided by Swag alongside the server list.
  /// Leave `null` to accept everything.
  final List<String>? trackerLabels;
}

/// Embeds Swag livestreams in your app: list the streams that are live
/// ([getLivestreamList]), show their covers ([getCoverImage]), and open a
/// stream in a web view ([buildLivestreamUrl]) — no native player needed.
///
/// The SDK finds a reachable service domain automatically on the first
/// [getLivestreamList] call and keeps using it, so no domain or URL setup is
/// needed beyond [LivestreamSdkConfig.trackerServers].
abstract interface class LivestreamSdk {
  /// Creates an SDK instance with [config].
  ///
  /// Create one instance and reuse it: the discovered service domain and
  /// fetched covers are cached per instance.
  factory LivestreamSdk(LivestreamSdkConfig config) = LivestreamSdkImpl;

  /// Fetches one page of livestreams for [feedId].
  ///
  /// For the first page pass no [pageToken]; for the next page pass the
  /// previous page's [LivestreamPage.nextToken]. A `null` `nextToken` means
  /// there are no more pages.
  ///
  /// The first call may take noticeably longer: it also discovers a reachable
  /// service domain. Set [bustCache] to `true` to skip intermediate caches and
  /// fetch the freshest data (slower; use for explicit pull-to-refresh, not
  /// for every page).
  ///
  /// Throws [DomainTrackerServerNotFoundException] when none of the
  /// configured servers can be reached (usually no connectivity).
  Future<LivestreamPage> getLivestreamList(
    String feedId, {
    PageToken? pageToken,
    bool bustCache = false,
  });

  /// Returns the cover image for [livestreamId] as raw image bytes (ready for
  /// `Image.memory`), or `null` when the stream currently has no cover — show
  /// your own placeholder in that case.
  ///
  /// Call it lazily, per card, when the card scrolls into view. Results are
  /// cached in memory and kept fresh automatically, so calling it again for
  /// the same stream (e.g. after scrolling back) is cheap.
  ///
  /// Only ids returned by [getLivestreamList] on this instance have covers;
  /// unknown ids resolve to `null`.
  Future<Uint8List?> getCoverImage(String livestreamId);

  /// Returns the URL that opens the livestream page (player, chat, and all)
  /// for [livestreamId] — load it in a web view as-is.
  ///
  /// The URL is self-contained; don't add, remove, or rewrite any part of it,
  /// or the page may fail to load.
  ///
  /// Call after at least one successful [getLivestreamList]; before that the
  /// SDK doesn't know the service domain yet and this throws a [StateError].
  String buildLivestreamUrl(String livestreamId);

  /// Registers a [listener] for the SDK's diagnostic logs — wire it to your
  /// logging when troubleshooting an integration. Pass `null` to stop.
  ///
  /// Each [LogEntry] carries a severity and a message. Only one listener is
  /// active at a time (registration is process-wide, not per instance).
  void setLogListener(FeedUtilLogCallback? listener);
}

/// Thrown when none of the configured [LivestreamSdkConfig.trackerServers]
/// can be reached — usually the device is offline or the server list is
/// outdated. Safe to retry once connectivity returns.
class DomainTrackerServerNotFoundException implements Exception {
  const DomainTrackerServerNotFoundException([this.message]);

  final String? message;

  @override
  String toString() =>
      'DomainTrackerServerNotFoundException(${message ?? 'all tracker servers unreachable'})';
}
