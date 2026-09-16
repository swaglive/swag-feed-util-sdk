# FeedUtil Flutter host example

Runnable Flutter/iOS consumer of the public `feed_util` Dart API. It does not
use the MethodChannel or Android facade.

The example demonstrates:

- creating one `LivestreamSdk` instance;
- sanitized console diagnostics and error/retry states;
- first-page loading, pull-to-refresh, and token pagination;
- lazy decrypted cover images with placeholders;
- card status, viewer, rating, badge, and funding metadata;
- requesting a development OTP on each card tap and opening the one-use
  SDK-built livestream URL in an in-app web view.

## Run

Use Flutter with Dart 3.8 or newer. Add the tracker token when the target
environment requires one.

```sh
cd feed_util/example
flutter pub get
flutter devices
flutter run -d <ios-device-id> \
  --dart-define=FEED_UTIL_TRACKER_AUTH_TOKEN=<token-from-Swag>
```

The SDK reads that define as its fallback token; the example does not write it
to disk. Omit the `--dart-define` line when Swag did not provide a token for the
environment. A simulator needs no signing. For a physical device, open
`ios/Runner.xcworkspace` and select a signing team if prompted.

The example feed id and non-secret tracker hosts are declared near the top of
[`lib/main.dart`](lib/main.dart). Replace them only when Swag gives you values
for a different environment.

The example ships with a development-only default OTP (`_devOtp` near the top
of `lib/main.dart`) so every card tap opens the room without typing. Set it to
an empty string to get the paste dialog instead, then paste a fresh test OTP
supplied via the backend team's convenience flow. A production host fetches one from its
own server on each tap; the mobile app never stores an affiliate signing key
or implements the signed server-to-server request.

## Dependency setup

This example uses the sibling SDK source so local Dart changes are visible
immediately:

```yaml
dependencies:
  feed_util:
    path: ../
```

An external application should use a pinned Git release instead. See the
[Flutter integration guide](../../docs/flutter-integration.md).

## Expected behavior

The console first shows domain-resolution events. Active cards then appear in a
two-column grid, covers replace their placeholders, and scrolling near the end
loads another page when `nextToken` is present. Pull-to-refresh replaces page
one; tapping a card asks for a fresh OTP and opens its web page once. Close the
page and use a new OTP before opening any room again. The same console stream records main
WebView page start/finish events and failed HTTP/network requests with stable
`event=webview.*` codes.

If the view is empty or reports `domain_unreachable`, inspect the sanitized
events before changing UI code. Verify network connectivity, token, tracker
hosts, and whether the feed currently contains active streams.
For a blank or unreachable livestream page, look for an HTTP status or
DNS/timeout/TLS categories in the `event=webview.*` entries. WebView URLs and
free-form error descriptions never enter the diagnostic API.
