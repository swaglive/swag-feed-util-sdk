package live.swag.feedutil

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Native entry point for the `feed_util` Flutter module on Android.
 *
 * Boots a headless [FlutterEngine] and exposes the module's API to the host
 * app over a [MethodChannel]. Host code should only talk to this facade —
 * never to the engine or channel directly.
 *
 * Callable from **Java** (`@JvmStatic`), since the Android integrator's host
 * app is Java:
 *
 * ```java
 * FeedUtil.start(context);
 * FeedUtil.invoke("ping", null, new MethodChannel.Result() {
 *     @Override public void success(Object result) { ... }
 *     @Override public void error(String c, String m, Object d) { ... }
 *     @Override public void notImplemented() { ... }
 * });
 * ```
 */
object FeedUtil {
    /** Channel name shared with the Dart side and the iOS entry point. */
    private const val CHANNEL_NAME = "feed_util/method"

    /**
     * Dart entrypoint function name — a headless entrypoint (no `runApp`),
     * annotated `@pragma('vm:entry-point')` in `lib/main.dart`.
     */
    private const val DART_ENTRYPOINT = "feedUtilHeadlessMain"

    private var engine: FlutterEngine? = null
    private var channel: MethodChannel? = null

    /** Whether the engine is running. From Java: `FeedUtil.isRunning()`. */
    @JvmStatic
    val isRunning: Boolean get() = engine != null

    /** Starts the headless Flutter engine. Safe to call repeatedly. */
    @JvmStatic
    @Synchronized
    fun start(context: Context) {
        if (engine != null) return

        val engine = FlutterEngine(context.applicationContext)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(
                io.flutter.FlutterInjector.instance()
                    .flutterLoader()
                    .findAppBundlePath(),
                DART_ENTRYPOINT,
            ),
        )

        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(::handle)

        this.engine = engine
        this.channel = channel
    }

    /** Stops the engine and releases resources. */
    @JvmStatic
    @Synchronized
    fun stop() {
        channel?.setMethodCallHandler(null)
        engine?.destroy()
        channel = null
        engine = null
    }

    /**
     * Invokes a Dart-side method. Call [start] first.
     *
     * `@JvmOverloads` generates Java overloads for the default args, so Java
     * can call `invoke("ping")`, `invoke("ping", args)`, or the full form.
     */
    @JvmStatic
    @JvmOverloads
    fun invoke(
        method: String,
        arguments: Any? = null,
        callback: MethodChannel.Result? = null,
    ) {
        val channel = checkNotNull(channel) {
            "FeedUtil.start() must be called before invoke"
        }
        channel.invokeMethod(method, arguments, callback)
    }

    /** Handles calls initiated from the Dart side. */
    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            else -> result.notImplemented()
        }
    }
}
