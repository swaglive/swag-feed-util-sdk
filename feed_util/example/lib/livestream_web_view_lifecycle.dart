import 'dart:async';

/// Stops a host-owned livestream WebView exactly once.
///
/// Detaching a WKWebView from Flutter's widget tree does not guarantee that
/// WebKit stops media immediately. This lifecycle sends both an in-page pause
/// and a blank-page navigation so playback ends without waiting for native
/// object finalization.
final class LivestreamWebViewLifecycle {
  LivestreamWebViewLifecycle({
    required Future<void> Function(String javaScript) runJavaScript,
    required Future<void> Function(Uri uri) loadRequest,
    this.operationTimeout = const Duration(seconds: 1),
  }) : _runJavaScript = runJavaScript,
       _loadRequest = loadRequest;

  static final Uri _blankPage = Uri.parse('about:blank');

  static const String _pauseMediaJavaScript = r'''
(() => {
  for (const media of document.querySelectorAll('audio, video')) {
    try { media.pause(); } catch (_) {}
    try { media.srcObject = null; } catch (_) {}
    try { media.removeAttribute('src'); } catch (_) {}
    try { media.load(); } catch (_) {}
  }
})();
''';

  final Future<void> Function(String javaScript) _runJavaScript;
  final Future<void> Function(Uri uri) _loadRequest;
  final Duration operationTimeout;

  Future<void>? _stopFuture;

  /// Pauses and unloads playback. Repeated calls join the first teardown.
  Future<void> stop() => _stopFuture ??= _stopOnce();

  Future<void> _stopOnce() async {
    // Start both operations immediately. The blank navigation is still sent
    // when JavaScript execution fails or the WebKit content process is gone.
    await Future.wait<void>([
      _bestEffort(() => _runJavaScript(_pauseMediaJavaScript)),
      _bestEffort(() => _loadRequest(_blankPage)),
    ]);
  }

  Future<void> _bestEffort(Future<void> Function() operation) async {
    try {
      await operation().timeout(operationTimeout);
    } catch (_) {
      // Teardown must never block route disposal.
    }
  }
}
