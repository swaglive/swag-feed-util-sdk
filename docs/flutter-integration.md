# Flutter integration

This guide is for a Flutter application that ships on iOS and calls the Dart
SDK directly. It assumes the [onboarding values](../README.md#what-you-need-from-swag)
have already been provided.

For the exact member contract, see the [API reference](api-reference.md).

## 1. Add the pinned package

The package requires Dart 3.8 or newer. Pin the release tag so a later SDK sync
cannot silently change the application build.

```yaml
# pubspec.yaml
dependencies:
  feed_util:
    git:
      url: https://github.com/swaglive/swag-feed-util-sdk.git
      path: feed_util
      ref: v0.9.1
```

Then resolve and analyze the host:

```sh
flutter pub get
flutter analyze
```

## 2. Create one SDK instance

Keep one instance at application or feature-composition scope. Domain and
cover caches belong to that instance, so constructing one per page or widget
causes unnecessary work.

```dart
import 'package:feed_util/feed_util.dart';

final livestreamSdk = LivestreamSdk(
  const LivestreamSdkConfig(
    trackerServers: ['<tracker-host-from-Swag>'],
    trackerAuthToken: '<runtime-token-from-Swag>', // Omit when not required.
    // trackerLabels: ['<label-from-Swag>'],
    // debugMode: true, // Temporary troubleshooting only.
  ),
);
```

Do not place a real token in source. Inject it from the host's existing secret
or runtime-configuration mechanism. `trackerServers` must contain at least one
non-empty host or URL.

## 3. Load and render page one

The first request also resolves reachable service domains and can therefore be
slower than later requests.

```dart
List<LivestreamItem> items = [];
PageToken? nextToken;

Future<void> loadFirstPage({bool refresh = false}) async {
  try {
    final page = await livestreamSdk.getLivestreamList(
      '<feed-id-from-Swag>',
      bustCache: refresh,
    );
    items = page.items;
    nextToken = page.nextToken;
    // Publish the loaded or empty state to your UI.
  } on LivestreamSdkException catch (error) {
    // Preserve a retry action only when error.code.isRetryable is true.
    showFeedError(error.message, canRetry: error.code.isRetryable);
  }
}
```

Host state must distinguish:

| State | Host behavior |
| --- | --- |
| Loading | Keep a progress or skeleton state visible |
| Loaded | Render items in backend order |
| Empty | Show a valid no-active-streams state |
| Retryable error | Show an action that calls the same operation again |
| Non-retryable error | Surface a stable error and correct the call order/configuration |

Offline streams are filtered by the SDK. A short or empty page is not proof of
a broken integration.

## 4. Append later pages

Treat `nextToken` as opaque. Pass it back unchanged and guard against duplicate
load-more requests.

```dart
Future<void> loadNextPage() async {
  final token = nextToken;
  if (token == null) return;

  try {
    final page = await livestreamSdk.getLivestreamList(
      '<feed-id-from-Swag>',
      pageToken: token,
    );
    items = [...items, ...page.items];
    nextToken = page.nextToken;
  } on LivestreamSdkException catch (error) {
    // Keep the existing items and retry the same token when allowed.
    showPaginationError(error.message, canRetry: error.code.isRetryable);
  }
}
```

Do not use `bustCache` for pagination. For pull-to-refresh, call
`loadFirstPage(refresh: true)`, replace existing items, and use only the new
page's token.

## 5. Load covers lazily

Ask for a cover only when its card is visible. The result is raw image bytes;
`null` is a normal no-cover result.

```dart
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

Future<Widget> coverFor(LivestreamItem item) async {
  try {
    final Uint8List? bytes = await livestreamSdk.getCoverImage(item.id);
    return bytes == null
        ? const Placeholder()
        : Image.memory(bytes, fit: BoxFit.cover);
  } on LivestreamSdkException {
    return const Placeholder();
  }
}
```

Keep the placeholder while loading, when the result is `null`, and after a
failure. The SDK caches and coalesces cover requests in memory.

## 6. Apply field fallbacks

The host controls visual design but must handle nullable data explicitly.

| Field | Recommended functional fallback |
| --- | --- |
| `displayName` | Use `username` |
| `title` | Use a localized untitled label or omit the title row |
| `score` | Omit rating when `null` |
| `countryFlag` | Omit the flag when `null` |
| `fundingTarget`, `fundingProgress` | Render only when both apply to a funding show |
| cover result | Keep a host-owned placeholder when `null` or failed |

Use `LivestreamItem.id` for cover and watch-URL calls. Do not substitute
`username`, `sessionId`, or a value from a different SDK instance.

## 7. Get an OTP from your server

In the card tap handler, ask your own backend for a fresh room OTP. Your
backend performs the signed `POST /affiliate/v1/login` request described in
the backend-owned reference linked from the
[Partner Integration Hub](https://app.notion.com/p/3c9926e209a3819b9673ea479a169997).
It sends only the resulting OTP to the app—not the affiliate signing key or
full redirect URL. The mobile SDK does not perform that server-to-server
request.

| Credential | SDK location | Purpose | Lifetime |
| --- | --- | --- | --- |
| Tracker auth token | `LivestreamSdkConfig` | Domain Tracker requests | Long-lived, per environment |
| OTP | `buildLivestreamUrl` | Log the member into one room open | Single-use and time-limited |

Use the onboarding tracker servers as static SDK configuration and ignore
`domain_tracker_config.domains` in the affiliate login response. Domain
Tracker selects the healthy API and frontend hosts for the current network and
region.

Fetch on every tap, not while loading the feed. An OTP is time-limited and is
consumed when the room opens, so never cache or reuse either the OTP or built
URL.

## 8. Open a livestream

Build the URL only from an item returned by this SDK instance, after at least
one successful feed request.

```dart
try {
  final otp = await myServer.fetchSwagOtp(memberId);
  final url = livestreamSdk.buildLivestreamUrl(item.id, otp: otp);
  openHostWebView(url);
} on LivestreamSdkException catch (error) {
  showOpenError(error.message);
}
```

Load the URL unchanged and only once. When the WebView closes, discard it. A
later open—including the same room—must fetch a fresh OTP and build a fresh
URL. A 401 from the room OTP login normally means the OTP is expired or was
already consumed. The SDK emits no room-closed event because the host owns the
WebView.

The runnable [`feed_util/example`](../feed_util/example) contains the
reference host WebView implementation; WebView configuration remains an
example concern rather than part of the SDK API contract.

## 9. Handle errors and diagnostics

The SDK performs no hidden request retry. Use
`LivestreamSdkErrorCode.isRetryable` to decide whether the host should offer a
retry action. See [Troubleshooting](troubleshooting.md) for the complete error
matrix and sanitized console events.

Enable diagnostics only while investigating an issue:

```dart
const LivestreamSdkConfig(
  trackerServers: ['<tracker-host-from-Swag>'],
  debugMode: true,
);
```

`debugMode` is immutable for an SDK instance. Create the production instance
with it disabled after troubleshooting.

## Acceptance checklist

- [ ] The dependency pins the intended release tag.
- [ ] No token is committed to source control.
- [ ] The affiliate signing key and full redirect URL never reach the app.
- [ ] One SDK instance is reused.
- [ ] Loading, empty, retryable-error, and non-retryable-error states render.
- [ ] Page one loads with the supplied feed ID.
- [ ] A non-null next token appends one page without duplicate requests.
- [ ] Pull-to-refresh replaces page one and uses `bustCache: true`.
- [ ] Visible cards load covers and preserve placeholders for `null`/failure.
- [ ] Nullable model fields use host fallbacks.
- [ ] Every card tap fetches a fresh OTP from the partner server.
- [ ] Tapping a returned item opens the unchanged SDK URL once, then discards it.
- [ ] Reopening any room fetches a new OTP and builds a new URL.
- [ ] Diagnostics can be enabled without exposing environment or user data.

Run the complete release example before shipping:

```sh
cd feed_util/example
flutter pub get
flutter analyze
flutter test
flutter run -d <ios-device-id> \
  --dart-define=FEED_UTIL_TRACKER_AUTH_TOKEN=<token-from-Swag>
```
