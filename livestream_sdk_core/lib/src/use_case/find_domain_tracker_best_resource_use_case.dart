import 'dart:async';

import '../model/domain_tracker_resource.dart';
import '../model/domain_tracker_resource_measurement.dart';
import '../model/domain_tracker_resource_result.dart';
import '../port/domain_tracker_health_reporter.dart';
import '../repository/domain_tracker_repository.dart';
import 'measure_domain_tracker_resource_use_case.dart';

/// 找到最佳的 Domain Tracker Resource
///
/// Extracted from webview-user-app — algorithm unchanged; the measure use
/// case and health reporter come from the constructor instead of GetIt.
class FindDomainTrackerBestResourceUseCase {
  FindDomainTrackerBestResourceUseCase({
    required MeasureDomainTrackerResourceUseCase measureResourceUseCase,
    DomainTrackerHealthReporter healthReporter =
        const NoopDomainTrackerHealthReporter(),
  }) : _measureResourceUseCase = measureResourceUseCase,
       _healthReporter = healthReporter;

  final MeasureDomainTrackerResourceUseCase _measureResourceUseCase;
  final DomainTrackerHealthReporter _healthReporter;

  Future<DomainTrackerResourceResult> call({
    required String resourceType,
    required List<DomainTrackerResource> resources,
    required DomainTrackerRepository repository,
  }) async {
    // 如果資源可以跳過Health Check，則直接返回第一個資源
    final firstResource = resources.firstOrNull;
    if (firstResource != null &&
        firstResource.metadata?.skipHealthCheck == true) {
      return DomainTrackerResourceResult.healthy(
        resourceType: resourceType,
        resource: firstResource,
        measurement: null,
      );
    }

    final List<DomainTrackerResourceMeasurement> fullyDownloadedResults = [];
    final List<DomainTrackerResourceMeasurement> partiallyDownloadedResults =
        [];
    final List<DomainTrackerResourceMeasurement> unhealthyResults = [];
    final Completer<DomainTrackerResourceResult> completer = Completer();

    // 創建所有資源的測試任務
    final List<Future<void>> testTasks = resources.map<Future<void>>((
      resource,
    ) async {
      final measurement = await _measureResourceUseCase.call(
        repository: repository,
        uri: resource.uri,
        healthCheckUri: resource.healthCheckUri,
        httpMethod: resource.healthCheckMethod,
        rangeInBytes: resource.metadata?.healthCheckConfig?.rangeInBytes,
        measureDuration: resource.metadata?.healthCheckConfig?.measureDuration,
      );

      if (measurement.fullyDownloaded) {
        fullyDownloadedResults.add(measurement);

        // 一旦有一個 resource 完全下載，就直接使用該 resource
        if (!completer.isCompleted) {
          completer.complete(
            DomainTrackerResourceResult.healthy(
              resourceType: resourceType,
              resource: resource,
              measurement: measurement,
            ),
          );
        }
      } else if (measurement.receivedBytes != null &&
          measurement.receivedBytes! > 0) {
        partiallyDownloadedResults.add(measurement);
      } else {
        unhealthyResults.add(measurement);
      }
    }).toList();

    // 測試所有的 resource
    // 這邊的機制是希望在找到第一個健康的 resource 時，就立即返回該 resource
    // 但是所有 resource 還是都要測完，並把測試結果回傳給 onResourceHealthReport
    Future.wait<void>(testTasks).whenComplete(() {
      // 找到健康的資源
      // 根據條件排序選擇最佳資源：
      // 1. fullyDownloaded 的排在前面，fullyDownloaded array 裡的順序已經照回傳順序排好，所以不用再排序
      // 2. 不是 fullyDownloaded，按照 receivedBytes 排序，receivedBytes 越大越好
      final List<DomainTrackerResourceMeasurement> healthyResults = [
        ...fullyDownloadedResults,
        ...partiallyDownloadedResults..sort((a, b) {
          final aBytes = a.receivedBytes ?? 0;
          final bBytes = b.receivedBytes ?? 0;
          return bBytes.compareTo(aBytes); // receivedBytes 越大越好
        }),
      ];

      _reportResourceHealth(resourceType, healthyResults, unhealthyResults);

      // 找不到健康的資源
      if (healthyResults.isEmpty && !completer.isCompleted) {
        completer.complete(
          DomainTrackerResourceResult.unhealthy(resourceType: resourceType),
        );
        return;
      }

      final bestResult = healthyResults.first;

      // 根據 bestResource 的 URI 找到對應的原始 DomainTrackerResource
      final bestResource = resources.firstWhere(
        (resource) => resource.uri == bestResult.uri,
        orElse: () => resources.first, // 如果找不到對應的資源，使用第一個作為後備
      );

      if (!completer.isCompleted) {
        completer.complete(
          DomainTrackerResourceResult.healthy(
            resourceType: resourceType,
            resource: bestResource,
            measurement: bestResult,
          ),
        );
      }
    });

    return completer.future;
  }

  void _reportResourceHealth(
    String resourceType,
    List<DomainTrackerResourceMeasurement> healthyResults,
    List<DomainTrackerResourceMeasurement> unhealthyResults,
  ) {
    _healthReporter.reportHealthy(
      resourceType: resourceType,
      measurements: healthyResults,
    );

    /// 為了debug方便，會把失敗的uri append在splash page的message上
    _healthReporter.reportUnhealthy(
      resourceType: resourceType,
      measurements: unhealthyResults,
    );
  }
}
