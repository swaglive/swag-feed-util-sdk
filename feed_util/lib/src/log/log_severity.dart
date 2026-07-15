/// Severity of a [LogEntry], ordered least → most severe. Use it to filter
/// how much SDK output reaches your logs (e.g. keep `warning`/`error` in
/// production, everything while debugging).
enum LogSeverity {
  verbose,
  debug,
  info,
  warning,
  error;

  /// Internal wire value used by the SDK's native bridge (the enum name).
  String get wireName => name;

  /// Internal: parses a [wireName] value. An unknown or `null` value falls
  /// back to [LogSeverity.info] rather than throwing, so a future severity
  /// added on one side never crashes the other.
  static LogSeverity fromWire(String? value) {
    for (final severity in LogSeverity.values) {
      if (severity.name == value) return severity;
    }
    return LogSeverity.info;
  }
}
