# FeedUtil native Android example

Standalone Java host that consumes the committed `FeedUtil` facade AAR. The
facade owns the headless Flutter engine and exposes typed Java callbacks, so
the application does not use MethodChannel or parse maps directly.

The example demonstrates:

- readiness-safe, idempotent SDK initialization;
- supplying tracker configuration at runtime through the Java callback API;
- fetching and paginating typed `LivestreamPage` results;
- pull-to-refresh and a two-column card grid;
- lazy cover decoding away from the UI thread;
- sanitized SDK console diagnostics;
- requesting a development OTP on every card tap and opening the one-use
  SDK-built URL in an Android WebView.

## Prerequisites

- JDK 17 or newer (Android Studio's bundled JDK is suitable);
- Android SDK 36;
- an API 24 or newer emulator/device;
- an auth token from Swag, if the target environment requires one.

Create `local.properties` in this directory. It is gitignored:

```properties
sdk.dir=/absolute/path/to/your/Android/sdk
feedUtilTrackerAuthToken=<token-from-Swag>
```

The token becomes a `BuildConfig` value and is passed to
`LivestreamSdkConfig`; it is not baked into the AAR. Omit the token line when
Swag did not provide one for the environment.

## Build and run

```sh
cd android/example
./gradlew :app:assembleDebug
./gradlew :app:installDebug
```

You can also open `android/example` in Android Studio and run the `app`
configuration.

No Flutter build is required. `settings.gradle.kts` reads the already published
artifacts from the sibling `../aar-repo` and the Flutter engine repository.
Editing `feed_util` Dart source therefore does not change what this example
runs; use a newer published release to test a different AAR.

The card-tap dialog is development-only. Paste a fresh test OTP supplied via
the backend team's convenience flow. A production host fetches one from its
own server on each tap; it never places the affiliate signing key on the
device or implements the signed server-to-server exchange in mobile code.

## Code tour

- [`MainActivity.java`](app/src/main/java/live/swag/feedutil/example/MainActivity.java)
  initializes the SDK, loads pages and covers, and renders cards. Re-created
  activities may safely repeat `initialize` with the same config.
- [`WebViewActivity.java`](app/src/main/java/live/swag/feedutil/example/WebViewActivity.java)
  loads the watch URL unchanged and reports lifecycle plus controlled
  HTTP/network/TLS failure categories through sanitized diagnostics.
- [`app/build.gradle.kts`](app/build.gradle.kts) reads the local token and adds
  the single `live.swag.feedutil:feed-util:1.0` dependency.
- [`settings.gradle.kts`](settings.gradle.kts) configures the local Maven
  repository and Flutter engine artifacts.

The host manifest explicitly declares `android.permission.INTERNET`. Omitting
it is a common cause of `domain_unreachable` in release hosts.
The example sets `debugMode` in `LivestreamSdkConfig`; filter Logcat by
`FeedUtil` and inspect the structured `event=webview.*` entries when a
livestream page is blank, returns 404, or cannot connect. No diagnostic data is
stored or exported by the SDK or example.

For remote Maven integration in another application, see the
[Android integration guide](../../docs/android-integration.md).
