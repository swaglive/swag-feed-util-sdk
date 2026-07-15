# swag-feed-util-sdk

Livestream feed SDK for external integration.

> **Generated distribution artifact — do not edit here.** The source of truth is
> Swag's internal monorepo; this repo is force-synced each release. PRs here are
> overwritten.

Two host types, two forms:

| Your host | Use |
| --- | --- |
| **iOS — Flutter** | the `feed_util/` Dart package (git dependency) |
| **Android — Java** | the release AAR + facade in `android/` |

---

## Flutter (iOS) host

```yaml
# your app's pubspec.yaml
dependencies:
  feed_util:
    git:
      url: https://github.com/swaglive/swag-feed-util-sdk.git
      path: feed_util
      ref: v0.7.0        # pin a tag
```

Use the SDK directly — no MethodChannel on a Flutter host:

**1 · Initialize the SDK**

```dart
import 'package:feed_util/feed_util.dart';

// Create the SDK once and hold on to it. Tracker hosts + token come from Swag.
// There's no explicit init call — domains resolve lazily on the first fetch.
final sdk = LivestreamSdk(
  const LivestreamSdkConfig(
    trackerServers: ['<tracker hosts from Swag>'],
    trackerAuthToken: '<token from Swag>',
  ),
);
```

**2 · Fetch the feed (first page)**

```dart
// A page has `items` (the cards to render) and `nextToken` (the paging cursor).
final page = await sdk.getLivestreamList('user_livestream-v2');
final items = page.items;         // List<LivestreamItem>
var nextToken = page.nextToken;   // PageToken? — null when there are no more pages
```

**3 · Load the next page**

```dart
// Feed the previous page's nextToken back in to append the next page.
if (nextToken != null) {
  final next = await sdk.getLivestreamList('user_livestream-v2', pageToken: nextToken);
  items.addAll(next.items);
  nextToken = next.nextToken;
}
```

**4 · Get a cover image**

```dart
// Decrypted image bytes for one card (or null when it has no cover). Lazy —
// call it as the card scrolls into view, then decode with Image.memory.
final Uint8List? cover = await sdk.getCoverImage(item.id);
```

**5 · Get the livestream URL**

```dart
// The web page that plays a livestream; open it in a WebView.
final String url = sdk.buildLivestreamUrl(item.id);
```

**6 · Diagnostic logs (optional)**

```dart
// Observe the SDK's internal logs (severity + message) while integrating.
sdk.setLogListener((entry) => print('[${entry.severity.name}] ${entry.message}'));
```

Runnable demo (all of the above wired into a real UI): `cd feed_util/example &&
flutter pub get && flutter run`.

## Android (Java) host

`android/aar-repo/` is a **release** Maven repo holding the `FeedUtil` facade AAR
(`live.swag.feedutil:feed-util`) plus the Flutter module AAR it depends on. You
add **one dependency** and Gradle pulls the Flutter module transitively — no
source to copy, no separate Flutter AAR to declare.

**Add the SDK repository + dependency**

```kotlin
// settings.gradle.kts — resolve the AAR repo remotely off GitHub (no clone).
dependencyResolutionManagement {
    repositories {
        google(); mavenCentral()
        // The SDK's committed Maven repo, straight off GitHub (public repo).
        maven(url = uri("https://raw.githubusercontent.com/swaglive/swag-feed-util-sdk/v0.7.0/android/aar-repo"))
        // Flutter engine artifacts referenced by the AAR poms.
        maven(url = "https://storage.googleapis.com/download.flutter.io")
    }
}

// app/build.gradle.kts — one coordinate pulls the Flutter module transitively.
dependencies { implementation("live.swag.feedutil:feed-util:1.0") }
```

**Declare the INTERNET permission**

The release AAR does **not** inject it (Flutter's debug AAR does), so without it a
release build has no network and the feed fails with
`domain_tracker_server_not_found`:

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
```

Then drive the SDK through the typed `FeedUtil` API — each call returns plain
Java objects to a callback (on the main thread); the MethodChannel is hidden:

**1 · Start the engine + configure** (once, at launch)

```java
// Warm the headless Flutter engine — e.g. in Application.onCreate.
FeedUtil.start(context);

// Configure once with tracker hosts + token from Swag (the AAR bakes none).
LivestreamSdkConfig config = new LivestreamSdkConfig(trackerServers, token);
FeedUtil.configure(config, new CompletionCallback() {
    @Override public void onSuccess() { /* ready */ }
    @Override public void onError(FeedUtilException e) { /* e.getCode() */ }
});
```

**2 · Fetch the feed (first page)**

```java
FeedUtil.getLivestreamList("user_livestream-v2", new ResultCallback<LivestreamPage>() {
    @Override public void onSuccess(LivestreamPage page) {
        for (LivestreamItem item : page.getItems()) { /* render card */ }
        String nextToken = page.getNextToken();   // null = no more pages
    }
    @Override public void onError(FeedUtilException e) { /* e.getCode() */ }
});
```

**3 · Load the next page**

```java
// Hand the previous page's nextToken back to append the next page.
FeedUtil.getLivestreamList("user_livestream-v2", nextToken,
    new ResultCallback<LivestreamPage>() {
        @Override public void onSuccess(LivestreamPage page) { /* append items */ }
        @Override public void onError(FeedUtilException e) { }
    });
```

**4 · Get a cover image**

```java
// Decrypted image bytes for one card, or null when it has no cover. Lazy —
// call it as the card scrolls into view.
FeedUtil.getCoverImage(item.getId(), new ResultCallback<byte[]>() {
    @Override public void onSuccess(byte[] bytes) {
        if (bytes == null) return;                 // no cover
        Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
        // show bitmap…
    }
    @Override public void onError(FeedUtilException e) { }
});
```

**5 · Get the livestream URL**

```java
// The web page that plays a livestream; open it in a Custom Tab / WebView.
FeedUtil.buildLivestreamUrl(item.getId(), new ResultCallback<String>() {
    @Override public void onSuccess(String url) { /* open url */ }
    @Override public void onError(FeedUtilException e) { }
});
```

**6 · Diagnostic logs (optional)**

```java
// Observe the SDK's internal logs (severity + message) while integrating.
FeedUtil.setLogListener(entry ->
    Log.d("feed_util", "[" + entry.getSeverity() + "] " + entry.getMessage()));
```

**Tracker token / hosts** come from Swag. The AAR carries **no** baked token —
pass `trackerAuthToken` at runtime in `configure` (Android) or via
`LivestreamSdkConfig` (Flutter).
