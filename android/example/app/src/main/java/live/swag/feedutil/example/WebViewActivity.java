package live.swag.feedutil.example;

import android.app.Activity;
import android.os.Bundle;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

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

        // Keep navigation inside the WebView instead of kicking out to a browser.
        webView.setWebViewClient(new WebViewClient());

        setContentView(webView);

        String url = getIntent().getStringExtra(EXTRA_URL);
        if (url != null) {
            webView.loadUrl(url);
        } else {
            finish();
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
