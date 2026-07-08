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
      ref: v0.2.0        # pin a tag
```

```dart
import 'package:feed_util/feed_util.dart';

final sdk = LivestreamSdk(
  const LivestreamSdkConfig(
    trackerServers: ['<tracker hosts from Swag>'],
    trackerAuthToken: '<token from Swag>',
  ),
);
final page = await sdk.getLivestreamList('user_livestream-v2');
// page.items / page.nextToken (load-more) / sdk.getCoverImage(id) /
// sdk.buildLivestreamUrl(id)
```

Runnable demo: `cd feed_util/example && flutter pub get && flutter run`.

## Android (Java) host

The `android/` folder is a self-contained delivery:

- `android/aar-repo/` — a **release** Maven repo holding the `FeedUtil` facade
  AAR (`live.swag.feedutil:feed-util`) + the Flutter module AAR it depends on.
- `android/example/` — a runnable Java host demo, already wired to it.

You add **one dependency** (`feed-util`); Gradle pulls the Flutter module
transitively — no source to copy, no separate Flutter AAR to declare.

Run the demo (Android Studio, or):

```sh
cd android/example && ./gradlew :app:installRelease
```

Wiring your own host — pull it **remotely via Gradle**, no clone needed (this
repo's `android/aar-repo/` is a valid Maven layout served over HTTP):

```kotlin
// settings.gradle.kts
dependencyResolutionManagement {
    repositories {
        google(); mavenCentral()
        // The SDK's committed Maven repo, straight off GitHub (public repo).
        maven(url = uri("https://raw.githubusercontent.com/swaglive/swag-feed-util-sdk/v0.3.0/android/aar-repo"))
        // Flutter engine artifacts referenced by the AAR poms.
        maven(url = "https://storage.googleapis.com/download.flutter.io")
    }
}

// app/build.gradle.kts — one coordinate pulls the Flutter module transitively
dependencies { implementation("live.swag.feedutil:feed-util:1.0") }
```

(Alternatively clone the repo and point at the local dir:
`maven(url = file("<path>/android/aar-repo"))` — that's what `android/example`
uses so it runs straight after cloning.)

```java
FeedUtil.start(context);                         // warm the engine at launch
Map<String,Object> cfg = new HashMap<>();
cfg.put("trackerServers", trackerServers);
cfg.put("trackerAuthToken", token);              // AAR has no baked token
FeedUtil.invoke("configure", cfg, result);       // then getLivestreamList, ...
```

**Tracker token / hosts** come from Swag. The AAR carries **no** baked token —
pass `trackerAuthToken` at runtime in `configure` (Android) or via
`LivestreamSdkConfig` (Flutter).
