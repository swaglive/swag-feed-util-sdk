# swag-feed-util-sdk

Livestream feed SDK for external integration.

> **Generated distribution artifact — do not edit here.** The source of truth is
> Swag's internal monorepo; this repo is force-synced each release. PRs here are
> overwritten.

Packages:

- **`feed_util/`** — the SDK you consume (`LivestreamSdk` interface + models).
  - **`feed_util/example/`** — a runnable demo app (`flutter run`) showing the
    feed grid, pull-to-refresh, load-more, and cover images.
- **`livestream_sdk_core/`** — its domain-tracker dependency (resolved
  automatically via a sibling path; you don't declare it).

## Flutter integration

```yaml
# your app's pubspec.yaml
dependencies:
  feed_util:
    git:
      url: https://github.com/swaglive/swag-feed-util-sdk.git
      path: feed_util
      ref: v0.1.0        # pin a tag
```

```dart
import 'package:feed_util/feed_util.dart';

final sdk = LivestreamSdk(
  const LivestreamSdkConfig(trackerServers: ['<tracker hosts from Swag>']),
);
final page = await sdk.getLivestreamList('user_livestream-v2');
// page.items / page.nextToken (load-more) / sdk.getCoverImage(id) /
// sdk.buildLivestreamUrl(id)
```

**Tracker auth token** (needed for live data): bake it with
`flutter build --dart-define=FEED_UTIL_TRACKER_AUTH_TOKEN=<token>`, or pass it at
runtime via `LivestreamSdkConfig.trackerAuthToken`. Ask your Swag contact for
the token and tracker hosts.

## Run the example

```sh
cd feed_util/example
flutter pub get
flutter run --dart-define=FEED_UTIL_TRACKER_AUTH_TOKEN=<token>
```

## Android (native) hosts

Native Android hosts don't use this Dart package — they embed the release
**AAR** + the `FeedUtil` Kotlin facade. Ask your Swag contact for those.
