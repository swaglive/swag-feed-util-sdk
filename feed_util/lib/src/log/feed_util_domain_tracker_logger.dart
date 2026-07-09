import 'package:livestream_sdk_core/livestream_sdk_core.dart' as sdk_core;

import 'feed_util_log.dart';

/// Adapts the pure-Dart core [sdk_core.DomainTrackerLogger] port onto the
/// SDK-wide [FeedUtilLog] fan-out.
///
/// `livestream_sdk_core` has no logging dependency (minimal-dependency policy),
/// so its domain-tracker pipeline emits through the abstract port and defaults
/// to [sdk_core.NoopDomainTrackerLogger] — silently dropping every stage log.
/// Passing this adapter into `DomainTracker` instead surfaces those stages
/// (config-server health race, per-resource latency measurement, best-resource
/// selection, remote-config overrides, and their warnings) to the same Dart /
/// native sinks every other FeedUtil log flows through.
///
/// The port only distinguishes `debug` and `warning`; both carry an optional
/// [error] and structured [context]. [LogEntry] is a flat `severity + message`,
/// so both are folded into the message here rather than lost.
final class FeedUtilDomainTrackerLogger
    implements sdk_core.DomainTrackerLogger {
  const FeedUtilDomainTrackerLogger();

  @override
  void debug(String message, {Object? error, Map<String, dynamic>? context}) {
    FeedUtilLog.instance.debug(
      _format(message, error: error, context: context),
    );
  }

  @override
  void warning(String message, {Object? error, Map<String, dynamic>? context}) {
    FeedUtilLog.instance.warning(
      _format(message, error: error, context: context),
    );
  }

  /// Folds the structured [context] and [error] into the flat log message so no
  /// diagnostic detail is lost across the `severity + message` [LogEntry].
  static String _format(
    String message, {
    Object? error,
    Map<String, dynamic>? context,
  }) {
    final buffer = StringBuffer('[DomainTracker] $message');
    if (context != null && context.isNotEmpty) {
      buffer.write(' | context=$context');
    }
    if (error != null) {
      buffer.write(' | error=$error');
    }
    return buffer.toString();
  }
}
