import 'log_entry.dart';
import 'log_severity.dart';

/// Callback invoked with each [LogEntry] the SDK emits.
typedef FeedUtilLogCallback = void Function(LogEntry entry);

/// Process-wide fan-out for the SDK's diagnostic logs.
///
/// This is the plumbing only: nothing inside the SDK emits through it yet —
/// individual internal call sites are wired up separately. Once they are, each
/// emitted [LogEntry] is delivered to two independent, optional sinks:
///
///  * a **Dart** callback, set by a Flutter host via
///    `LivestreamSdk.setLogListener` (for hosts that consume the Dart API
///    directly);
///  * the **native** bridge sink, bound by `FeedUtilChannel`, which forwards
///    every entry over `feed_util/method` to the native `FeedUtil` log callback
///    (for native Android/iOS integrators).
///
/// A singleton because both the native bridge and any Dart host share one
/// engine-wide log stream, mirroring the single native `FeedUtil` facade.
class FeedUtilLog {
  FeedUtilLog._();

  static final FeedUtilLog instance = FeedUtilLog._();

  FeedUtilLogCallback? _dartCallback;
  FeedUtilLogCallback? _nativeSink;

  /// Registers the Dart-host log callback. Pass `null` to clear it.
  void setCallback(FeedUtilLogCallback? callback) => _dartCallback = callback;

  /// Binds the sink that forwards entries to the native facade. Called by
  /// [FeedUtilChannel]; not part of the public API.
  void bindNativeSink(FeedUtilLogCallback? sink) => _nativeSink = sink;

  /// Emits [message] at [severity] to every registered sink.
  ///
  /// A no-op when no sink is registered (avoids building an entry no one
  /// receives). A throwing sink is isolated so one bad listener can't break
  /// delivery to the other sink or the calling code path.
  void emit(LogSeverity severity, String message) {
    if (_dartCallback == null && _nativeSink == null) return;
    final entry = LogEntry(severity: severity, message: message);
    _deliver(_dartCallback, entry);
    _deliver(_nativeSink, entry);
  }

  void verbose(String message) => emit(LogSeverity.verbose, message);
  void debug(String message) => emit(LogSeverity.debug, message);
  void info(String message) => emit(LogSeverity.info, message);
  void warning(String message) => emit(LogSeverity.warning, message);
  void error(String message) => emit(LogSeverity.error, message);

  static void _deliver(FeedUtilLogCallback? sink, LogEntry entry) {
    if (sink == null) return;
    try {
      sink(entry);
    } catch (_) {
      // A misbehaving listener must never break logging or the caller.
    }
  }
}
