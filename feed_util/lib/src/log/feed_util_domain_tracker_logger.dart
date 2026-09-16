import 'package:livestream_sdk_core/livestream_sdk_core.dart' as sdk_core;

import '../diagnostics/feed_util_diagnostics.dart';

/// Adapts the core's human-readable logger onto sanitized typed events.
///
/// `livestream_sdk_core` has no logging dependency (minimal-dependency policy),
/// so its domain-tracker pipeline emits through the abstract port and defaults
/// to [sdk_core.NoopDomainTrackerLogger] — silently dropping every stage log.
/// The core messages can contain hosts, URLs, response headers, remote config,
/// and exception strings. This adapter only recognizes fixed message prefixes
/// and discards the original message, error, and context in every case.
final class FeedUtilDomainTrackerLogger
    implements sdk_core.DomainTrackerLogger {
  FeedUtilDomainTrackerLogger(this._diagnostics);

  final FeedUtilDiagnostics _diagnostics;
  int _sequence = 0;

  @override
  void debug(String message, {Object? error, Map<String, dynamic>? context}) {
    _diagnostics.domainTrackerSignal(_classify(message), sequence: ++_sequence);
  }

  @override
  void warning(String message, {Object? error, Map<String, dynamic>? context}) {
    _diagnostics.domainTrackerSignal(_classify(message), sequence: ++_sequence);
  }

  static FeedUtilDomainTrackerSignal _classify(String message) =>
      switch (message) {
        _ when message.startsWith('Found healthy config server:') =>
          FeedUtilDomainTrackerSignal.configCandidateHealthy,
        _ when message.startsWith('Failed to check health of config server:') =>
          FeedUtilDomainTrackerSignal.configCandidateFailed,
        _ when message.startsWith('Selected healthy config server:') =>
          FeedUtilDomainTrackerSignal.configSelected,
        _ when message.startsWith('After all health checks') =>
          FeedUtilDomainTrackerSignal.configExhausted,
        _ when message.startsWith('Measure RTT success') =>
          FeedUtilDomainTrackerSignal.resourceProbeSucceeded,
        _ when message.startsWith('Measure RTT for') =>
          FeedUtilDomainTrackerSignal.resourceProbeFailed,
        _
            when message.startsWith(
              'Failed to update domain tracker resource status',
            ) =>
          FeedUtilDomainTrackerSignal.resourceStatusUpdateFailed,
        _ when message.startsWith('Failed to get resource list') =>
          FeedUtilDomainTrackerSignal.resourceListFailed,
        _ when message.startsWith('Best [') =>
          FeedUtilDomainTrackerSignal.resourcesEvaluated,
        _ when message.startsWith('Remote config overrides:') =>
          FeedUtilDomainTrackerSignal.remoteConfigEvaluated,
        _ => FeedUtilDomainTrackerSignal.unknown,
      };
}
