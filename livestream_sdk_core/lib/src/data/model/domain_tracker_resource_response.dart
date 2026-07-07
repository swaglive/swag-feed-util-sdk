import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_converter/duration_converter.dart';

part 'domain_tracker_resource_response.freezed.dart';
part 'domain_tracker_resource_response.g.dart';

@freezed
abstract class DomainTrackerResourceResponse
    with _$DomainTrackerResourceResponse {
  const factory DomainTrackerResourceResponse({
    String? type,
    String? url,

    /// Path to check the health of the resource
    @JsonKey(name: 'health_check_path') String? healthCheckPath,

    /// HTTP method to check the health of the resource
    @JsonKey(name: 'health_check_method') String? healthCheckMethod,

    /// Priority of the resource, 0 is the highest priority
    int? priority,

    /// Availability score (percentage), between 0 and 100
    int? score,

    /// When the resource was last checked
    @JsonKey(name: 'last_checked') DateTime? lastChecked,

    /// When the resource was created
    DateTime? createdAt,

    /// Metadata of the resource
    DomainTrackerResourceMetadataResponse? metadata,
  }) = _DomainTrackerResourceResponse;

  factory DomainTrackerResourceResponse.fromJson(Map<String, dynamic> json) =>
      _$DomainTrackerResourceResponseFromJson(json);
}

@freezed
abstract class DomainTrackerResourceMetadataResponse
    with _$DomainTrackerResourceMetadataResponse {
  const factory DomainTrackerResourceMetadataResponse({
    /// Whether to skip the health check for this resource
    @JsonKey(name: 'skip_health_check') bool? skipHealthCheck,

    /// Remote configs which needs to be overrided for this resource
    @JsonKey(name: 'remote_config_overrides')
    Map<String, String>? remoteConfigOverrides,

    /// Configs for how to do the health check
    @JsonKey(name: 'health_check_config')
    DomainTrackerResourceHealthCheckConfigResponse? healthCheckConfig,
  }) = _DomainTrackerResourceMetadataResponse;

  factory DomainTrackerResourceMetadataResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$DomainTrackerResourceMetadataResponseFromJson(json);
}

@freezed
abstract class DomainTrackerResourceHealthCheckConfigResponse
    with _$DomainTrackerResourceHealthCheckConfigResponse {
  const factory DomainTrackerResourceHealthCheckConfigResponse({
    int? range,
    @MillisecondsToDurationConverter() Duration? duration,
  }) = _DomainTrackerResourceHealthCheckConfigResponse;

  factory DomainTrackerResourceHealthCheckConfigResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$DomainTrackerResourceHealthCheckConfigResponseFromJson(json);
}
