import '../model/domain_tracker_resource_measurement.dart';

/// Debug/telemetry port for per-resource health-check measurements
/// (webview-user-app adapts this to its DomainTrackerDebugInfoManager).
abstract interface class DomainTrackerHealthReporter {
  void reportHealthy({
    required String resourceType,
    required List<DomainTrackerResourceMeasurement> measurements,
  });

  void reportUnhealthy({
    required String resourceType,
    required List<DomainTrackerResourceMeasurement> measurements,
  });
}

final class NoopDomainTrackerHealthReporter
    implements DomainTrackerHealthReporter {
  const NoopDomainTrackerHealthReporter();

  @override
  void reportHealthy({
    required String resourceType,
    required List<DomainTrackerResourceMeasurement> measurements,
  }) {}

  @override
  void reportUnhealthy({
    required String resourceType,
    required List<DomainTrackerResourceMeasurement> measurements,
  }) {}
}
