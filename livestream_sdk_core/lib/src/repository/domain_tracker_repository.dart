import '../model/domain_tracker_resource.dart';

typedef Health = ({
  bool fullyDownloaded, // 是否在限制時間內完整下載了資料
  Map<String, dynamic>? requestHeaders,
  Map<String, dynamic>? responseHeaders,
  Duration? rtt,
  Duration? ttfb, // Time To First Byte (DNS+TCP+TLS+Server)
  String? eoLogUuid,
  String? eoCacheStatus,
  int? receivedBytes,
});

/// Creates a repository bound to one config-server [host].
///
/// The use cases race several config servers, so they take this factory
/// instead of a single repository instance.
typedef DomainTrackerRepositoryFactory =
    DomainTrackerRepository Function(String host);

abstract interface class DomainTrackerRepository {
  /// Check the health of the config server
  Future<Health> checkHealth();

  Future<String?> echo();

  /// Get the list of server resource types
  Future<List<String>> getResourceTypes({List<String>? labels});

  /// Get the list of server resources
  ///
  /// [page] - The page number (starts from 1)
  /// [limit] - The number of items per page
  /// [type] - The type of the server resource to filter by, null means no filter
  /// [freshness] - The freshness of the server resource to get in seconds
  Future<List<DomainTrackerResource>> getResourceList({
    int page = 1,
    int limit = 100,
    String? type,
    List<String>? labels,
    int? freshness,
  });

  /// Update the status of a server resource
  ///
  /// [url] - The url of the server resource
  /// [status] - The status of the server resource to update
  /// [rtt] - The rtt of the server resource to update
  /// [metadata] - The metadata of the server resource to update
  Future<DomainTrackerResource> updateResourceStatus({
    required String url,
    required ResourceStatus status,
    Duration? rtt,
    Map<String, dynamic>? metadata,
  });

  /// Check the health of a server resource
  ///
  /// [uri] - The uri of the server resource
  /// [maxMeasureDuration] - The maximum duration to download the data from the server resource
  /// if the downloading is not finished within the duration, return the current download bytes
  Future<Health> checkResourceHealth({
    required Uri uri,
    required String httpMethod,
    int? rangeInBytes,
    Duration? maxMeasureDuration,
  });
}
