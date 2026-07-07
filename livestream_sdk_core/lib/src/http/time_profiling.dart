import 'package:dio/dio.dart';

/// `RequestOptions.extra` keys for time profiling.
///
/// ⚠️ Deliberately identical to packages/core's `RequestOptionExtraKeys` so
/// that a Dio client already carrying core's TimeProfilingInterceptor (e.g.
/// `HttpEngine.instance.domainTrackerClient`) interoperates with this
/// package's [Health] readers — keep them in sync.
class TimeProfilingExtraKeys {
  static const String timeProfilingEnable = 'timeProfilingEnable';
  static const String stopwatch = 'stopwatch';
  static const String rtt = 'rtt';
  static const String ttfb = 'ttfb'; // Time To First Byte
}

extension TimeProfilingRequestOptionsX on RequestOptions {
  bool get timeProfilingEnable =>
      (extra[TimeProfilingExtraKeys.timeProfilingEnable] as bool?) ?? false;

  set timeProfilingEnable(bool value) =>
      extra[TimeProfilingExtraKeys.timeProfilingEnable] = value;

  Stopwatch? get stopwatch =>
      extra[TimeProfilingExtraKeys.stopwatch] as Stopwatch?;

  set stopwatch(Stopwatch? value) =>
      extra[TimeProfilingExtraKeys.stopwatch] = value;

  Duration? get rtt => extra[TimeProfilingExtraKeys.rtt] as Duration?;

  set rtt(Duration? value) => extra[TimeProfilingExtraKeys.rtt] = value;

  Duration? get ttfb => extra[TimeProfilingExtraKeys.ttfb] as Duration?;

  set ttfb(Duration? value) => extra[TimeProfilingExtraKeys.ttfb] = value;
}

/// Measures rtt (full round trip) and ttfb (first byte) for requests with
/// [TimeProfilingRequestOptionsX.timeProfilingEnable] set. Port of
/// packages/core's TimeProfilingInterceptor — behavior unchanged.
class TimeProfilingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.timeProfilingEnable) {
      options.stopwatch = Stopwatch()..start();

      // Wrap onReceiveProgress to capture TTFB
      final originalCallback = options.onReceiveProgress;
      if (originalCallback != null) {
        options.onReceiveProgress = (count, total) {
          // Capture TTFB when first byte arrives
          if (options.ttfb == null && count > 0) {
            options.ttfb = options.stopwatch?.elapsed;
          }
          // Call original callback
          originalCallback(count, total);
        };
      } else {
        // Even without callback, capture TTFB
        options.onReceiveProgress = (count, total) {
          if (options.ttfb == null && count > 0) {
            options.ttfb = options.stopwatch?.elapsed;
          }
        };
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final stopwatch = err.requestOptions.stopwatch;
    if (stopwatch != null) {
      err.requestOptions.rtt = stopwatch.elapsed;
      stopwatch.stop();
    }
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final stopwatch = response.requestOptions.stopwatch;
    if (stopwatch != null) {
      response.requestOptions.rtt = stopwatch.elapsed;
      stopwatch.stop();
    }
    super.onResponse(response, handler);
  }
}
