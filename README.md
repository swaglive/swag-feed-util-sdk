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

- `android/aar-repo/` — the **release** AAR (a local Maven repo) your build
  resolves against; committed here so you get it by cloning.
- `android/feed-util-facade/` — the `FeedUtil` Kotlin facade to include in your
  host (channel glue; no business logic).
- `android/example/` — a runnable Java host demo, already wired to the two above.

Run the demo (Android Studio, or):

```sh
cd android/example && ./gradlew :app:installRelease
```

Wiring your own host (see `android/example` for the full version):

```kotlin
// settings.gradle.kts
maven(url = file("<path to>/android/aar-repo"))
maven(url = "https://storage.googleapis.com/download.flutter.io") // engine artifacts (network)

// app/build.gradle.kts
implementation("com.example.feed_util:flutter_release:1.0")
// + include android/feed-util-facade/src/main/kotlin
```

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
