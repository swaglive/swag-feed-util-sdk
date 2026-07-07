# swag-feed-util-sdk

Livestream feed SDK for external integration.

> **Generated distribution artifact — do not edit here.** The source of truth is
> Swag's internal monorepo; this repo is produced by a release tool and force-
> synced each version. PRs against this repo will be overwritten.

Two packages:

- **`feed_util/`** — the SDK you consume (`LivestreamSdk` interface + models).
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
for (final item in page.items) {
  // item.title, item.score, item.reviewCount, ...
  final coverBytes = await sdk.getCoverImage(item.id);
  final url = sdk.buildLivestreamUrl(item.id);
}
// page.nextToken → pass as getLivestreamList(..., pageToken:) for load-more.
```

**Tracker auth token** (needed for live data): bake it at build time with
`flutter build --dart-define=FEED_UTIL_TRACKER_AUTH_TOKEN=<token>`, or pass it at
runtime via `LivestreamSdkConfig.trackerAuthToken` (overrides the build value).
Ask your Swag contact for the token and tracker hosts.

## Android (native) hosts

Native Android hosts don't use this Dart package — they embed the release
**AAR** + the `FeedUtil` Kotlin facade. Ask your Swag contact for those artifacts.
