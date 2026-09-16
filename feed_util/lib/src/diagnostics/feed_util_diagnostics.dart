import 'package:flutter/foundation.dart';

import '../log/web_view_log_event.dart';

/// Version of the stable diagnostic event schema.
const int feedUtilDiagnosticSchemaVersion = 1;

/// SDK version reported in diagnostic events.
const String feedUtilSdkVersion = '1.0.0';

/// Severity used only by the package-internal console adapters.
enum FeedUtilDiagnosticLevel {
  debug,
  info,
  warning,
  error;

  String get wireName => name;
}

/// Platform whose console receives a diagnostic event.
enum FeedUtilDiagnosticPlatform {
  flutter,
  android,
  ios;

  static FeedUtilDiagnosticPlatform fromWire(String? value) => switch (value) {
    'android' => android,
    'ios' => ios,
    _ => flutter,
  };
}

/// Safe failure categories. Never append an exception message to these.
enum FeedUtilDiagnosticError {
  invalidArgument,
  illegalState,
  domainUnreachable,
  networkTimeout,
  networkFailure,
  badResponse,
  decryptionFailure,
  internalFailure;

  String get wireName => switch (this) {
    invalidArgument => 'invalid_argument',
    illegalState => 'illegal_state',
    domainUnreachable => 'domain_unreachable',
    networkTimeout => 'network_timeout',
    networkFailure => 'network_failure',
    badResponse => 'bad_response',
    decryptionFailure => 'decryption_failure',
    internalFailure => 'internal_failure',
  };
}

/// Safe signals adapted from the core domain tracker.
///
/// The core logger currently supplies human-readable messages containing
/// hosts, URLs, headers, and errors. The adapter classifies those messages but
/// deliberately never forwards or interpolates them.
enum FeedUtilDomainTrackerSignal {
  configCandidateHealthy,
  configCandidateFailed,
  configSelected,
  configExhausted,
  resourceProbeSucceeded,
  resourceProbeFailed,
  resourceStatusUpdateFailed,
  resourceListFailed,
  resourcesEvaluated,
  remoteConfigEvaluated,
  unknown;

  String get wireName => switch (this) {
    configCandidateHealthy => 'config_candidate_healthy',
    configCandidateFailed => 'config_candidate_failed',
    configSelected => 'config_selected',
    configExhausted => 'config_exhausted',
    resourceProbeSucceeded => 'resource_probe_succeeded',
    resourceProbeFailed => 'resource_probe_failed',
    resourceStatusUpdateFailed => 'resource_status_update_failed',
    resourceListFailed => 'resource_list_failed',
    resourcesEvaluated => 'resources_evaluated',
    remoteConfigEvaluated => 'remote_config_evaluated',
    unknown => 'unknown',
  };
}

enum FeedUtilCoverOutcome {
  success,
  notFound,
  unavailable,
  empty;

  String get wireName => switch (this) {
    success => 'success',
    notFound => 'not_found',
    unavailable => 'unavailable',
    empty => 'empty',
  };
}

/// Package-internal output seam used by the native bridge.
///
/// It is intentionally absent from the public [LivestreamSdk] API. Flutter
/// consumers use the default [debugPrint] adapter; native facades receive the
/// same already-sanitized line over their private method channel.
typedef FeedUtilDiagnosticOutput =
    void Function(FeedUtilDiagnosticLevel level, String line);

/// Opaque, per-instance operation identifier and monotonic timer.
final class FeedUtilDiagnosticTrace {
  FeedUtilDiagnosticTrace._(this.id) : _stopwatch = Stopwatch()..start();

  final String id;
  final Stopwatch _stopwatch;

  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;
}

/// Instance-scoped, allowlist-only diagnostics.
///
/// Every public method below accepts only booleans, integers, or package-owned
/// enums. The sole map/string formatter is private, so a call site cannot
/// accidentally forward a URL, token, response body, identifier, exception,
/// or arbitrary `toString()` output.
final class FeedUtilDiagnostics {
  FeedUtilDiagnostics({
    required this.enabled,
    required this.platform,
    FeedUtilDiagnosticOutput? output,
  }) : _output = output ?? _debugPrintOutput,
       _session = 's${++_nextSessionId}';

  static const _rateLimitWindow = Duration(minutes: 1);
  static const _rateLimitBurst = 10;
  static int _nextSessionId = 0;

  final bool enabled;
  final FeedUtilDiagnosticPlatform platform;
  final FeedUtilDiagnosticOutput _output;
  final String _session;
  final Map<String, _RateLimitState> _rateLimits = {};
  int _nextTraceId = 0;

  FeedUtilDiagnosticTrace startTrace() =>
      FeedUtilDiagnosticTrace._('t${++_nextTraceId}');

  void configured({required int trackerServers, required int trackerLabels}) {
    _emit(
      FeedUtilDiagnosticLevel.info,
      'sdk.configured',
      fields: {
        'trackerServers': trackerServers,
        'trackerLabels': trackerLabels,
      },
    );
  }

  void domainResolveStarted(
    FeedUtilDiagnosticTrace trace, {
    required int candidates,
  }) {
    _emit(
      FeedUtilDiagnosticLevel.info,
      'domain.resolve.started',
      trace: trace,
      fields: {'candidates': candidates},
    );
  }

  void domainResolveCompleted(
    FeedUtilDiagnosticTrace trace, {
    required int resourceCount,
    required bool frontendChanged,
  }) {
    _emit(
      FeedUtilDiagnosticLevel.info,
      'domain.resolve.completed',
      trace: trace,
      fields: {
        'outcome': 'success',
        'durationMs': trace.elapsedMilliseconds,
        'resourceCount': resourceCount,
        'frontendChanged': frontendChanged,
      },
    );
  }

  void domainResolveFailed(
    FeedUtilDiagnosticTrace trace,
    FeedUtilDiagnosticError error,
  ) {
    _emit(
      FeedUtilDiagnosticLevel.error,
      'domain.resolve.failed',
      trace: trace,
      fields: {
        'outcome': 'failure',
        'durationMs': trace.elapsedMilliseconds,
        'error': error.wireName,
      },
    );
  }

  void domainTrackerSignal(
    FeedUtilDomainTrackerSignal signal, {
    required int sequence,
  }) {
    final level = switch (signal) {
      FeedUtilDomainTrackerSignal.configCandidateFailed ||
      FeedUtilDomainTrackerSignal.configExhausted ||
      FeedUtilDomainTrackerSignal.resourceProbeFailed ||
      FeedUtilDomainTrackerSignal.resourceStatusUpdateFailed ||
      FeedUtilDomainTrackerSignal.resourceListFailed =>
        FeedUtilDiagnosticLevel.warning,
      _ => FeedUtilDiagnosticLevel.debug,
    };
    _emit(
      level,
      'domain.tracker.signal',
      fields: {'signal': signal.wireName, 'sequence': sequence},
      rateLimitKey: signal.wireName,
    );
  }

  void encryptionConfigApplied({required int keyCount}) {
    _emit(
      FeedUtilDiagnosticLevel.info,
      'encryption.config.applied',
      fields: {'keyCount': keyCount},
    );
  }

  void encryptionConfigIgnored() {
    _emit(
      FeedUtilDiagnosticLevel.warning,
      'encryption.config.ignored',
      fields: const {'reason': 'invalid_format'},
    );
  }

  void feedFetchStarted(
    FeedUtilDiagnosticTrace trace, {
    required int page,
    required bool bustCache,
  }) {
    _emit(
      FeedUtilDiagnosticLevel.info,
      'feed.fetch.started',
      trace: trace,
      fields: {'page': page, 'bustCache': bustCache},
    );
  }

  void feedResponseObserved({
    required bool schedules,
    required int? statusCode,
    required int itemCount,
  }) {
    _emit(
      FeedUtilDiagnosticLevel.debug,
      'feed.response.observed',
      fields: {
        'stage': schedules ? 'schedules' : 'feed',
        'status': statusCode ?? 0,
        'itemCount': itemCount,
      },
      rateLimitKey: schedules ? 'schedules' : 'feed',
    );
  }

  void feedEnrichmentWarning() {
    _emit(
      FeedUtilDiagnosticLevel.warning,
      'feed.enrichment.warning',
      fields: const {'error': 'network_failure'},
      rateLimitKey: 'network_failure',
    );
  }

  void feedFetchCompleted(
    FeedUtilDiagnosticTrace trace, {
    required int itemCount,
    required int filteredCount,
  }) {
    _emit(
      FeedUtilDiagnosticLevel.info,
      'feed.fetch.completed',
      trace: trace,
      fields: {
        'outcome': 'success',
        'durationMs': trace.elapsedMilliseconds,
        'itemCount': itemCount,
        'filteredCount': filteredCount,
      },
    );
  }

  void feedFetchFailed(
    FeedUtilDiagnosticTrace trace,
    FeedUtilDiagnosticError error,
  ) {
    _emit(
      FeedUtilDiagnosticLevel.error,
      'feed.fetch.failed',
      trace: trace,
      fields: {
        'outcome': 'failure',
        'durationMs': trace.elapsedMilliseconds,
        'error': error.wireName,
      },
    );
  }

  void coverFetchStarted(FeedUtilDiagnosticTrace trace) {
    _emit(
      FeedUtilDiagnosticLevel.debug,
      'cover.fetch.started',
      trace: trace,
      rateLimitKey: 'started',
    );
  }

  void coverFetchCompleted(
    FeedUtilDiagnosticTrace trace, {
    required FeedUtilCoverOutcome outcome,
  }) {
    _emit(
      FeedUtilDiagnosticLevel.debug,
      'cover.fetch.completed',
      trace: trace,
      fields: {
        'outcome': outcome.wireName,
        'durationMs': trace.elapsedMilliseconds,
      },
      rateLimitKey: outcome.wireName,
    );
  }

  void coverFetchFailed(
    FeedUtilDiagnosticTrace trace,
    FeedUtilDiagnosticError error,
  ) {
    _emit(
      FeedUtilDiagnosticLevel.error,
      'cover.fetch.failed',
      trace: trace,
      fields: {
        'outcome': 'failure',
        'durationMs': trace.elapsedMilliseconds,
        'error': error.wireName,
      },
      rateLimitKey: error.wireName,
    );
  }

  void livestreamUrlBuilt({required bool usedCachedUsername}) {
    _emit(
      usedCachedUsername
          ? FeedUtilDiagnosticLevel.info
          : FeedUtilDiagnosticLevel.warning,
      'livestream.url.built',
      fields: {
        'outcome': 'success',
        'usernameCache': usedCachedUsername ? 'hit' : 'miss',
        'otp': 'present',
      },
    );
  }

  void livestreamUrlFailed(FeedUtilDiagnosticError error) {
    _emit(
      FeedUtilDiagnosticLevel.error,
      'livestream.url.failed',
      fields: {'outcome': 'failure', 'error': error.wireName},
    );
  }

  void webViewLifecycle({
    required bool started,
    required bool? isForMainFrame,
  }) {
    _emit(
      FeedUtilDiagnosticLevel.info,
      started ? 'webview.page.started' : 'webview.page.finished',
      fields: {'frame': _frame(isForMainFrame)},
      rateLimitKey:
          '${started ? 'started' : 'finished'}-${_frame(isForMainFrame)}',
    );
  }

  void webViewHttpError({
    required int? statusCode,
    required bool? isForMainFrame,
  }) {
    final status = statusCode ?? 0;
    _emit(
      status >= 500
          ? FeedUtilDiagnosticLevel.error
          : FeedUtilDiagnosticLevel.warning,
      'webview.http.failed',
      fields: {'status': status, 'frame': _frame(isForMainFrame)},
      rateLimitKey: '$status-${_frame(isForMainFrame)}',
    );
  }

  void webViewNetworkError({
    required WebViewNetworkErrorType category,
    required int? errorCode,
    required bool? isForMainFrame,
  }) {
    _emit(
      FeedUtilDiagnosticLevel.error,
      'webview.network.failed',
      fields: {
        'category': category.name,
        'code': errorCode ?? 0,
        'frame': _frame(isForMainFrame),
      },
      rateLimitKey: '${category.name}-${_frame(isForMainFrame)}',
    );
  }

  void _emit(
    FeedUtilDiagnosticLevel level,
    String event, {
    FeedUtilDiagnosticTrace? trace,
    Map<String, Object> fields = const {},
    String? rateLimitKey,
  }) {
    if (!enabled) return;
    if (rateLimitKey != null && !_shouldEmit(event, rateLimitKey)) return;

    final buffer = StringBuffer('[FeedUtil][${level.name.toUpperCase()}]')
      ..write(' schemaVersion=$feedUtilDiagnosticSchemaVersion')
      ..write(' sdkVersion=$feedUtilSdkVersion')
      ..write(' platform=${platform.name}')
      ..write(' session=$_session')
      ..write(' event=$event');
    if (trace != null) buffer.write(' trace=${trace.id}');
    for (final entry in fields.entries) {
      buffer.write(' ${entry.key}=${entry.value}');
    }
    _output(level, buffer.toString());
  }

  bool _shouldEmit(String event, String bucket) {
    final now = DateTime.now();
    final key = '$event|$bucket';
    final previous = _rateLimits[key];
    if (previous == null ||
        now.difference(previous.startedAt) >= _rateLimitWindow) {
      if (previous != null && previous.suppressed > 0) {
        _emitSuppressed(event, previous.suppressed);
      }
      _rateLimits[key] = _RateLimitState(now, emitted: 1);
      return true;
    }
    if (previous.emitted < _rateLimitBurst) {
      previous.emitted++;
      return true;
    }
    previous.suppressed++;
    if (previous.suppressed == 1) {
      _emitSuppressed(event, previous.suppressed);
    }
    return false;
  }

  void _emitSuppressed(String source, int count) {
    final buffer = StringBuffer('[FeedUtil][WARNING]')
      ..write(' schemaVersion=$feedUtilDiagnosticSchemaVersion')
      ..write(' sdkVersion=$feedUtilSdkVersion')
      ..write(' platform=${platform.name}')
      ..write(' session=$_session')
      ..write(' event=diagnostics.suppressed')
      ..write(' source=$source')
      ..write(' count=$count');
    _output(FeedUtilDiagnosticLevel.warning, buffer.toString());
  }

  static String _frame(bool? value) => switch (value) {
    true => 'main',
    false => 'subresource',
    null => 'unknown',
  };

  static void _debugPrintOutput(FeedUtilDiagnosticLevel _, String line) {
    debugPrint(line);
  }
}

final class _RateLimitState {
  _RateLimitState(this.startedAt, {required this.emitted});

  final DateTime startedAt;
  int emitted;
  int suppressed = 0;
}
