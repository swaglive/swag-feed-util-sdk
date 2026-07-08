package live.swag.feedutil.example;

import android.app.Activity;
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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import io.flutter.plugin.common.MethodChannel;
import live.swag.feedutil.FeedUtil;

/**
 * Java host demo: configures the SDK, fetches the livestream feed over the
 * MethodChannel, and renders real feed metadata as cards. Cover images are
 * fetched lazily per card via {@code getCoverImage} (decrypted on the Dart
 * side) over a colored placeholder. UI modeled on the in-app livestream tab
 * card. Colors are hard-coded (an example app has no design tokens).
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
    private String frontendBase; // cached from resolvedFrontendBase for tap URLs
    private String nextToken;    // opaque PageToken for load-more; null = no more pages
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

    // --- SDK calls over the MethodChannel -------------------------------------

    private void configureThenLoad() {
        Map<String, Object> config = new HashMap<>();
        config.put("trackerServers", TRACKER_SERVERS);
        // Runtime tracker token (the AAR bakes none) — from local.properties via
        // BuildConfig. Omitted when empty so a misconfigured build fails loudly
        // as domain_tracker_server_not_found rather than sending a blank token.
        if (!BuildConfig.TRACKER_AUTH_TOKEN.isEmpty()) {
            config.put("trackerAuthToken", BuildConfig.TRACKER_AUTH_TOKEN);
        }
        FeedUtil.invoke("configure", config, new MethodChannel.Result() {
            @Override public void success(Object result) { loadFeed(null); }
            @Override public void error(String code, String message, Object details) {
                // configure is call-once; a re-created Activity is fine to proceed.
                if ("already_configured".equals(code)) loadFeed(null);
                else fail(code + ": " + message);
            }
            @Override public void notImplemented() { fail("engine not ready"); }
        });
        // Cache the frontend base so card taps can build the web-view URL.
        FeedUtil.invoke("resolvedFrontendBase", null, new MethodChannel.Result() {
            @Override public void success(Object result) { frontendBase = (String) result; }
            @Override public void error(String c, String m, Object d) { }
            @Override public void notImplemented() { }
        });
    }

    /**
     * Fetches one feed page. {@code pageToken == null} loads page 1 and
     * replaces the grid; a non-null token appends the next page (load-more).
     */
    private void loadFeed(final String pageToken) {
        final boolean append = pageToken != null;
        Map<String, Object> args = new HashMap<>();
        args.put("feedId", FEED_ID);
        if (append) args.put("pageToken", pageToken);
        FeedUtil.invoke("getLivestreamList", args, new MethodChannel.Result() {
            @Override public void success(Object result) { onFeed((Map<?, ?>) result, append); }
            @Override public void error(String code, String message, Object details) {
                fail(code + ": " + message);
            }
            @Override public void notImplemented() { fail("getLivestreamList not implemented"); }
        });
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

    @SuppressWarnings("unchecked")
    private void onFeed(Map<?, ?> page, boolean append) {
        swipe.setRefreshing(false);
        loadingMore = false;
        Object token = page.get("nextToken");
        nextToken = token == null ? null : token.toString();

        List<?> items = (List<?>) page.get("items");
        if (items == null || items.isEmpty()) {
            if (!append) {
                statusView.setVisibility(View.VISIBLE);
                statusView.setText("No livestreams.");
                grid.removeAllViews();
            }
            return;
        }
        statusView.setVisibility(View.GONE);
        if (!append) grid.removeAllViews();
        for (Object raw : items) {
            grid.addView(buildCard((Map<String, Object>) raw));
        }
    }

    private void fail(String message) {
        swipe.setRefreshing(false);
        loadingMore = false;
        statusView.setVisibility(View.VISIBLE);
        statusView.setText("Error: " + message);
    }

    // --- Card view ------------------------------------------------------------

    private View buildCard(Map<String, Object> item) {
        String id = str(item, "id");
        String username = str(item, "username");
        String displayName = str(item, "displayName");
        String title = str(item, "title");
        String countryFlag = str(item, "countryFlag");

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

        String[] status = statusLabelColor(str(item, "status"), item);
        if (status != null) {
            cover.addView(pill(status[0], (int) Long.parseLong(status[1], 16)),
                    overlayLp(Gravity.TOP | Gravity.END));
        }
        String badge = topLeftBadge(item);
        if (badge != null) {
            cover.addView(pill(badge, badgeColor(item)), overlayLp(Gravity.TOP | Gravity.START));
        }
        cover.addView(pill(viewerText(num(item, "viewers")), 0xB3000000),
                overlayLp(Gravity.BOTTOM | Gravity.START));
        double score = dbl(item, "score");
        if (score > 0) {
            // Design: {flag} ★ {score} ({reviewCount}) at bottom-right.
            String flagPrefix = (countryFlag == null || countryFlag.isEmpty()) ? "" : countryFlag + " ";
            int reviews = num(item, "reviewCount");
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

    private void openUrl(String id) {
        if (frontendBase == null) {
            Toast.makeText(this, "frontend base not resolved yet", Toast.LENGTH_SHORT).show();
            return;
        }
        // Mirrors LivestreamSdk.buildLivestreamUrl: {frontend}/user/{id}/livestream
        String url = frontendBase
                + (frontendBase.endsWith("/") ? "" : "/")
                + "user/" + Uri.encode(id) + "/livestream";
        Toast.makeText(this, url, Toast.LENGTH_LONG).show();
    }

    /**
     * Requests the decrypted cover for {@code id} over the channel. The reply is
     * a {@code Uint8List}, which the standard codec delivers as a {@code byte[]}.
     * On success it decodes to a bitmap and slots an ImageView behind the
     * overlays (index 0), hiding the placeholder letter. The channel callback
     * lands on the UI thread, so the decode is pushed to {@link #coverExecutor}
     * and only the view updates run back on the UI thread.
     */
    private void loadCover(String id, FrameLayout cover, TextView initial) {
        Map<String, Object> args = new HashMap<>();
        args.put("livestreamId", id);
        FeedUtil.invoke("getCoverImage", args, new MethodChannel.Result() {
            @Override public void success(Object result) {
                if (!(result instanceof byte[])) return; // null = no cover
                final byte[] bytes = (byte[]) result;
                if (bytes.length == 0) return;
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
            @Override public void error(String c, String m, Object d) { }
            @Override public void notImplemented() { }
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

    /** status name -> {label, hex-argb-without-0x}; null hides the pill. */
    private String[] statusLabelColor(String status, Map<String, Object> item) {
        if (status == null) return null;
        switch (status) {
            case "free": return new String[]{"免費直播中", "CC000000"};
            case "performing": return new String[]{"表演中", "FF7C4DFF"};
            case "funding":
                int remaining = num(item, "fundingTarget") - num(item, "fundingProgress");
                return new String[]{remaining > 0 ? "剩 " + remaining + " 張" : "募資中", "FF7C4DFF"};
            case "exclusive": return new String[]{"獨家", "FF3A6DE0"};
            default: return null; // offline
        }
    }

    private String topLeftBadge(Map<String, Object> item) {
        if (bool(item, "isVipSponsor")) return "VIP";
        if (bool(item, "isNewbie")) return "NEW";
        if (bool(item, "hasToy")) return "TOY";
        return null;
    }

    private int badgeColor(Map<String, Object> item) {
        if (bool(item, "isVipSponsor")) return 0xFFB8860B;
        if (bool(item, "isNewbie")) return 0xFF2E7D32;
        return 0xFFAD1457;
    }

    private String viewerText(int viewers) {
        return viewers >= 1000 ? (viewers / 1000) + "k" : String.valueOf(viewers);
    }

    private int placeholderColor(String id) {
        float hue = Math.abs(id.hashCode() % 360);
        return Color.HSVToColor(new float[]{hue, 0.35f, 0.30f});
    }

    private static String str(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v == null ? null : v.toString();
    }

    private static int num(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v instanceof Number ? ((Number) v).intValue() : 0;
    }

    private static double dbl(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v instanceof Number ? ((Number) v).doubleValue() : 0;
    }

    private static boolean bool(Map<String, Object> m, String key) {
        return Boolean.TRUE.equals(m.get(key));
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}
