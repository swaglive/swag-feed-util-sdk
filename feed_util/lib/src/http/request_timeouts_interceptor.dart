import 'package:dio/dio.dart';

/// Applies default connect / receive timeouts to every request that has none.
///
/// `BaseOptions` timeouts only reach requests built through `dio.get()` /
/// `dio.request()`; the SDK core issues its tracker and feed calls as bare
/// `RequestOptions` via `dio.fetch()`, which skips that merge. An interceptor
/// runs inside `fetch()`, so it is the one place that covers both paths.
/// Explicit per-request timeouts are left untouched.
class RequestTimeoutsInterceptor extends Interceptor {
  const RequestTimeoutsInterceptor({
    required this.connectTimeout,
    required this.receiveTimeout,
  });

  final Duration connectTimeout;
  final Duration receiveTimeout;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.connectTimeout ??= connectTimeout;
    options.receiveTimeout ??= receiveTimeout;
    handler.next(options);
  }
}
