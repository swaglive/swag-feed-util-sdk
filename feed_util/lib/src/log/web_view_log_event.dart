/// A significant network event reported by the host's livestream web view.
///
/// The SDK intentionally does not own a web view. Hosts report only main-page
/// lifecycle events and failed requests through
/// `LivestreamSdk.reportWebViewEvent`; successful subresources and JavaScript
/// console output should not be reported.
enum WebViewLogEventType { pageStarted, pageFinished, httpError, networkError }

/// Controlled, cross-platform network failure categories.
enum WebViewNetworkErrorType {
  dns,
  timeout,
  connection,
  tls,
  offline,
  cancelled,
  unknown,
}

/// Structured diagnostic information from a host-owned livestream web view.
///
/// URLs, descriptions, request/response headers, and bodies are deliberately
/// not part of this model. Only controlled categories and scalar status/code
/// values can reach diagnostics.
final class WebViewLogEvent {
  const WebViewLogEvent._({
    required this.type,
    required this.statusCode,
    required this.errorCode,
    required this.errorType,
    required this.isForMainFrame,
  });

  /// The main document started loading.
  const WebViewLogEvent.pageStarted({bool? isForMainFrame = true})
    : this._(
        type: WebViewLogEventType.pageStarted,
        statusCode: null,
        errorCode: null,
        errorType: null,
        isForMainFrame: isForMainFrame,
      );

  /// The main document finished loading.
  const WebViewLogEvent.pageFinished({bool? isForMainFrame = true})
    : this._(
        type: WebViewLogEventType.pageFinished,
        statusCode: null,
        errorCode: null,
        errorType: null,
        isForMainFrame: isForMainFrame,
      );

  /// An HTTP request returned an error status (normally 4xx or 5xx).
  const WebViewLogEvent.httpError({int? statusCode, bool? isForMainFrame})
    : this._(
        type: WebViewLogEventType.httpError,
        statusCode: statusCode,
        errorCode: null,
        errorType: null,
        isForMainFrame: isForMainFrame,
      );

  /// A request failed before receiving an HTTP response, such as DNS, timeout,
  /// connection, or TLS failure.
  const WebViewLogEvent.networkError({
    int? errorCode,
    WebViewNetworkErrorType errorType = WebViewNetworkErrorType.unknown,
    bool? isForMainFrame,
  }) : this._(
         type: WebViewLogEventType.networkError,
         statusCode: null,
         errorCode: errorCode,
         errorType: errorType,
         isForMainFrame: isForMainFrame,
       );

  final WebViewLogEventType type;
  final int? statusCode;
  final int? errorCode;
  final WebViewNetworkErrorType? errorType;

  /// `true` for the main document, `false` for a subresource, or `null` when
  /// the platform WebView callback cannot identify the frame.
  final bool? isForMainFrame;
}
