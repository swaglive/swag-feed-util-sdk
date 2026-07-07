import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../http/time_profiling.dart';
import '../model/domain_tracker_resource.dart';
import '../repository/domain_tracker_repository.dart';
import 'mapper/domain_tracker_resource_mapper.dart';
import 'model/domain_tracker_resource_response.dart';

/// Plain-Dio [DomainTrackerRepository] for consumers without packages/core
/// (feed_util). Endpoint paths, health semantics, and error messages mirror
/// webview-user-app's ApiDomainTrackerRepository — the injected [httpClient]
/// must carry [TimeProfilingInterceptor] (rtt/ttfb depend on it) and the
/// tracker auth interceptor.
final class DioDomainTrackerRepository implements DomainTrackerRepository {
  DioDomainTrackerRepository({required this.host, required Dio httpClient})
    : _http = httpClient;

  final String host;
  final Dio _http;

  static const _eoLogUuidHeader = 'EO-LOG-UUID';
  static const _eoCacheStatusHeader = 'EO-CACHE-STATUS';

  /// First value of a (case-insensitive) response header, `null` when absent.
  static String? _firstHeaderValue(Headers? headers, String name) {
    final values = headers?[name];
    return (values == null || values.isEmpty) ? null : values.first;
  }

  String _url(String path, [Map<String, dynamic>? queryParameters]) {
    final query = <String, dynamic>{...?queryParameters}
      ..removeWhere((_, value) => value == null);
    return Uri(
      scheme: 'https',
      host: host,
      path: path,
      queryParameters: query.isEmpty ? null : query,
    ).toString();
  }

  @override
  Future<Health> checkHealth() {
    final options = RequestOptions(path: _url('/health'))
      ..timeProfilingEnable = true;
    return _http
        .fetch(options)
        .then<Health>(
          (response) => (
            fullyDownloaded: true,
            requestHeaders: response.requestOptions.headers,
            responseHeaders: response.headers.map,
            rtt: response.requestOptions.rtt,
            ttfb: response.requestOptions.ttfb,
            eoLogUuid: null,
            eoCacheStatus: null,
            receivedBytes: null,
          ),
        )
        .catchError((Object e) {
          if (e is DioException) {
            throw Exception(
              'Server is not healthy (${e.response?.statusCode}) for $host, error: ${e.error}',
            );
          }
          throw Exception('Server health check error for $host, error: $e');
        });
  }

  @override
  Future<String?> echo() =>
      _http.fetch(RequestOptions(path: _url('/echo'))).then((response) {
        final data = response.data;
        return data is String ? data : jsonEncode(data);
      });

  @override
  Future<List<String>> getResourceTypes({List<String>? labels}) => _http
      .fetch(
        RequestOptions(
          path: _url('/resource-types', {
            if (labels != null && labels.isNotEmpty) 'labels': labels,
          }),
        ),
      )
      .then((response) {
        // Malformed payloads fall back to an empty list — mirrors
        // HttpRequestable's caught-deserializer-error → `?? <String>[]`
        // behavior in the app repository.
        try {
          return (response.data as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              <String>[];
        } catch (_) {
          return <String>[];
        }
      });

  @override
  Future<List<DomainTrackerResource>> getResourceList({
    int page = 1,
    int limit = 100,
    String? type,
    List<String>? labels,
    int? freshness,
  }) => _http
      .fetch(
        RequestOptions(
          path: _url('/resources', {
            'page': page.toString(),
            'limit': limit.toString(),
            'type': type,
            'freshness': freshness?.toString(),
            if (labels != null && labels.isNotEmpty) 'labels': labels,
          }),
        ),
      )
      .then((response) {
        final dynamic data = response.data;
        if (data is List) {
          return data
              .map(
                (element) => DomainTrackerResourceResponse.fromJson(
                  element,
                ).toDomainTrackerResource(),
              )
              .toList();
        }
        throw const FormatException(
          'getResourceList response format is not JSON array',
        );
      });

  @override
  Future<DomainTrackerResource> updateResourceStatus({
    required String url,
    required ResourceStatus status,
    Duration? rtt,
    Map<String, dynamic>? metadata,
  }) => _http
      .fetch(
        RequestOptions(
          path: _url('/resources/status'),
          method: 'PUT',
          data: {
            'url': url,
            'status': status.toRequestPayload(),
            if (rtt != null) 'rtt': rtt.inMilliseconds,
            if (metadata != null) 'metadata': metadata,
          },
        ),
      )
      .then(
        (response) => DomainTrackerResourceResponse.fromJson(
          response.data,
        ).toDomainTrackerResource(),
      );

  @override
  Future<Health> checkResourceHealth({
    required Uri uri,
    required String httpMethod,
    int? rangeInBytes,
    Duration? maxMeasureDuration,
  }) async {
    final requestCompleter = Completer<Health>();
    int receivedBytes = 0;
    Timer? timeoutTimer;
    CancelToken cancelToken = CancelToken();

    final options = RequestOptions(
      path: uri.toString(),
      method: httpMethod,
      headers: {if (rangeInBytes != null) 'Range': 'bytes=0-$rangeInBytes'},
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        receivedBytes = received;
      },
    )..timeProfilingEnable = true;

    _http
        .fetch(options)
        .then((response) {
          timeoutTimer?.cancel();

          final eoLogUuid = _firstHeaderValue(
            response.headers,
            _eoLogUuidHeader,
          );
          final eoCacheStatus = _firstHeaderValue(
            response.headers,
            _eoCacheStatusHeader,
          );

          /// 200: full response
          /// 206: partial response
          if (response.statusCode == 200 || response.statusCode == 206) {
            if (!requestCompleter.isCompleted) {
              requestCompleter.complete((
                fullyDownloaded: true,
                requestHeaders: response.requestOptions.headers,
                responseHeaders: response.headers.map,
                rtt: response.requestOptions.rtt,
                ttfb: response
                    .requestOptions
                    .ttfb, // From TimeProfilingInterceptor
                eoLogUuid: eoLogUuid,
                eoCacheStatus: eoCacheStatus,
                receivedBytes: receivedBytes,
              ));
            }
            return;
          }
          if (!requestCompleter.isCompleted) {
            requestCompleter.completeError(
              Exception(
                'Resource is not healthy (${response.statusCode}) for $uri, eoLogUuid: $eoLogUuid, eoCacheStatus: $eoCacheStatus',
              ),
            );
          }
        })
        .catchError((Object e) {
          timeoutTimer?.cancel();

          if (e is DioException) {
            final eoLogUuid = _firstHeaderValue(
              e.response?.headers,
              _eoLogUuidHeader,
            );
            final eoCacheStatus = _firstHeaderValue(
              e.response?.headers,
              _eoCacheStatusHeader,
            );
            if (!requestCompleter.isCompleted) {
              requestCompleter.completeError(
                Exception(
                  'Resource is not healthy (${e.response?.statusCode}) for $uri, eoLogUuid: $eoLogUuid, eoCacheStatus: $eoCacheStatus, error: ${e.error}',
                ),
              );
            }
            return;
          }
          if (!requestCompleter.isCompleted) {
            requestCompleter.completeError(
              Exception('Resource health check error for $uri, error: $e'),
            );
          }
        });

    if (maxMeasureDuration != null) {
      timeoutTimer = Timer(maxMeasureDuration, () {
        cancelToken.cancel();

        if (receivedBytes > 0) {
          if (!requestCompleter.isCompleted) {
            requestCompleter.complete((
              fullyDownloaded: false,
              requestHeaders: options.headers,
              responseHeaders: null,
              rtt: null,
              ttfb: null, // No TTFB for timeout case
              eoLogUuid: null,
              eoCacheStatus: null,
              receivedBytes: receivedBytes,
            ));
          }
        } else {
          if (!requestCompleter.isCompleted) {
            requestCompleter.completeError(
              Exception(
                'Resource is not healthy because it failed to download any data in the time limit',
              ),
            );
          }
        }
      });
    }

    return requestCompleter.future;
  }
}
