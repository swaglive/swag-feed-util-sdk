import 'dart:async';

import '../model/domain_tracker_resource.dart';
import '../model/domain_tracker_resource_measurement.dart';
import '../port/domain_tracker_logger.dart';
import '../repository/domain_tracker_repository.dart';

/// Provides the debug process id attached to status-update metadata
/// (webview-user-app supplies DomainTrackerDebugInfoManager.processId).
typedef DomainTrackerProcessIdProvider = String? Function();

/// Measures one resource's health (spec §04 step 3) and reports the outcome
/// back to the config server.
///
/// Extracted from webview-user-app — algorithm unchanged; logger/processId
/// come from the constructor instead of GetIt.
class MeasureDomainTrackerResourceUseCase {
  MeasureDomainTrackerResourceUseCase({
    DomainTrackerLogger logger = const NoopDomainTrackerLogger(),
    DomainTrackerProcessIdProvider? processIdProvider,
  }) : _logger = logger,
       _processIdProvider = processIdProvider;

  final DomainTrackerLogger _logger;
  final DomainTrackerProcessIdProvider? _processIdProvider;

  Future<DomainTrackerResourceMeasurement> call({
    required DomainTrackerRepository repository,
    required Uri uri,
    required Uri healthCheckUri,
    required String httpMethod,
    int? rangeInBytes,
    Duration? measureDuration,
  }) async {
    final String? processId = _processIdProvider?.call();
    bool isHealthy = false;
    Duration? rtt;
    Map<String, dynamic>? requestHeaders;
    Map<String, dynamic>? responseHeaders;
    try {
      final health = await repository.checkResourceHealth(
        uri: healthCheckUri,
        httpMethod: httpMethod,
        rangeInBytes: rangeInBytes,
        maxMeasureDuration: measureDuration,
      );
      isHealthy = true;
      rtt = health.rtt;
      requestHeaders = health.requestHeaders;
      responseHeaders = health.responseHeaders;
      _logger.debug(
        'Measure RTT success for [$healthCheckUri], rtt: ${health.rtt}, ttfb: ${health.ttfb}, eoLogUuid: ${health.eoLogUuid}, eoCacheStatus: ${health.eoCacheStatus}, receivedBytes: ${health.receivedBytes}',
        context: {'processId': processId, 'responseHeaders': responseHeaders},
      );
      return DomainTrackerResourceMeasurement(
        uri: uri,
        isHealthy: isHealthy,
        rtt: health.rtt,
        eoLogUuid: health.eoLogUuid,
        eoCacheStatus: health.eoCacheStatus,
        debugMessage:
            'Measure RTT success for [$healthCheckUri], rtt: ${health.rtt}, eoLogUuid: ${health.eoLogUuid}, eoCacheStatus: ${health.eoCacheStatus}, receivedBytes: ${health.receivedBytes}',
        receivedBytes: health.receivedBytes,
        fullyDownloaded: health.fullyDownloaded,
      );
    } catch (e) {
      _logger.debug(
        'Measure RTT for [$healthCheckUri] failed, $e',
        context: {'processId': processId},
      );
      return DomainTrackerResourceMeasurement(
        uri: uri,
        isHealthy: false,
        rtt: Duration.zero,
        eoLogUuid: null,
        eoCacheStatus: null,
        debugMessage: 'Measure RTT for [$healthCheckUri] failed, $e',
      );
    } finally {
      unawaited(
        repository
            .updateResourceStatus(
              url: uri.toString(),
              status: isHealthy
                  ? ResourceStatus.available
                  : ResourceStatus.unavailable,
              rtt: rtt,
              metadata: {
                'processId': processId,
                'httpMethod': httpMethod,
                'requestHeaders': requestHeaders,
                'responseHeaders': responseHeaders,
              },
            )
            .then<void>((_) {})
            .catchError((Object e) {
              _logger.debug(
                'Failed to update domain tracker resource status for [$uri]',
                error: e,
              );
            }),
      );
    }
  }
}
