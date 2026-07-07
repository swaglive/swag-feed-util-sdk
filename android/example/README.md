# FeedUtilExample (Android)

Native **Java** host app (matching the Android integrator) embedding the
`feed_util` Flutter module via prebuilt AARs. App code (`ExampleApp.java`,
`MainActivity.java`) is Java; it calls the `FeedUtil` facade, which is Kotlin
but exposed `@JvmStatic` so Java calls `FeedUtil.start(ctx)` /
`FeedUtil.invoke(...)` directly. The build compiles
`native/android/feed-util/src/main/kotlin` directly (the wrapper stays
single-sourced) and pulls
`com.example.feed_util:flutter_debug|flutter_release:1.0` from the module's
local Maven repo.

## Build & run

```sh
# 1. Build the module AARs (from apps/feed_util)
flutter build aar

# 2. Build/run the example (from examples/android)
./gradlew :app:installDebug  && adb shell am start -n live.swag.feedutil.example/.MainActivity
```

Or open `examples/android` in Android Studio and run `app`.

## Notes

- Repositories are wired in `settings.gradle.kts`:
  `../../build/host/outputs/repo` (module AARs) +
  `download.flutter.io` (Flutter engine artifacts).
- Rerun `flutter build aar` after any Dart change — the AARs are snapshots,
  not live source.
- The app warms the engine in `ExampleApp` (`FeedUtil.start(this)`), then
  `MainActivity` calls `configure` + `getLivestreamList("user_livestream-v2")`
  over the channel and renders the returned items as a card grid (title,
  streamer, viewers, score, status). Cover images are placeholders until
  `getCoverImage` lands (WS-B/B6); tapping a card toasts its web-view URL.
- **Real data needs the tracker auth token** baked into the AAR:
  `cd ../.. && flutter build aar --dart-define=FEED_UTIL_TRACKER_AUTH_TOKEN=YOUR_TOKEN`
  (rerun before installing). Without it the tracker can't resolve.
- Versions: **AGP 8.10.1** (kept below the `.android` host's 8.11.1 so it syncs
  in Android Studio releases that cap at AGP 8.10.x; bump when AS catches up),
  Kotlin 2.2.20, Gradle 8.14, compile/target SDK 36, min SDK 24.
