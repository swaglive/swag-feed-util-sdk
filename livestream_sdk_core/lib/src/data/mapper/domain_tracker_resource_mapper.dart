import '../../model/domain_tracker_resource.dart';
import '../model/domain_tracker_resource_response.dart';

extension DomainTrackerResourceResponseMapper on DomainTrackerResourceResponse {
  DomainTrackerResource toDomainTrackerResource() {
    final String? resourceType = type;
    if (resourceType == null) {
      throw const FormatException('Invalid resource type: null');
    }
    final String? resourceUrl = url;
    if (resourceUrl == null) {
      throw const FormatException('Invalid resource url: null');
    }
    final Uri? resourceUri = Uri.tryParse(resourceUrl);
    if (resourceUri == null) {
      throw FormatException('Cannot parse url to uri: $resourceUrl');
    }
    final String? healthCheckPath = this.healthCheckPath;
    if (healthCheckPath == null) {
      throw const FormatException('Invalid health check path: null');
    }
    final String? healthCheckMethod = this.healthCheckMethod;
    if (healthCheckMethod == null) {
      throw const FormatException('Invalid health check method: null');
    }
    final int priority = this.priority ?? 0;
    final int? score = this.score;
    if (score == null) {
      throw const FormatException('Invalid score: null');
    }
    final DomainTrackerResourceMetadataResponse? metadataResponse =
        this.metadata;
    DomainTrackerResourceMetadata? metadata;
    if (metadataResponse != null) {
      metadata = DomainTrackerResourceMetadata(
        skipHealthCheck: metadataResponse.skipHealthCheck,
        remoteConfigOverrides: metadataResponse.remoteConfigOverrides,
        healthCheckConfig: DomainTrackerResourceHealthCheckConfig(
          rangeInBytes: metadataResponse.healthCheckConfig?.range,
          measureDuration: metadataResponse.healthCheckConfig?.duration,
        ),
      );
    }
    return DomainTrackerResource(
      type: resourceType,
      uri: resourceUri,
      healthCheckPath: healthCheckPath,
      healthCheckMethod: healthCheckMethod,
      priority: priority,
      score: score,
      lastChecked: lastChecked,
      createdAt: createdAt,
      metadata: metadata,
    );
  }
}

extension ResourceStatusMapper on ResourceStatus {
  String toRequestPayload() => switch (this) {
    ResourceStatus.available => 'available',
    ResourceStatus.unavailable => 'unavailable',
  };
}
