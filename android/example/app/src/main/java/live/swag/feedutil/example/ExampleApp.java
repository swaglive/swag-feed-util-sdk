package live.swag.feedutil.example;

import android.app.Application;

import live.swag.feedutil.FeedUtil;

/** Warms up the feed_util engine at launch (Java host). */
public class ExampleApp extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        FeedUtil.start(this);
    }
}
