import '../model/domain_tracker_resource_result.dart';

/// Persistence port for the selected best resources (webview-user-app adapts
/// this to SharedPreferenceService; feed_util runs without a store).
abstract interface class DomainTrackerBestServersStore {
  /// The frontend uri selected on a previous launch, used to compute
  /// [SelectedDomainTrackerResources.isFrontendChanged].
  Uri? getCachedFrontendUri();

  /// Persists the newly selected best resources. Implementations may complete
  /// asynchronously; failures must not propagate into the resolve flow.
  void saveBestResources(List<DomainTrackerResourceHealthyResult> results);
}
