package live.swag.feedutil.example;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowInsets;
import android.widget.FrameLayout;
import android.widget.GridLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import androidx.browser.customtabs.CustomTabsIntent;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import live.swag.feedutil.CompletionCallback;
import live.swag.feedutil.FeedUtil;
import live.swag.feedutil.FeedUtilException;
import live.swag.feedutil.LivestreamItem;
import live.swag.feedutil.LivestreamPage;
import live.swag.feedutil.LivestreamSdkConfig;
import live.swag.feedutil.ResultCallback;

/**
 * Java host demo: configures the SDK, fetches the livestream feed, and renders
 * real feed metadata as cards. Everything goes through the typed {@link FeedUtil}
 * API — no MethodChannel, no map parsing; results arrive as {@link LivestreamPage}
 * / {@link LivestreamItem} on the main thread. Cover images are fetched lazily per
 * card via {@code getCoverImage} (decrypted on the Dart side) over a colored
 * placeholder. UI modeled on the in-app livestream tab card. Colors are
 * hard-coded (an example app has no design tokens).
 */
public class MainActivity extends Activity {

    private static final String FEED_ID = "user_livestream-v2";
    private static final List<String> TRACKER_SERVERS = Arrays.asList(
            "138.113.217.111",
            "138.113.217.43",
            "wscps.henkeichu.com",
            "wscps.henkeichu.info",
            "wscps.henkeichu.net");

    private TextView statusView;
    private GridLayout grid;
    private SwipeRefreshLayout swipe;
    private ScrollView scroll;
    private int cellWidth;
    private String nextToken;    // opaque page cursor for load-more; null = no more pages
    private boolean loadingMore; // guards against firing load-more repeatedly while scrolling
    // Off-UI-thread cover decoding so BitmapFactory work doesn't jank scrolling.
    private final ExecutorService coverExecutor = Executors.newFixedThreadPool(2);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        grid = new GridLayout(this);
        grid.setColumnCount(2);
        grid.setPadding(dp(6), dp(6), dp(6), dp(6));

        scroll = new ScrollView(this);
        scroll.addView(grid);
        // Load-more: fetch the next page as the user nears the bottom.
        scroll.setOnScrollChangeListener((v, x, y, oldX, oldY) -> maybeLoadMore());
        // targetSdk 36 draws edge-to-edge, so pad the feed clear of the status
        // bar (top) and navigation bar (bottom).
        scroll.setOnApplyWindowInsetsListener((v, insets) -> {
            int top, bottom;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                android.graphics.Insets bars = insets.getInsets(WindowInsets.Type.systemBars());
                top = bars.top;
                bottom = bars.bottom;
            } else {
                top = insets.getSystemWindowInsetTop();
                bottom = insets.getSystemWindowInsetBottom();
            }
            v.setPadding(0, top, 0, bottom);
            return insets;
        });

        swipe = new SwipeRefreshLayout(this);
        swipe.addView(scroll);
        // Pull-to-refresh reloads page 1 (null token = fresh, replaces the grid).
        swipe.setOnRefreshListener(() -> loadFeed(null));

        statusView = new TextView(this);
        statusView.setText("Loading " + FEED_ID + " …");
        statusView.setTextColor(Color.WHITE);
        statusView.setGravity(Gravity.CENTER);

        FrameLayout root = new FrameLayout(this);
        root.setBackgroundColor(0xFF121212);
        root.addView(swipe);
        root.addView(statusView, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(root);

        DisplayMetrics metrics = getResources().getDisplayMetrics();
        cellWidth = (metrics.widthPixels - dp(24)) / 2;

        configureThenLoad();
    }

    @Override
    protected void onDestroy() {
        coverExecutor.shutdownNow();
        super.onDestroy();
    }

    // --- SDK calls via the typed FeedUtil API ---------------------------------

    private void configureThenLoad() {
        // Runtime tracker token (the AAR bakes none) — from local.properties via
        // BuildConfig. Omitted when empty so a misconfigured build fails loudly
        // as domain_tracker_server_not_found rather than sending a blank token.
        LivestreamSdkConfig config = BuildConfig.TRACKER_AUTH_TOKEN.isEmpty()
                ? new LivestreamSdkConfig(TRACKER_SERVERS)
                : new LivestreamSdkConfig(TRACKER_SERVERS, BuildConfig.TRACKER_AUTH_TOKEN);
        FeedUtil.configure(config, new CompletionCallback() {
            @Override public void onSuccess() { loadFeed(null); }
            @Override public void onError(FeedUtilException e) {
                // configure is call-once; a re-created Activity is fine to proceed.
                if ("already_configured".equals(e.getCode())) loadFeed(null);
                else fail(e.getCode() + ": " + e.getMessage());
            }
        });
    }

    /**
     * Fetches one feed page. {@code pageToken == null} loads page 1 and replaces
     * the grid; a non-null token appends the next page (load-more).
     */
    private void loadFeed(final String pageToken) {
        final boolean append = pageToken != null;
        ResultCallback<LivestreamPage> callback = new ResultCallback<LivestreamPage>() {
            @Override public void onSuccess(LivestreamPage page) { onFeed(page, append); }
            @Override public void onError(FeedUtilException e) {
                fail(e.getCode() + ": " + e.getMessage());
            }
        };
        if (append) {
            FeedUtil.getLivestreamList(FEED_ID, pageToken, callback);
        } else {
            FeedUtil.getLivestreamList(FEED_ID, callback);
        }
    }

    /** Loads the next page once the user scrolls within one screen of the end. */
    private void maybeLoadMore() {
        if (loadingMore || nextToken == null) return;
        View content = scroll.getChildAt(0);
        if (content == null) return;
        int remaining = content.getBottom() - (scroll.getScrollY() + scroll.getHeight());
        if (remaining <= scroll.getHeight()) {
            loadingMore = true;
            loadFeed(nextToken);
        }
    }

    private void onFeed(LivestreamPage page, boolean append) {
        swipe.setRefreshing(false);
        loadingMore = false;
        nextToken = page.getNextToken();

        List<LivestreamItem> items = page.getItems();
        if (items.isEmpty()) {
            if (!append) {
                statusView.setVisibility(View.VISIBLE);
                statusView.setText("No livestreams.");
                grid.removeAllViews();
            }
            return;
        }
        statusView.setVisibility(View.GONE);
        if (!append) grid.removeAllViews();
        for (LivestreamItem item : items) {
            grid.addView(buildCard(item));
        }
    }

    private void fail(String message) {
        swipe.setRefreshing(false);
        loadingMore = false;
        statusView.setVisibility(View.VISIBLE);
        statusView.setText("Error: " + message);
    }

    // --- Card view ------------------------------------------------------------

    private View buildCard(LivestreamItem item) {
        String id = item.getId();
        String username = item.getUsername();
        String displayName = item.getDisplayName();
        String title = item.getTitle();
        String countryFlag = item.getCountryFlag();

        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.VERTICAL);
        GridLayout.LayoutParams lp = new GridLayout.LayoutParams();
        lp.width = cellWidth;
        lp.setMargins(dp(6), dp(6), dp(6), dp(6));
        card.setLayoutParams(lp);
        card.setOnClickListener(v -> openUrl(id));

        // Cover (square placeholder + overlays).
        FrameLayout cover = new FrameLayout(this);
        cover.setLayoutParams(new LinearLayout.LayoutParams(cellWidth, cellWidth));
        GradientDrawable coverBg = new GradientDrawable();
        coverBg.setColor(placeholderColor(id));
        coverBg.setCornerRadius(dp(12));
        cover.setBackground(coverBg);
        cover.setClipToOutline(true);

        TextView initial = new TextView(this);
        initial.setText(username.isEmpty() ? "?" : username.substring(0, 1).toUpperCase());
        initial.setTextColor(0x8CFFFFFF);
        initial.setTextSize(TypedValue.COMPLEX_UNIT_SP, 34);
        FrameLayout.LayoutParams initLp = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        initLp.gravity = Gravity.CENTER;
        cover.addView(initial, initLp);

        // Fetch the decrypted cover lazily; on success it slots in behind the
        // overlays and the placeholder letter is hidden. Failures/empties leave
        // the placeholder in place.
        loadCover(id, cover, initial);

        String[] status = statusLabelColor(item);
        if (status != null) {
            cover.addView(pill(status[0], (int) Long.parseLong(status[1], 16)),
                    overlayLp(Gravity.TOP | Gravity.END));
        }
        String badge = topLeftBadge(item);
        if (badge != null) {
            cover.addView(pill(badge, badgeColor(item)), overlayLp(Gravity.TOP | Gravity.START));
        }
        cover.addView(pill(viewerText(item.getViewers()), 0xB3000000),
                overlayLp(Gravity.BOTTOM | Gravity.START));
        double score = item.getScore() != null ? item.getScore() : 0;
        if (score > 0) {
            // Design: {flag} ★ {score} ({reviewCount}) at bottom-right.
            String flagPrefix = (countryFlag == null || countryFlag.isEmpty()) ? "" : countryFlag + " ";
            int reviews = item.getReviewCount();
            String reviewSuffix = reviews > 0 ? " (" + viewerText(reviews) + ")" : "";
            cover.addView(
                    pill(flagPrefix + "★ " + String.format("%.1f", score) + reviewSuffix, 0xB3000000),
                    overlayLp(Gravity.BOTTOM | Gravity.END));
        }
        card.addView(cover);

        TextView titleView = new TextView(this);
        titleView.setText(title == null || title.isEmpty() ? "(untitled)" : title);
        titleView.setTextColor(Color.WHITE);
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13);
        titleView.setMaxLines(1);
        titleView.setPadding(0, dp(6), 0, 0);
        card.addView(titleView);

        TextView subtitle = new TextView(this);
        subtitle.setText(displayName != null && !displayName.isEmpty() ? displayName : username);
        subtitle.setTextColor(0xFFB0B0B0);
        subtitle.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12);
        subtitle.setMaxLines(1);
        card.addView(subtitle);

        return card;
    }

    /**
     * Builds the livestream web-view URL via the SDK and opens it in an in-app
     * Chrome Custom Tab. Falls back to surfacing the URL if the device has no
     * browser/handler so the demo never crashes.
     */
    private void openUrl(String id) {
        FeedUtil.buildLivestreamUrl(id, new ResultCallback<String>() {
            @Override public void onSuccess(String url) {
                try {
                    new CustomTabsIntent.Builder().build().launchUrl(MainActivity.this, Uri.parse(url));
                } catch (ActivityNotFoundException e) {
                    Toast.makeText(MainActivity.this, url, Toast.LENGTH_LONG).show();
                }
            }
            @Override public void onError(FeedUtilException e) {
                Toast.makeText(MainActivity.this, "URL unavailable: " + e.getMessage(),
                        Toast.LENGTH_SHORT).show();
            }
        });
    }

    /**
     * Requests the decrypted cover for {@code id} via the SDK ({@code byte[]}, or
     * null when the stream has no cover). On success it decodes to a bitmap and
     * slots an ImageView behind the overlays (index 0), hiding the placeholder
     * letter. The callback lands on the UI thread, so the decode is pushed to
     * {@link #coverExecutor} and only the view updates run back on the UI thread.
     */
    private void loadCover(String id, FrameLayout cover, TextView initial) {
        FeedUtil.getCoverImage(id, new ResultCallback<byte[]>() {
            @Override public void onSuccess(byte[] bytes) {
                if (bytes == null || bytes.length == 0) return; // no cover
                coverExecutor.execute(() -> {
                    final Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
                    if (bitmap == null) return;
                    runOnUiThread(() -> {
                        ImageView image = new ImageView(MainActivity.this);
                        image.setScaleType(ImageView.ScaleType.CENTER_CROP);
                        image.setImageBitmap(bitmap);
                        cover.addView(image, 0, new FrameLayout.LayoutParams(
                                ViewGroup.LayoutParams.MATCH_PARENT,
                                ViewGroup.LayoutParams.MATCH_PARENT));
                        initial.setVisibility(View.GONE);
                    });
                });
            }
            @Override public void onError(FeedUtilException e) { }
        });
    }

    // --- helpers --------------------------------------------------------------

    private TextView pill(String text, int argb) {
        TextView tv = new TextView(this);
        tv.setText(text);
        tv.setTextColor(Color.WHITE);
        tv.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11);
        tv.setPadding(dp(6), dp(2), dp(6), dp(2));
        GradientDrawable bg = new GradientDrawable();
        bg.setColor(argb);
        bg.setCornerRadius(dp(6));
        tv.setBackground(bg);
        return tv;
    }

    private FrameLayout.LayoutParams overlayLp(int gravity) {
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.gravity = gravity;
        lp.setMargins(dp(6), dp(6), dp(6), dp(6));
        return lp;
    }

    /** status -> {label, hex-argb-without-0x}; null hides the pill. */
    private String[] statusLabelColor(LivestreamItem item) {
        switch (item.getStatus()) {
            case FREE: return new String[]{"免費直播中", "CC000000"};
            case PERFORMING: return new String[]{"表演中", "FF7C4DFF"};
            case FUNDING:
                int target = item.getFundingTarget() != null ? item.getFundingTarget() : 0;
                int progress = item.getFundingProgress() != null ? item.getFundingProgress() : 0;
                int remaining = target - progress;
                return new String[]{remaining > 0 ? "剩 " + remaining + " 張" : "募資中", "FF7C4DFF"};
            case EXCLUSIVE: return new String[]{"獨家", "FF3A6DE0"};
            default: return null; // OFFLINE / UNKNOWN
        }
    }

    private String topLeftBadge(LivestreamItem item) {
        if (item.isVipSponsor()) return "VIP";
        if (item.isNewbie()) return "NEW";
        if (item.hasToy()) return "TOY";
        return null;
    }

    private int badgeColor(LivestreamItem item) {
        if (item.isVipSponsor()) return 0xFFB8860B;
        if (item.isNewbie()) return 0xFF2E7D32;
        return 0xFFAD1457;
    }

    private String viewerText(int viewers) {
        return viewers >= 1000 ? (viewers / 1000) + "k" : String.valueOf(viewers);
    }

    private int placeholderColor(String id) {
        float hue = Math.abs(id.hashCode() % 360);
        return Color.HSVToColor(new float[]{hue, 0.35f, 0.30f});
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}
