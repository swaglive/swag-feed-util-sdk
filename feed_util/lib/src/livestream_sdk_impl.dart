import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:livestream_sdk_core/livestream_sdk_core.dart' as sdk_core;

import 'livestream_sdk.dart';
import 'model/livestream_item.dart';
import 'model/livestream_page.dart';

/// Tracker auth token baked in at build time (spec §07):
/// `--dart-define=FEED_UTIL_TRACKER_AUTH_TOKEN=...` from CI secret.
/// Never a source literal; [LivestreamSdkConfig.trackerAuthToken] overrides.
const _builtInTrackerAuthToken = String.fromEnvironment(
  'FEED_UTIL_TRACKER_AUTH_TOKEN',
);

/// Concrete [LivestreamSdk].
///
/// Feature 1 (domain tracker) resolves lazily and exactly once in flight:
/// the first [getLivestreamList] (or [prewarm]) races the tracker servers,
/// picks the best `api` / `frontend` resources, and caches them for the
/// SDK's lifetime. The pipeline itself is `sdk_core.DomainTracker` — the
/// production-proven algorithm extracted from the main apps (WS-A).
///
/// The feed/cover internals plug in the feed logic extracted from the main
/// apps (WS-B) — see the TODOs.
class LivestreamSdkImpl implements LivestreamSdk {
  /// [httpClient] is a seam for tests; defaults to a client with the
  /// tracker Bearer-token and time-profiling interceptors installed
  /// (the tracker's ttfb measurement depends on the latter).
  LivestreamSdkImpl(this._config, {Dio? httpClient})
    : _http = httpClient ?? _defaultHttpClient(_config) {
    // Only augment the client we create ourselves. An injected [httpClient]
    // (test seam / shared Dio) is left exactly as the caller configured it — we
    // neither replace its transformer (set in _defaultHttpClient) nor add the
    // EncryptedDomainInterceptor to it, so we can't mutate a shared client or
    // register a duplicate interceptor on one the caller already set up.
    if (httpClient == null) {
      // HTTP cache (covers only). Added before the reroute so the cache key is
      // the stable public-host URL rather than the rotating encrypted mirror;
      // on a miss/stale entry the request continues down the chain, the reroute
      // swaps the host, and revalidation (ETag / Last-Modified / max-age) hits
      // the mirror. The global policy is noCache, so tracker health probes and
      // feed requests are never served or stored — only the cover request opts
      // into CachePolicy.request (see _coverRequestOptions).
      _http.interceptors.add(DioCacheInterceptor(options: _baseCacheOptions));

      // Reroute public-asset requests to the AES-encrypted mirror. Hosts are
      // read lazily from the tracker-resolved bases (unknown at construction);
      // the interceptor no-ops until both are present. Decryption itself is
      // handled by the AesDecryptFusedTransformer the default client carries.
      _http.interceptors.add(
        sdk_core.EncryptedDomainInterceptor(
          publicHost: () => _bases?.publicBase?.host,
          encryptedPublicHost: () => _bases?.encryptedPublicBase?.host,
        ),
      );
    }
  }

  final LivestreamSdkConfig _config;
  final Dio _http;

  /// Single-flight guard + cache for domain resolution.
  Completer<_ResolvedBases>? _resolving;
  _ResolvedBases? _bases;

  /// Feed data source, created lazily once the api base is resolved and then
  /// reused (Feature 2, WS-B). Backed by the shared pure-Dart
  /// `livestream_sdk_core` feed logic over the SDK's tracker-aware [_http].
  sdk_core.DioLivestreamFeedRepository? _feedRepository;

  /// `livestreamId -> encrypted snapshot path`, captured from list responses.
  /// The path is kept SDK-internal (never surfaced on [LivestreamItem]); the
  /// cover is fetched lazily by [getCoverImage]. Keyed by id, so re-listing a
  /// stream refreshes its path; the map is small (paths are short strings).
  final Map<String, String> _snapshotPathById = {};

  /// Per-id de-duplication of concurrent cover fetches, so a fast scroll that
  /// requests the same cover twice only fetches (and decrypts) it once.
  /// Complements [_baseCacheOptions] — the HTTP cache dedupes across calls,
  /// this dedupes calls that are simultaneously in flight (before the cache is
  /// populated). dio_cache_interceptor does not coalesce concurrent requests.
  final Map<String, Future<Uint8List?>> _coverInFlight = {};

  /// Volatile (in-memory only, LRU) cover cache — spec §03: decrypted plaintext
  /// never touches disk, so this is deliberately [MemCacheStore], not a file /
  /// hive store. Covers change over time to reflect the live stream, so we let
  /// the origin's HTTP directives drive freshness rather than pinning bytes.
  final CacheStore _coverCacheStore = MemCacheStore();

  /// Default cache behaviour for [_http]. [CachePolicy.noCache] means: never
  /// serve or store from cache — so the tracker's latency probes and the feed
  /// are untouched. Only the cover request overrides this (see
  /// [_coverRequestOptions]).
  late final CacheOptions _baseCacheOptions = CacheOptions(
    store: _coverCacheStore,
    policy: CachePolicy.noCache,
  );

  /// Per-request options for a cover fetch: bytes response + [CachePolicy]
  /// `request`, which serves an un-expired cached cover and otherwise
  /// revalidates against the origin (ETag / Last-Modified / max-age).
  Options get _coverRequestOptions => _baseCacheOptions
      .copyWith(policy: CachePolicy.request)
      .toOptions()
      .copyWith(responseType: ResponseType.bytes);

  /// Cover snapshot size requested from the CDN (mirrors packages/core's
  /// `LivestreamUrlUtils`).
  static const String _coverSize = '512x512';

  /// Implementation detail (not on [LivestreamSdk]): lets the native facade
  /// warm the engine + resolve domains at host-app startup (spec §03).
  Future<void> prewarm() async {
    await _resolveBases();
  }

  /// Implementation detail (not on [LivestreamSdk]): resolved frontend base
  /// handed to the native facade so its `buildLivestreamUrl` stays sync.
  Future<String> resolvedFrontendBase() async =>
      (await _resolveBases()).frontend.toString();

  @override
  Future<LivestreamPage> getLivestreamList(
    String feedId, {
    PageToken? pageToken,
    bool bustCache = false,
  }) async {
    final bases = await _resolveBases();
    final repository = _feedRepository ??= sdk_core.DioLivestreamFeedRepository(
      apiBase: bases.api,
      httpClient: _http,
    );

    // Resolve the config path to the real feed path on the first page only;
    // subsequent pages carry it (and the next page number) inside the opaque
    // [PageToken], so paging never re-runs the redirect.
    final String feedPath;
    final int page;
    if (pageToken == null) {
      final resolved = await repository.resolveFeedPath(feedId);
      if (resolved == null || resolved.isEmpty) {
        throw sdk_core.FeedPathResolutionException(feedId);
      }
      feedPath = resolved;
      page = 1;
    } else {
      final cursor = _FeedCursor.decode(pageToken);
      feedPath = cursor.feedPath;
      page = cursor.page;
    }

    // A cache-buster is added as an extra query param on the feed path; the
    // repository preserves unknown query params, so it flows to the CDN edge.
    final requestPath = bustCache ? _withCacheBuster(feedPath) : feedPath;

    final base = await repository.getLivestreamList(
      feedPath: requestPath,
      page: page,
      limit: _pageSize,
    );
    // Enrich with live schedules (title/snapshot/session/status/viewers/…) —
    // this is the packaged GetStreamSchedule logic (batch retained-events).
    final enriched = await sdk_core.EnrichLivestreamTitlesUseCase(
      repository,
    ).call(base);

    // Retain each stream's encrypted snapshot path for lazy getCoverImage.
    for (final livestream in enriched) {
      final snapshotPath = livestream.snapshot;
      if (snapshotPath != null && snapshotPath.isNotEmpty) {
        _snapshotPathById[livestream.id] = snapshotPath;
      } else {
        // The stream no longer exposes a snapshot (e.g. it went offline).
        // Drop any previously captured path so getCoverImage returns null
        // rather than a stale/dead cover.
        _snapshotPathById.remove(livestream.id);
      }
    }

    // A full page implies there may be more; a short page is the last one.
    final PageToken? nextToken = base.length >= _pageSize
        ? _FeedCursor(feedPath: feedPath, page: page + 1).encode()
        : null;

    return LivestreamPage(
      items: [for (final livestream in enriched) _toItem(livestream)],
      nextToken: nextToken,
    );
  }

  /// Feed page size. Delegates to the shared core's product default so the
  /// SDK and the in-app feed page identically.
  static const int _pageSize = sdk_core.LivestreamFeedPaging.defaultPageSize;

  /// Appends a timestamp query param so the CDN edge cache is bypassed.
  static String _withCacheBuster(String feedPath) {
    final uri = Uri.parse(feedPath);
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    return uri
        .replace(queryParameters: {...uri.queryParameters, '_ts': ts})
        .toString();
  }

  /// Maps a core [sdk_core.Livestream] to the SDK's wire [LivestreamItem].
  static LivestreamItem _toItem(sdk_core.Livestream livestream) {
    return LivestreamItem(
      id: livestream.id,
      username: livestream.username,
      displayName: livestream.displayName,
      title: livestream.title,
      sessionId: livestream.sessionId,
      status: _mapStatus(livestream.status),
      viewers: livestream.viewers,
      score: livestream.score,
      reviewCount: livestream.reviewCount,
      badges: livestream.badges,
      countryFlag: livestream.countryFlag,
      isVipSponsor: livestream.isVipSponsor,
      isNewbie: livestream.isNewbie,
      hasToy: livestream.hasToy,
      fundingTarget: livestream.fundingTarget,
      fundingProgress: livestream.fundingProgress,
    );
  }

  static LivestreamStatus _mapStatus(sdk_core.LivestreamStatus status) {
    switch (status) {
      case sdk_core.LivestreamStatus.free:
        return LivestreamStatus.free;
      case sdk_core.LivestreamStatus.exclusive:
        return LivestreamStatus.exclusive;
      case sdk_core.LivestreamStatus.performing:
        return LivestreamStatus.performing;
      case sdk_core.LivestreamStatus.funding:
        return LivestreamStatus.funding;
      case sdk_core.LivestreamStatus.offline:
        return LivestreamStatus.offline;
    }
  }

  @override
  Future<Uint8List?> getCoverImage(String livestreamId) {
    // Single-flight: join an in-progress fetch for the same id. Cross-call
    // caching + freshness is handled by the HTTP cache on [_http].
    final inFlight = _coverInFlight[livestreamId];
    if (inFlight != null) return inFlight;

    final future = _fetchCover(livestreamId);
    _coverInFlight[livestreamId] = future;
    return future.whenComplete(() => _coverInFlight.remove(livestreamId));
  }

  /// Fetches and decrypts the cover for [livestreamId]. The transport does the
  /// heavy lifting: [sdk_core.EncryptedDomainInterceptor] reroutes the public
  /// host to the encrypted mirror and [sdk_core.AesDecryptFusedTransformer]
  /// turns the `X-Encrypted-*` response into plaintext bytes.
  ///
  /// Returns `null` (rather than throwing) when there's nothing to show: no
  /// snapshot path captured for this id, the public host isn't resolved yet, an
  /// empty body, or a 404.
  Future<Uint8List?> _fetchCover(String livestreamId) async {
    final snapshotPath = _snapshotPathById[livestreamId];
    if (snapshotPath == null) return null; // stream has no snapshot

    final bases = await _resolveBases();
    final publicBase = bases.publicBase;
    if (publicBase == null) return null; // public host not resolved (B1)

    final url = sdk_core.buildSnapshotUrl(
      snapshotPath: snapshotPath,
      publicBase: publicBase,
      size: _coverSize,
    );

    try {
      // _coverRequestOptions opts this request into the HTTP cache
      // (CachePolicy.request): a fresh cached cover is returned without a
      // network hit, a stale one is revalidated (304 -> cached bytes).
      final response = await _http.get<List<int>>(
        url.toString(),
        options: _coverRequestOptions,
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;
      return Uint8List.fromList(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  String buildLivestreamUrl(String livestreamId) {
    final bases = _bases;
    if (bases == null) {
      throw StateError(
        'domains not resolved yet — call getLivestreamList or prewarm first',
      );
    }
    // Spec §06: {frontendBase}/user/{id}/livestream
    // Encode the id: ? / # or / inside it would otherwise be read by
    // Uri.resolve as query/fragment/path separators and corrupt the URL.
    return bases.frontend
        .resolve('user/')
        .resolve('${Uri.encodeComponent(livestreamId)}/')
        .resolve('livestream')
        .toString();
  }

  /// Lazy, cached, single-flight domain resolution (Feature 1).
  Future<_ResolvedBases> _resolveBases() {
    final cached = _bases;
    if (cached != null) return Future.value(cached);

    final inFlight = _resolving;
    if (inFlight != null) return inFlight.future;

    final completer = _resolving = Completer<_ResolvedBases>();
    _runResolve().then(
      (bases) {
        _bases = bases;
        _resolving = null; // resolved: the cache serves reads from here on
        completer.complete(bases);
      },
      onError: (Object e, StackTrace s) {
        _resolving = null; // allow retry after failure
        completer.completeError(e, s);
      },
    );
    return completer.future;
  }

  /// Spec §04 steps 1–4 via the extracted pipeline (WS-A/A4): race
  /// checkHealth() over the config servers, fetch + group resources, race
  /// checkResourceHealth() per priority group, return the api/frontend bases.
  Future<_ResolvedBases> _runResolve() async {
    final tracker = sdk_core.DomainTracker(
      trackerServers: _config.trackerServers.map(_serverUriOf).toList(),
      resourceLabels: _config.trackerLabels,
      repositoryFactory: (host) =>
          sdk_core.DioDomainTrackerRepository(host: host, httpClient: _http),
    );

    try {
      final resolved = await tracker.resolve();
      return _ResolvedBases(
        api: resolved.api,
        frontend: resolved.frontend,
        // Optional hosts for EncryptedDomainInterceptor's public->encrypted
        // rerouting. The exact tracker resource types are pending the backend
        // merged-API confirmation (WS-B / B1); until the tracker advertises
        // them these lookups are null and the interceptor stays a no-op.
        publicBase: resolved.uris[_publicResourceType],
        encryptedPublicBase: resolved.uris[_encryptedPublicResourceType],
      );
    } on sdk_core.DomainTrackerServerNotFoundException catch (e) {
      // Translate to the exception type declared on the LivestreamSdk
      // interface (mapped to PlatformException
      // 'domain_tracker_server_not_found' by the channel layer).
      throw DomainTrackerServerNotFoundException(
        e.message.isEmpty ? null : e.message,
      );
    }
    // NOTE: sdk_core.HealthyResourceNotFoundException (steps 2–3: resources
    // exist but none healthy / required types missing) propagates as-is; the
    // channel layer maps it to a generic error code (B2 decides the mapping —
    // the LivestreamSdk interface deliberately only declares the
    // server-not-found case).
  }

  /// Tracker resource types for the public image CDN and its AES-encrypted
  /// mirror, consumed by [sdk_core.EncryptedDomainInterceptor]. The public type
  /// is `cdn` (confirmed); the encrypted mirror is still a placeholder pending
  /// the backend contract (WS-B / B1). A missing type resolves to `null`,
  /// leaving the interceptor a no-op.
  static const _publicResourceType = 'cdn';
  static const _encryptedPublicResourceType = 'encrypted-public';

  /// Normalizes a tracker server entry to a full https [Uri], accepting both
  /// full URLs (`https://t1.example.com`) and bare hosts (`t1.example.com`).
  static Uri _serverUriOf(String server) =>
      server.contains('://') ? Uri.parse(server) : Uri.parse('https://$server');

  /// Extracts the host from a tracker server entry, accepting both full
  /// URLs (`https://t1.example.com`) and bare hosts (`t1.example.com`) —
  /// `Uri.parse` alone returns an empty host for the latter, which would
  /// silently skip Bearer-token attachment.
  static String _hostOf(String server) => _serverUriOf(server).host;

  static Dio _defaultHttpClient(LivestreamSdkConfig config) {
    final token = config.trackerAuthToken ?? _builtInTrackerAuthToken;
    final trackerHosts = config.trackerServers.map(_hostOf).toSet();
    return Dio()
      // Transparently AES-decrypts any response whose X-Encrypted-* headers
      // say so (cover images), and behaves like the default transformer for
      // all plain traffic (tracker health checks, feed JSON) — so it's safe as
      // the single transformer for every request this client makes.
      ..transformer = sdk_core.AesDecryptFusedTransformer()
      ..interceptors.addAll([
        // rtt/ttfb measurement for the tracker health checks.
        sdk_core.TimeProfilingInterceptor(),
        // Bearer auth only toward tracker servers.
        sdk_core.DomainTrackerAuthInterceptor(
          trackerHosts: trackerHosts,
          authToken: token,
        ),
      ]);
  }
}

/// Resolved bases the SDK actually needs (spec §04 step 4: `api` + `frontend`).
class _ResolvedBases {
  const _ResolvedBases({
    required this.api,
    required this.frontend,
    this.publicBase,
    this.encryptedPublicBase,
  });

  final Uri api;
  final Uri frontend;

  /// Public image-CDN base, if the tracker advertises one (else `null`).
  final Uri? publicBase;

  /// AES-encrypted mirror of [publicBase], if advertised (else `null`).
  final Uri? encryptedPublicBase;
}

/// The paging state the SDK encodes inside the opaque [PageToken]: the
/// already-resolved real feed path plus the next page number. Keeping the
/// resolved path here means paging never re-runs the feed-path redirect.
class _FeedCursor {
  const _FeedCursor({required this.feedPath, required this.page});

  final String feedPath;
  final int page;

  PageToken encode() => PageToken(
    base64Url.encode(utf8.encode(jsonEncode({'p': feedPath, 'n': page}))),
  );

  /// Decodes a [PageToken] previously produced by [encode].
  ///
  /// Tokens are opaque, so a malformed or stale-format token (bad base64/JSON,
  /// missing/wrong-typed fields) is a caller error rather than something to
  /// silently paper over: it throws a clear [FormatException] instead of the
  /// raw base64/JSON/cast error, so pagination fails loudly and debuggably.
  static _FeedCursor decode(PageToken token) {
    try {
      final decoded =
          jsonDecode(utf8.decode(base64Url.decode(token.raw)))
              as Map<String, dynamic>;
      final feedPath = decoded['p'] as String;
      final page = (decoded['n'] as num).toInt();
      return _FeedCursor(feedPath: feedPath, page: page);
    } catch (_) {
      throw const FormatException(
        'Invalid or unrecognized livestream feed PageToken',
      );
    }
  }
}
