import 'log_severity.dart';

/// A single diagnostic log record surfaced to the integrator's log callback.
///
/// Deliberately minimal — a [severity] and a human-readable [message] — so it
/// serializes cleanly across the `feed_util/method` MethodChannel to the
/// native `FeedUtil` facades (`FeedUtil.kt` / `FeedUtil.swift`).
class LogEntry {
  const LogEntry({required this.severity, required this.message});

  final LogSeverity severity;
  final String message;

  /// Wire form pushed to the native side.
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
