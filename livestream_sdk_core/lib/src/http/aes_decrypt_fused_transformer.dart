import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/src/compute/compute.dart';
import 'package:dio/src/transformers/util/consolidate_bytes.dart';
import 'package:dio/src/transformers/util/transform_empty_to_null.dart';
import 'package:webcrypto/webcrypto.dart';

import 'http_header.dart';

/// A [Transformer] with a fast path for UTF8-encoded JSON that *also*
/// transparently AES-decrypts responses whose headers advertise encryption.
///
/// Config-injected port of packages/core's `AesDecryptFusedTransformer` for
/// consumers without get_it / remote_config_kit (feed_util). The decryption
/// pipeline (AES-CTR / AES-CBC via `package:webcrypto`, streaming) and the
/// fused [Utf8Decoder]+[JsonDecoder] fast path are byte-for-byte the same; the
/// only change is where the AES keys come from: an injected [encryptKeys] map
/// (defaulting to [defaultEncryptKeys]) instead of a `RemoteConfig` lookup.
///
/// "Decrypt if present": when a response carries no `X-Encrypted-*` headers, or
/// its key id is unknown, or decryption fails, the original (unmodified) body
/// flows through and is transformed exactly like the default transformer would.
/// Wiring this onto a Dio client therefore never changes the behavior of plain
/// (unencrypted) traffic — see `LivestreamSdkImpl`.
///
/// By default responses are transformed in the same isolate; set
/// [contentLengthIsolateThreshold] to offload large responses to an isolate.
class AesDecryptFusedTransformer extends Transformer {
  AesDecryptFusedTransformer({
    this.contentLengthIsolateThreshold = -1,
    Map<String, String>? encryptKeys,
  }) : _encryptKeys = encryptKeys ?? defaultEncryptKeys;

  /// Always decode the response in the same isolate.
  factory AesDecryptFusedTransformer.sync({Map<String, String>? encryptKeys}) =>
      AesDecryptFusedTransformer(
        contentLengthIsolateThreshold: -1,
        encryptKeys: encryptKeys,
      );

  /// Built-in `keyId -> base64 raw AES key` map.
  ///
  /// Mirrors the default of packages/core's `PUBLIC_URL_ENCRYPT_KEYS` remote
  /// config so the SDK decrypts the same public assets out of the box. The
  /// backend rotates keys by publishing a new id; add the id/key here (or pass
  /// [encryptKeys]) when that happens.
  static const Map<String, String> defaultEncryptKeys = {
    '1': 'GzAND4E3DFTDKUs0bsrk4UBB9lFAJPmuRQcCIDZbx90=',
  };

  final Map<String, String> _encryptKeys;

  /// Whether to switch decoding to an isolate for large responses.
  /// -1 disables (always same isolate); 0 always uses an isolate.
  final int contentLengthIsolateThreshold;

  static final _utf8JsonDecoder = const Utf8Decoder().fuse(const JsonDecoder());

  /// AES-CTR counter length: use the whole 128-bit IV as the counter.
  static const _aesCtrCounterLength = 128;

  /// webcrypto internal buffer size (see [_splitChunks]).
  static const _maxChunkSize = 4096;

  @override
  Future<String> transformRequest(RequestOptions options) async {
    return Transformer.defaultTransformRequest(options, jsonEncode);
  }

  @override
  Future<dynamic> transformResponse(
    RequestOptions options,
    ResponseBody responseBody,
  ) async {
    // If response type is stream, return the response body as is.
    if (options.responseType == ResponseType.stream) {
      return responseBody;
    }

    // Decrypt in place when the headers say so (no-op otherwise).
    await _tryDecryptResponse(responseBody);

    // Process response according to content type.
    return _processResponseContent(options, responseBody);
  }

  // ============================================================
  // Decryption Methods
  // ============================================================

  /// Decrypts [responseBody] in place when it advertises encryption; otherwise
  /// leaves the original bytes untouched.
  Future<void> _tryDecryptResponse(ResponseBody responseBody) async {
    final headers = responseBody.headers;
    final algo = _firstHeader(headers, HttpHeader.xEncryptedAlgo);
    final keyId = _firstHeader(headers, HttpHeader.xEncryptedKeyId);
    final ivStr = _firstHeader(headers, HttpHeader.xEncryptedIv);
    final xContentType = _firstHeader(headers, HttpHeader.xContentType);

    if (!_shouldDecrypt(algo, keyId, ivStr, xContentType)) {
      return;
    }

    final keyStr = _encryptKeys[keyId];
    if (keyStr == null) {
      // Unknown key id — return the original (still-encrypted) bytes rather
      // than throwing, so an unexpected rotation degrades gracefully.
      return;
    }

    try {
      final rawKey = base64.decode(keyStr);
      final rawIv = base64.decode(ivStr!);

      final decryptStream = await _createDecryptStream(
        algo: algo!,
        rawKey: rawKey,
        rawIv: rawIv,
        sourceStream: responseBody.stream,
      );

      responseBody.stream = decryptStream;
      _updateHeadersAfterDecryption(responseBody, xContentType!);
    } catch (_) {
      // Best-effort: on any decryption error keep the original encrypted data.
      return;
    }
  }

  /// First value for [key] in [headers], or `null` when absent/empty.
  static String? _firstHeader(Map<String, List<String>> headers, String key) {
    final values = headers[key];
    return (values == null || values.isEmpty) ? null : values.first;
  }

  /// Whether decryption should be attempted (supports AES-CBC and AES-CTR).
  bool _shouldDecrypt(
    String? algo,
    String? keyId,
    String? ivStr,
    String? xContentType,
  ) {
    return (algo == 'AES-CBC' || algo == 'AES-CTR') &&
        keyId != null &&
        ivStr != null &&
        xContentType != null;
  }

  /// Builds the decrypting byte stream.
  Future<Stream<Uint8List>> _createDecryptStream({
    required String algo,
    required Uint8List rawKey,
    required Uint8List rawIv,
    required Stream<Uint8List> sourceStream,
  }) async {
    if (algo == 'AES-CTR') {
      final key = await AesCtrSecretKey.importRawKey(rawKey);
      final safeStream = _splitChunks(sourceStream);
      return key.decryptStream(safeStream, rawIv, _aesCtrCounterLength);
    } else {
      // AES-CBC
      final key = await AesCbcSecretKey.importRawKey(rawKey);
      return key.decryptStream(sourceStream, rawIv);
    }
  }

  /// Splits stream chunks into pieces of at most [_maxChunkSize] bytes.
  ///
  /// Works around a webcrypto AES-CTR `decryptStream` bug: in
  /// `impl_ffi.aesctr.dart`, `N = min(M, bufSize)` should be
  /// `min(M - i, bufSize)`. For chunks > 4096 bytes the second loop iteration
  /// miscomputes N and trips an assertion; capping chunk size makes the loop
  /// run once and avoids it.
  Stream<Uint8List> _splitChunks(Stream<Uint8List> source) async* {
    const maxChunkSize = _maxChunkSize;
    await for (final chunk in source) {
      var offset = 0;
      while (offset < chunk.length) {
        final end = (offset + maxChunkSize).clamp(0, chunk.length);
        yield chunk.sublist(offset, end);
        offset = end;
      }
    }
  }

  /// Updates headers after decryption: promote `X-Content-Type` to
  /// `Content-Type` and drop the now-consumed `X-Encrypted-*` markers.
  void _updateHeadersAfterDecryption(
    ResponseBody responseBody,
    String xContentType,
  ) {
    responseBody.headers[Headers.contentTypeHeader] = [xContentType];
    responseBody.headers.remove(HttpHeader.xEncryptedAlgo.toLowerCase());
    responseBody.headers.remove(HttpHeader.xEncryptedKeyId.toLowerCase());
    responseBody.headers.remove(HttpHeader.xEncryptedIv.toLowerCase());
    responseBody.headers.remove(HttpHeader.xContentType.toLowerCase());
    responseBody.headers.remove(HttpHeader.xEncryptedChunkSize.toLowerCase());
  }

  // ============================================================
  // Response Content Processing Methods
  // ============================================================

  Future<dynamic> _processResponseContent(
    RequestOptions options,
    ResponseBody responseBody,
  ) async {
    final contentTypeHeader =
        responseBody.headers[Headers.contentTypeHeader]?.first;

    // Binary content — return raw bytes.
    if (_isBinaryContentType(contentTypeHeader)) {
      return consolidateBytes(responseBody.stream);
    }

    final isJsonContent = Transformer.isJsonMimeType(contentTypeHeader);
    final customDecoder = options.responseDecoder;

    // Fast path: JSON without custom decoder.
    if (isJsonContent && customDecoder == null) {
      return _fastUtf8JsonDecode(options, responseBody);
    }

    // Slow path: custom decoder or non-JSON content.
    return _processWithCustomDecoder(
      responseBody: responseBody,
      options: options,
      isJsonContent: isJsonContent,
      customDecoder: customDecoder,
    );
  }

  Future<dynamic> _processWithCustomDecoder({
    required ResponseBody responseBody,
    required RequestOptions options,
    required bool isJsonContent,
    required ResponseDecoder? customDecoder,
  }) async {
    final responseBytes = await consolidateBytes(responseBody.stream);

    if (customDecoder != null) {
      final decodeResult = customDecoder(
        responseBytes,
        options,
        responseBody..stream = const Stream.empty(),
      );

      final decodedResponse = decodeResult is Future
          ? await decodeResult
          : decodeResult;

      if (isJsonContent && decodedResponse != null) {
        return jsonDecode(decodedResponse);
      }
      return decodedResponse;
    }

    // Non-JSON — treat as a UTF8 string.
    return utf8.decode(responseBytes, allowMalformed: true);
  }

  // ============================================================
  // JSON Decoding Methods
  // ============================================================

  Future<Object?> _fastUtf8JsonDecode(
    RequestOptions options,
    ResponseBody responseBody,
  ) async {
    final contentLengthHeader =
        responseBody.headers[Headers.contentLengthHeader];

    final hasContentLengthHeader =
        contentLengthHeader != null && contentLengthHeader.isNotEmpty;

    final int contentLength;
    Uint8List? responseBytes;

    if (!hasContentLengthHeader) {
      responseBytes = await consolidateBytes(responseBody.stream);
      contentLength = responseBytes.length;
    } else {
      contentLength = int.parse(contentLengthHeader.first);
    }

    final shouldUseIsolate =
        !(contentLengthIsolateThreshold < 0) &&
        contentLength >= contentLengthIsolateThreshold;

    if (shouldUseIsolate) {
      return compute(
        _decodeUtf8ToJson,
        responseBytes ?? await consolidateBytes(responseBody.stream),
      );
    } else {
      if (responseBytes != null) {
        if (responseBytes.isEmpty) {
          return null;
        }
        return _utf8JsonDecoder.convert(responseBytes);
      } else {
        return _decodeJsonFromStream(responseBody.stream);
      }
    }
  }

  Future<Object?> _decodeJsonFromStream(Stream<Uint8List> stream) async {
    final streamWithNullFallback = stream.transform(
      const DefaultNullIfEmptyStreamTransformer(),
    );
    final decodedStream = _utf8JsonDecoder.bind(streamWithNullFallback);
    final decoded = await decodedStream.toList();

    if (decoded.isEmpty) {
      return null;
    }
    assert(decoded.length == 1);
    return decoded.first;
  }

  static Future<Object?> _decodeUtf8ToJson(Uint8List data) async {
    if (data.isEmpty) {
      return null;
    }
    return _utf8JsonDecoder.convert(data);
  }

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Whether [contentType] denotes binary data to be returned as bytes.
  bool _isBinaryContentType(String? contentType) {
    if (contentType == null) return false;

    final lowerContentType = contentType.toLowerCase();

    return lowerContentType.startsWith('image/') ||
        lowerContentType.startsWith('video/') ||
        lowerContentType.startsWith('audio/') ||
        lowerContentType.startsWith('application/octet-stream') ||
        lowerContentType.startsWith('application/pdf') ||
        lowerContentType.startsWith('application/zip') ||
        lowerContentType.startsWith('application/x-') ||
        lowerContentType.contains('binary');
  }
}
