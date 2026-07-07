import 'package:dio/dio.dart';

/// Attaches the tracker Bearer token — only toward config-server hosts.
///
/// Config-injected port of packages/core's DomainTrackerAuthInterceptor
/// (which reads EnvConfig via GetIt — not allowed in this package).
class DomainTrackerAuthInterceptor extends Interceptor {
  DomainTrackerAuthInterceptor({
    required Iterable<String> trackerHosts,
    required String? authToken,
  }) : _trackerHosts = trackerHosts.toSet(),
       _authToken = authToken;

  final Set<String> _trackerHosts;
  final String? _authToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _authToken;
    if (token != null &&
        token.isNotEmpty &&
        _trackerHosts.contains(options.uri.host)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
