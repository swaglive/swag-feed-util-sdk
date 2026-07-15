import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'src/livestream_sdk.dart';
import 'src/livestream_sdk_impl.dart';
import 'src/log/feed_util_log.dart';
import 'src/log/log_entry.dart';
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
///   override; never empty — `mdm=1` is always present), cached natively so
///   `buildLivestreamUrl` stays synchronous after the first resolve
///
/// And Dart → native (pushed by the SDK, not a host request):
/// - `log {severity, message}` → null — a diagnostic [LogEntry] delivered to
///   the native `FeedUtil` log callback (best-effort; ignored if no native
///   handler is attached).
///
/// Errors cross as [PlatformException] with a stable `code`:
/// `not_configured` · `already_configured` · `bad_args` ·
/// `domain_tracker_server_not_found` · `network` · `illegal_state` ·
/// `unimplemented`.
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
    // Forward SDK diagnostic logs to the native FeedUtil log callback.
    FeedUtilLog.instance.bindNativeSink(_pushLog);
  }

  /// Stops listening and releases the SDK.
  void dispose() {
    _channel.setMethodCallHandler(null);
    FeedUtilLog.instance.bindNativeSink(null);
    _sdk = null;
  }

  /// Pushes a diagnostic [LogEntry] to the native side over the channel.
  ///
  /// Fire-and-forget and best-effort: logging must never throw into or block
  /// the code path that emitted it, and a host with no `log` handler (or no
  /// native side at all, e.g. in Dart unit tests) must not surface an error.
  void _pushLog(LogEntry entry) {
    unawaited(
      _channel.invokeMethod<void>('log', entry.toMap()).catchError((_) {}),
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
      rethrow; // already carries a stable code (bad_args / not_configured)
    } on DomainTrackerServerNotFoundException catch (e) {
      throw PlatformException(
        code: 'domain_tracker_server_not_found',
        message: e.toString(),
      );
    } on DioException catch (e) {
      throw PlatformException(code: 'network', message: e.message ?? '$e');
    } on UnimplementedError catch (e) {
      // Feature wiring pending (WS-A / WS-B) — surfaced explicitly, not as a
      // generic crash, so hosts can tell "not yet built" from a real failure.
      throw PlatformException(code: 'unimplemented', message: e.toString());
    } on StateError catch (e) {
      throw PlatformException(code: 'illegal_state', message: e.message);
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
        code: 'already_configured',
        message: 'configure was already called; reconfiguring is not supported',
      );
    }
    final servers = (args['trackerServers'] as List?)?.cast<String>();
    if (servers == null || servers.isEmpty) {
      throw PlatformException(
        code: 'bad_args',
        message: 'configure: "trackerServers" is required and non-empty',
      );
    }
    _sdk = LivestreamSdkImpl(
      LivestreamSdkConfig(
        trackerServers: servers,
        trackerAuthToken: args['trackerAuthToken'] as String?,
        trackerLabels: (args['trackerLabels'] as List?)?.cast<String>(),
      ),
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
        code: 'not_configured',
        message: 'call configure before this method',
      );
    }
    return sdk;
  }

  Map<String, Object?> _args(MethodCall call) {
    final args = call.arguments;
    if (args == null) return const {};
    if (args is Map) return args.cast<String, Object?>();
    throw PlatformException(
      code: 'bad_args',
      message: '${call.method}: expected a map, got ${args.runtimeType}',
    );
  }

  String _requireString(Map<String, Object?> args, String key, String method) {
    final value = args[key];
    if (value is String && value.isNotEmpty) return value;
    throw PlatformException(
      code: 'bad_args',
      message: '$method: missing or invalid "$key"',
    );
  }
}
