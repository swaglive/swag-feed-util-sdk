package live.swag.feedutil.example;

import android.app.Activity;
import android.graphics.Bitmap;
import android.net.http.SslError;
import android.os.Bundle;
import android.view.ViewGroup;
import android.webkit.SslErrorHandler;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;

import live.swag.feedutil.FeedUtil;
import live.swag.feedutil.WebViewLogEvent;
import live.swag.feedutil.WebViewNetworkErrorType;

/**
 * Hosts the livestream URL produced by the SDK in a full-screen {@link WebView}.
 *
 * <p>Replaces the Chrome Custom Tab so the demo controls the WebView settings —
 * chiefly {@link WebSettings#setMediaPlaybackRequiresUserGesture(boolean)} set to
 * {@code false} so the livestream autoplays without a tap (the Custom Tab / stock
 * browser blocks autoplay and can't be told otherwise).
 */
public final class WebViewActivity extends Activity {

    /** Intent extra: the livestream URL to load (required). */
    public static final String EXTRA_URL = "live.swag.feedutil.example.URL";

    private WebView webView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        webView = new WebView(this);
        webView.setLayoutParams(new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        // Let the livestream start playing without a user gesture.
        webSettings.setMediaPlaybackRequiresUserGesture(false);

        // Keep navigation inside the WebView and forward only lifecycle plus
        // controlled failure categories to sanitized SDK diagnostics.
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                FeedUtil.reportWebViewEvent(WebViewLogEvent.pageStarted());
                super.onPageStarted(view, url, favicon);
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                FeedUtil.reportWebViewEvent(WebViewLogEvent.pageFinished());
                super.onPageFinished(view, url);
            }

            @Override
            public void onReceivedHttpError(
                    WebView view,
                    WebResourceRequest request,
                    WebResourceResponse response) {
                FeedUtil.reportWebViewEvent(WebViewLogEvent.httpError(
                        response.getStatusCode(),
                        request.isForMainFrame()));
                super.onReceivedHttpError(view, request, response);
            }

            @Override
            public void onReceivedError(
                    WebView view,
                    WebResourceRequest request,
                    WebResourceError error) {
                FeedUtil.reportWebViewEvent(WebViewLogEvent.networkError(
                        error.getErrorCode(),
                        errorType(error.getErrorCode()),
                        request.isForMainFrame()));
                super.onReceivedError(view, request, error);
            }

            @Override
            public void onReceivedSslError(
                    WebView view,
                    SslErrorHandler handler,
                    SslError error) {
                FeedUtil.reportWebViewEvent(WebViewLogEvent.networkError(
                        error.getPrimaryError(),
                        WebViewNetworkErrorType.TLS,
                        null));
                // Keep WebViewClient's secure default: cancel the request.
                super.onReceivedSslError(view, handler, error);
            }
        });

        setContentView(webView);

        String url = getIntent().getStringExtra(EXTRA_URL);
        if (url != null) {
            webView.loadUrl(url);
        } else {
            finish();
        }
    }

    private static WebViewNetworkErrorType errorType(int errorCode) {
        switch (errorCode) {
            case WebViewClient.ERROR_HOST_LOOKUP: return WebViewNetworkErrorType.DNS;
            case WebViewClient.ERROR_TIMEOUT: return WebViewNetworkErrorType.TIMEOUT;
            case WebViewClient.ERROR_CONNECT: return WebViewNetworkErrorType.CONNECTION;
            case WebViewClient.ERROR_FAILED_SSL_HANDSHAKE: return WebViewNetworkErrorType.TLS;
            default: return WebViewNetworkErrorType.UNKNOWN;
        }
    }

    @Override
    public void onBackPressed() {
        if (webView != null && webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }

    @Override
    protected void onDestroy() {
        if (webView != null) {
            webView.destroy();
            webView = null;
        }
        super.onDestroy();
    }
}
