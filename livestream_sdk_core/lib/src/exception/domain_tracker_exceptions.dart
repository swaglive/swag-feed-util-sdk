/// Thrown when no config server responds (spec §04 step 1).
class DomainTrackerServerNotFoundException implements Exception {
  const DomainTrackerServerNotFoundException({this.message = '', this.servers});

  final String message;
  final List<Uri>? servers;

  @override
  String toString() => message;
}

/// Exception thrown when no healthy servers are found during server selection.
/// Contains information about the server type and attempted servers.
final class HealthyResourceNotFoundException implements Exception {
  const HealthyResourceNotFoundException({
    required this.code,
    this.message,
    this.resourceTypes,
  });

  final String code;
  final String? message;
  final List<String>? resourceTypes;

  static const String codeServerResourceNotFound = 'server-resources-not-found';
  static const String codeHealthyResourceNotFound =
      'healthy-resource-not-found';

  @override
  String toString() =>
      'No healthy servers found ($code), $message, $resourceTypes';
}
