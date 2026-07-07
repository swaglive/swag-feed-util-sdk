/// Final output of [DomainTracker.resolve] (spec §04 step 4): the bases a
/// consumer needs for later API access.
///
/// [api] is the resolved API base for backend requests (e.g. the livestream
/// feed: `{api}/{feedPath}?limit&page&sorting`). [frontend] is the resolved
/// public domain, used to build user-facing web-view URLs.
class ResolvedDomains {
  const ResolvedDomains({
    required this.api,
    required this.frontend,
    required this.uris,
    required this.remoteConfigOverrides,
    required this.isFrontendChanged,
  });

  /// Best healthy `api` resource base.
  final Uri api;

  /// Best healthy `frontend` (public domain) resource base.
  final Uri frontend;

  /// Every resolved resource type → base uri (includes [api] and [frontend];
  /// future types such as `cdn` appear here without an API change).
  final Map<String, Uri> uris;

  /// Remote-config overrides attached to the selected resources' metadata.
  final Map<String, String> remoteConfigOverrides;

  /// Whether the selected frontend differs from the one cached in the
  /// injected [DomainTrackerBestServersStore] (always `true` without a store).
  final bool isFrontendChanged;
}
