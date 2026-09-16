import 'dart:typed_data';

import 'log/web_view_log_event.dart';
import 'livestream_sdk_exception.dart';
import 'model/livestream_page.dart';

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
    this.debugMode = false,
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

  /// Enables sanitized SDK diagnostics in the platform console.
  ///
  /// Defaults to `false` and is immutable for this SDK instance. It is safe to
  /// enable in release builds: output uses a fixed event/field allowlist and
  /// never contains URLs, hosts, tokens, payloads, identifiers, user data, or
  /// raw exception messages.
  final bool debugMode;
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
  ///
  /// Throws [LivestreamSdkException] with
  /// [LivestreamSdkErrorCode.invalidArgument] when [config] has no usable
  /// tracker server.
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
  /// Throws a [LivestreamSdkException] with code
  /// `LivestreamSdkErrorCode.domainUnreachable` when none of the configured
  /// servers can be reached (usually no connectivity).
  /// The SDK does not automatically retry; use
  /// [LivestreamSdkErrorCode.isRetryable] to drive host-owned retry UI.
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
  /// unknown ids resolve to `null`. An empty id throws
  /// [LivestreamSdkErrorCode.invalidArgument].
  Future<Uint8List?> getCoverImage(String livestreamId);

  /// Returns the URL that opens the livestream page (player, chat, and all)
  /// for [livestreamId] with the single-use room [otp] — load it in a web view
  /// as-is.
  ///
  /// Pass the [LivestreamItem.id] from [getLivestreamList]. The SDK maps it to
  /// that item's username because the public web route is username-based.
  ///
  /// Obtain a fresh [otp] from the partner server for every room open. Do not
  /// cache or reuse the returned URL: the room consumes the OTP on first use.
  /// The SDK validates only that [otp] is non-blank; it does not fetch,
  /// remotely validate, refresh, or retain it.
  ///
  /// The URL is self-contained; don't add, remove, or rewrite any part of it,
  /// or the page may fail to load.
  ///
  /// Call after at least one successful [getLivestreamList]; before that the
  /// SDK doesn't know the service domain yet and this throws a
  /// [LivestreamSdkException] with code [LivestreamSdkErrorCode.illegalState].
  /// Passing an id that was not returned by this instance throws
  /// [LivestreamSdkErrorCode.invalidArgument] instead of constructing a URL
  /// that may open the wrong route.
  String buildLivestreamUrl(String livestreamId, {required String otp});

  /// Reports a significant network event from the host-owned livestream web
  /// view through the SDK's sanitized diagnostics.
  ///
  /// Report main-page start/finish events and failed HTTP/network requests.
  /// Do not report successful subresources or JavaScript console output. The
  /// event model deliberately accepts no URL or free-form description.
  void reportWebViewEvent(WebViewLogEvent event);
}
