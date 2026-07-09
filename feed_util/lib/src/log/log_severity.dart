/// Severity of a [LogEntry] emitted by the SDK for integrator debugging.
///
/// Ordered least → most severe. The [name] doubles as the wire value that
/// crosses the `feed_util/method` channel to the native `FeedUtil` facades,
/// where it maps to the matching `LogSeverity` case.
enum LogSeverity {
  verbose,
  debug,
  info,
  warning,
  error;

  /// Value sent across the MethodChannel (the enum name, e.g. `"warning"`).
  String get wireName => name;

  /// Parses a wire value produced by [wireName]. An unknown or `null` value
  /// falls back to [LogSeverity.info] rather than throwing, so a future
  /// severity added on one side never crashes the other.
  static LogSeverity fromWire(String? value) {
    for (final severity in LogSeverity.values) {
      if (severity.name == value) return severity;
    }
    return LogSeverity.info;
  }
}
