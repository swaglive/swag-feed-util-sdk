import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Bounds silence *inside* a response body.
///
/// Dio's `receiveTimeout` only covers the wait for response headers (see
/// `IOHttpClientAdapter`: the timeout wraps the headers future, not the body
/// stream). A server that sends headers — or headers plus a first chunk — and
/// then goes quiet is therefore never interrupted. This decorator applies the
/// request's `receiveTimeout` to the body as a per-chunk gap: the clock resets
/// on every chunk, so a slow but flowing download is never cut, only a stall.
class BodyStallTimeoutAdapter implements HttpClientAdapter {
  BodyStallTimeoutAdapter(this.inner);

  /// The adapter that performs the actual request.
  final HttpClientAdapter inner;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = await inner.fetch(options, requestStream, cancelFuture);
    final gap = options.receiveTimeout;
    if (gap == null || gap <= Duration.zero) return body;

    return ResponseBody(
      body.stream.timeout(
        gap,
        onTimeout: (sink) {
          sink.addError(
            DioException.receiveTimeout(timeout: gap, requestOptions: options),
          );
          sink.close();
        },
      ),
      body.statusCode,
      statusMessage: body.statusMessage,
      isRedirect: body.isRedirect,
      redirects: body.redirects,
      headers: body.headers,
    );
  }

  @override
  void close({bool force = false}) => inner.close(force: force);
}
