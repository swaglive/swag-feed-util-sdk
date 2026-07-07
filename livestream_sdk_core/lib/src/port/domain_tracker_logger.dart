/// Logging port — the package has no log_kit/sentry dependency (feed_util
/// minimal-dependency policy). Apps adapt their own logger; the SDK default
/// is silent.
abstract interface class DomainTrackerLogger {
  void debug(String message, {Object? error, Map<String, dynamic>? context});

  void warning(String message, {Object? error, Map<String, dynamic>? context});
}

final class NoopDomainTrackerLogger implements DomainTrackerLogger {
  const NoopDomainTrackerLogger();

  @override
  void debug(String message, {Object? error, Map<String, dynamic>? context}) {}

  @override
  void warning(
    String message, {
    Object? error,
    Map<String, dynamic>? context,
  }) {}
}
