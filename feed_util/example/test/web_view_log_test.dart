import 'package:feed_util_flutter_example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  test('ignores WebKit navigation cancellation', () {
    const error = WebResourceError(
      errorCode: -999,
      description: 'cancelled',
      isForMainFrame: true,
    );

    expect(shouldReportLivestreamWebViewError(error), isFalse);
  });

  test('keeps actionable WebView network errors', () {
    const error = WebResourceError(
      errorCode: -2,
      description: 'host lookup failed',
      errorType: WebResourceErrorType.hostLookup,
      isForMainFrame: false,
    );

    expect(shouldReportLivestreamWebViewError(error), isTrue);
  });
}
