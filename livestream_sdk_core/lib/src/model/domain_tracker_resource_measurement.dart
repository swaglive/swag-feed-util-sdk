import 'package:freezed_annotation/freezed_annotation.dart';

part 'domain_tracker_resource_measurement.freezed.dart';

@freezed
abstract class DomainTrackerResourceMeasurement
    with _$DomainTrackerResourceMeasurement {
  const factory DomainTrackerResourceMeasurement({
    required Uri uri,
    required bool isHealthy,
    Duration? rtt,
    String? eoLogUuid,
    String? eoCacheStatus,
    String? debugMessage,
    int? receivedBytes,
    @Default(false) bool fullyDownloaded,
  }) = _DomainTrackerResourceMeasurement;
}
