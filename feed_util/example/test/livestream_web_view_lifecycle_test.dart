import 'package:feed_util_flutter_example/livestream_web_view_lifecycle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pauses media and unloads the livestream document', () async {
    final calls = <String>[];
    final lifecycle = LivestreamWebViewLifecycle(
      runJavaScript: (javaScript) async {
        expect(javaScript, contains("querySelectorAll('audio, video')"));
        calls.add('pause');
      },
      loadRequest: (uri) async => calls.add('load:$uri'),
    );

    await lifecycle.stop();

    expect(calls, ['pause', 'load:about:blank']);
  });

  test('still unloads when JavaScript teardown fails', () async {
    final loadedUris = <Uri>[];
    final lifecycle = LivestreamWebViewLifecycle(
      runJavaScript: (_) => Future<void>.error(StateError('WebView exited')),
      loadRequest: (uri) async => loadedUris.add(uri),
    );

    await lifecycle.stop();

    expect(loadedUris, [Uri.parse('about:blank')]);
  });

  test('coalesces repeated teardown requests', () async {
    var pauseCalls = 0;
    var loadCalls = 0;
    final lifecycle = LivestreamWebViewLifecycle(
      runJavaScript: (_) async => pauseCalls++,
      loadRequest: (_) async => loadCalls++,
    );

    await Future.wait([lifecycle.stop(), lifecycle.stop()]);

    expect(pauseCalls, 1);
    expect(loadCalls, 1);
  });
}
