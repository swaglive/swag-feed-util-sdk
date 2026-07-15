import 'log_severity.dart';

/// A diagnostic log record delivered to the listener you register with
/// `LivestreamSdk.setLogListener`: a [severity] plus a human-readable
/// [message]. Forward it to your app's logging while troubleshooting.
class LogEntry {
  const LogEntry({required this.severity, required this.message});

  final LogSeverity severity;
  final String message;

  /// Internal wire form used by the SDK's native bridge.
  Map<String, Object?> toMap() => {
    'severity': severity.wireName,
    'message': message,
  };

  /// Rebuilds a [LogEntry] from its [toMap] form.
  factory LogEntry.fromMap(Map<String, Object?> map) => LogEntry(
    severity: LogSeverity.fromWire(map['severity'] as String?),
    message: (map['message'] as String?) ?? '',
  );

  @override
  String toString() => '[${severity.name}] $message';
}
