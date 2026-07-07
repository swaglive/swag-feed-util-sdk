# FeedUtilExample (Flutter host)

Standalone Flutter app that simulates an **external Flutter consumer** of the
`feed_util` Livestream SDK: it adds `feed_util` as a dependency and calls
`LivestreamSdk` directly — no MethodChannel, no native bridge (that path is
only for native hosts like `examples/android`). This is the **iOS integrator's
path**.

Pub package name is `feed_util_flutter_example` (it can't be the literal
`flutter` — that collides with the Flutter SDK package); the folder is
`flutter` to match `android/` and `ios/`.

## Run

```sh
# from apps/feed_util/examples/flutter — real data needs the tracker auth token
flutter run -d <ios-id> --dart-define=FEED_UTIL_TRACKER_AUTH_TOKEN=YOUR_TOKEN
# or VS Code → "feed_util host example (iOS)"
```

- Simulator needs no signing; a real device needs a signing team
  (`open ios/Runner.xcworkspace`).
- Hot reload works — being a Flutter host, no AAR/xcframework rebuild after Dart
  edits (contrast the Android example).

The screen renders the live **`user_livestream-v2`** feed as a card grid
(`getLivestreamList`), modeled on the in-app livestream tab: title, streamer,
viewers, score, status badge, country flag. Cover images are placeholders until
`getCoverImage` lands (WS-B/B6). Tapping a card shows its `buildLivestreamUrl`.
Without the token the tracker can't resolve and you'll see the error view.

## How the dependency resolves

This example is a **pub workspace member** (root `pubspec.yaml` `workspace:`
list), so `feed_util: any` resolves to the local module. A real external app
uses a git/published dependency instead — see `../../INTEGRATION.md`.
