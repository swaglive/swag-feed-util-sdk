import 'package:freezed_annotation/freezed_annotation.dart';

part 'domain_tracker_resource.freezed.dart';

enum ResourceStatus { available, unavailable }

@freezed
abstract class DomainTrackerResource with _$DomainTrackerResource {
  const DomainTrackerResource._();

  const factory DomainTrackerResource({
    /// The type of the resource
    required String type,

    /// The URI of the resource
    required Uri uri,

    /// Path to check the health of the resource
    required String healthCheckPath,

    /// HTTP method to check the health of the resource
    required String healthCheckMethod,

    /// Priority of the resource, 0 is the highest priority
    required int priority,

    /// The score of the resource
    required int score,

    /// When the resource was last checked
    DateTime? lastChecked,

    /// When the resource was created
    DateTime? createdAt,

    /// Metadata of the resource
    DomainTrackerResourceMetadata? metadata,
  }) = _DomainTrackerResource;

  Uri get healthCheckUri => uri.replace(path: healthCheckPath);
}

@freezed
abstract class DomainTrackerResourceMetadata
    with _$DomainTrackerResourceMetadata {
  const factory DomainTrackerResourceMetadata({
    bool? skipHealthCheck,
    Map<String, String>? remoteConfigOverrides,
    DomainTrackerResourceHealthCheckConfig? healthCheckConfig,
  }) = _DomainTrackerResourceMetadata;
}

@freezed
abstract class DomainTrackerResourceHealthCheckConfig
    with _$DomainTrackerResourceHealthCheckConfig {
  const factory DomainTrackerResourceHealthCheckConfig({
    int? rangeInBytes,
    Duration? measureDuration,
  }) = _DomainTrackerResourceHealthCheckConfig;
}
