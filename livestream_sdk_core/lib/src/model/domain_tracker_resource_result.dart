import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain_tracker_resource.dart';
import 'domain_tracker_resource_measurement.dart';

part 'domain_tracker_resource_result.freezed.dart';

@freezed
sealed class DomainTrackerResourceResult with _$DomainTrackerResourceResult {
  const factory DomainTrackerResourceResult.healthy({
    required String resourceType,
    required DomainTrackerResource resource,
    required DomainTrackerResourceMeasurement? measurement,
  }) = DomainTrackerResourceHealthyResult;

  const factory DomainTrackerResourceResult.unhealthy({
    required String resourceType,
  }) = DomainTrackerResourceUnhealthyResult;
}
