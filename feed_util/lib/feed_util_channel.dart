import 'dart:async';

import 'package:flutter/services.dart';

import 'src/diagnostics/feed_util_diagnostics.dart';
import 'src/livestream_sdk.dart';
import 'src/livestream_sdk_exception.dart';
import 'src/livestream_sdk_impl.dart';
import 'src/model/livestream_page.dart';

/// Dart-side counterpart of the native `FeedUtil` entry points
/// (`FeedUtil.swift` / `FeedUtil.kt`).
///
/// Routes MethodChannel calls from the host to [LivestreamSdkImpl]. The host
/// calls `configure` once, then the feature methods. Register it at engine
/// startup (`FeedUtilChannel.instance.init()` in `main`).
///
/// Bridge contract (`feed_util/method`, native → Dart):
/// - `ping` → `"pong"` (smoke test)
/// - `configure {trackerServers, trackerAuthToken?, trackerLabels?}` → null
/// - `getLivestreamList {feedId, pageToken?, bustCache?}` → [LivestreamPage.toMap]
/// - `getCoverImage {livestreamId}` → `Uint8List?`
/// - `livestreamUrlContext` → `{frontendBase: String, query: String}` — the
///   resolved frontend base plus the web-view query
///   (`mdm=1&config=KEY:::VALUE&…`, one `config` per tracker remote-config
///   override; never empty — `mdm=1` is always present). This context is
///   deliberately OTP-free and may be cached natively; each facade appends the
///   fresh OTP supplied to `buildLivestreamUrl`
///
/// And Dart → native (pushed by the SDK, not a host request):
/// - `diagnosticLog {level, line}` → null — an already-sanitized structured
///   event printed by the native facade (best-effort).
///
/// Errors cross as [PlatformException] with one stable sanitized code:
/// `invalid_argument` · `illegal_state` · `domain_unreachable` ·
/// `network_timeout` · `network_failure` · `bad_response` ·
/// `decryption_failure` · `internal_failure`.
class FeedUtilChannel {
  FeedUtilChannel._();

  static final instance = FeedUtilChannel._();

  /// Must match `channelName` in FeedUtil.swift and `CHANNEL_NAME` in
  /// FeedUtil.kt.
  static const _channel = MethodChannel('feed_util/method');

  /// Built by `configure`; the impl type is used so the channel can call the
  /// impl-only `livestreamUrlContext()` (kept off the public interface).
  LivestreamSdkImpl? _sdk;

  /// Starts listening for calls from the native side.
  void init() {
    _channel.setMethodCallHandler(_handle);
  }

  /// Stops listening and releases the SDK.
  void dispose() {
    _channel.setMethodCallHandler(null);
    _sdk = null;
  }

  /// Pushes one already-sanitized line to the native platform logger.
  void _pushDiagnostic(FeedUtilDiagnosticLevel level, String line) {
    unawaited(
      _channel
          .invokeMethod<void>('diagnosticLog', {
            'level': level.wireName,
            'line': line,
          })
          .catchError((_) {}),
    );
  }

  /// Invokes a native-side method (handled in `FeedUtil.swift` /
  /// `FeedUtil.kt`).
  Future<T?> invoke<T>(String method, [Object? arguments]) =>
      _channel.invokeMethod<T>(method, arguments);

  /// Handles calls initiated from the native side.
  Future<Object?> _handle(MethodCall call) async {
    try {
      switch (call.method) {
        case 'ping':
          return 'pong';
        case 'configure':
          return _configure(_args(call));
        case 'getLivestreamList':
          return await _getLivestreamList(_args(call));
        case 'getCoverImage':
          return await _getCoverImage(_args(call));
        case 'livestreamUrlContext':
          return await _requireSdk().livestreamUrlContext();
        default:
          throw MissingPluginException(
            'feed_util: ${call.method} not implemented',
          );
      }
    } on PlatformException {
      rethrow; // already carries a stable sanitized code/message
    } on LivestreamSdkException catch (error) {
      throw PlatformException(
        code: error.code.wireName,
        message: error.message,
      );
    } catch (_) {
      throw PlatformException(
        code: 'internal_failure',
        message: 'The SDK could not complete the operation.',
      );
    }
  }

  // --- method handlers -------------------------------------------------------

  Object? _configure(Map<String, Object?> args) {
    // Configure-once (see the class doc). Reject a second call instead of
    // replacing the SDK — a silent reset would drop the cached domains + any
    // in-flight resolve, leak the old Dio client, and swallow a host
    // call-order bug. Hosts that must reconfigure should recreate the engine.
    if (_sdk != null) {
      throw PlatformException(
        code: 'illegal_state',
        message: 'The SDK is not ready for this operation.',
      );
    }
    final servers = (args['trackerServers'] as List?)?.cast<String>();
    if (servers == null || servers.isEmpty) {
      throw PlatformException(
        code: 'invalid_argument',
        message: 'An SDK argument is invalid.',
      );
    }
    _sdk = LivestreamSdkImpl(
      LivestreamSdkConfig(
        trackerServers: servers,
        trackerAuthToken: args['trackerAuthToken'] as String?,
        trackerLabels: (args['trackerLabels'] as List?)?.cast<String>(),
        debugMode: args['debugMode'] == true,
      ),
      diagnosticPlatform: FeedUtilDiagnosticPlatform.fromWire(
        args['platform'] as String?,
      ),
      diagnosticOutput: _pushDiagnostic,
    );
    return null;
  }

  Future<Map<String, Object?>> _getLivestreamList(
    Map<String, Object?> args,
  ) async {
    final sdk = _requireSdk();
    final feedId = _requireString(args, 'feedId', 'getLivestreamList');
    final tokenRaw = args['pageToken'] as String?;
    final page = await sdk.getLivestreamList(
      feedId,
      pageToken: tokenRaw == null ? null : PageToken(tokenRaw),
      bustCache: args['bustCache'] == true,
    );
    return page.toMap();
  }

  Future<Uint8List?> _getCoverImage(Map<String, Object?> args) async {
    final sdk = _requireSdk();
    final id = _requireString(args, 'livestreamId', 'getCoverImage');
    return sdk.getCoverImage(id);
  }

  // --- helpers ---------------------------------------------------------------

  LivestreamSdkImpl _requireSdk() {
    final sdk = _sdk;
    if (sdk == null) {
      throw PlatformException(
        code: 'illegal_state',
        message: 'The SDK is not ready for this operation.',
      );
    }
    return sdk;
  }

  Map<String, Object?> _args(MethodCall call) {
    final args = call.arguments;
    if (args == null) return const {};
    if (args is Map) return args.cast<String, Object?>();
    throw PlatformException(
      code: 'invalid_argument',
      message: 'An SDK argument is invalid.',
    );
  }

  String _requireString(Map<String, Object?> args, String key, String method) {
    final value = args[key];
    if (value is String && value.isNotEmpty) return value;
    throw PlatformException(
      code: 'invalid_argument',
      message: 'An SDK argument is invalid.',
    );
  }
}
