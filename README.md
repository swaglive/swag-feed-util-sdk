# Swag Feed Util SDK

Use this SDK to show Swag livestream cards in an external application. It
finds reachable Swag services, loads the feed, decrypts cover images, and
builds the URL that the host opens for a selected livestream.

The SDK does not provide a native player, chat UI, authentication UI, or card
design. The host owns those presentation decisions.

> This repository is a generated release artifact. Pin a release tag and do
> not commit changes here; the next release replaces the repository contents.

## Choose one integration path

| Host application | SDK form | Guide | Runnable example |
| --- | --- | --- | --- |
| Flutter app shipping on iOS | Dart package | [Flutter integration](docs/flutter-integration.md) | [`feed_util/example`](feed_util/example) |
| Native Android app in Kotlin or Java | AAR with typed facade | [Android integration](docs/android-integration.md) | [`android/example`](android/example) |

Native iOS and direct MethodChannel integration are not supported. Android
hosts use `FeedUtil`; Flutter hosts use `LivestreamSdk` directly.

## What you need from Swag

Ask your Swag contact for these values before starting. Environment values are
not stable SDK constants and must not be copied from an example application.

| Value | Required | Secret | Source-control rule | Example shape |
| --- | --- | --- | --- | --- |
| Release tag | Yes | No | Pin it in the dependency | `v1.2.3` |
| Tracker servers | Yes | No | Store as environment configuration | `tracker.example.com` |
| Tracker auth token | Environment-dependent | Yes | Runtime or ignored local configuration only | Opaque string |
| Tracker labels | Environment-dependent | No | Store as environment configuration | `global`, `prod` |
| Feed ID | Yes | No | Store as product configuration | `user_livestream-v2` |
| Room OTP | Every room open | Yes | Fetch at runtime from the partner server; never store or reuse | Opaque string |

Never commit the tracker token. Do not log any of these values while
troubleshooting.

### Two credentials, two purposes

| Credential | Given to | Used for | Lifetime |
| --- | --- | --- | --- |
| Tracker auth token | SDK configuration | Domain Tracker requests only | Long-lived, per environment |
| OTP | `buildLivestreamUrl` | Log the partner member into one room open | Single-use and time-limited |

The partner's server obtains an OTP from Swag's affiliate login API and sends
only the OTP to the app. The affiliate signing key and full redirect URL must
stay off the device. The mobile SDK does not implement this server-to-server
exchange, validate the OTP, or refresh it. Use the backend-owned
`POST /affiliate/v1/login` reference linked from the
[FeedUtil SDK Partner Integration Hub](https://app.notion.com/p/3c9926e209a3819b9673ea479a169997)
for its exact request and response contract.

Keep using the tracker servers supplied during onboarding. Ignore
`domain_tracker_config.domains` from the affiliate login response; Domain
Tracker remains responsible for selecting healthy API and frontend hosts for
the device's current network and region.

## Integration outcome

A complete host integration must:

1. create or initialize one application-scoped SDK;
2. load the first page and represent loading, empty, error, and retry states;
3. pass each opaque `nextToken` back unchanged to append later pages;
4. use `bustCache` only for an explicit first-page refresh;
5. fetch cover bytes lazily and keep a placeholder when no cover is available;
6. fetch a fresh OTP from the partner server when the user taps a card;
7. build the watch URL from that item and OTP;
8. load that URL once and unchanged in the host-owned WebView;
9. discard the URL after use and fetch a new OTP for every later open;
10. enable sanitized diagnostics temporarily when investigating a failure.

The first feed request is normally slower because it also discovers reachable
service domains. Resolved domains and covers are cached in memory for the SDK
instance.

## Documentation

- [Flutter integration](docs/flutter-integration.md): installation and the
  complete Flutter/iOS host flow.
- [Android integration](docs/android-integration.md): AAR setup, Kotlin
  coroutines, Java callbacks, and lifecycle.
- [API reference](docs/api-reference.md): exact parameters, results,
  nullability, errors, and threading contracts.
- [Troubleshooting](docs/troubleshooting.md): stable diagnostic events,
  console/Logcat capture, and symptom lookup.

## Compatibility snapshot

| Surface | Minimum host requirement | Release example verified with |
| --- | --- | --- |
| Flutter package | Dart 3.8 or newer | Flutter 3.41.6 |
| Native Android | API 24, Java 17 | compile/target SDK 36, Gradle 8.14, AGP 8.10.1 |
| Kotlin host | Kotlin 2.2 or newer | Kotlin 2.2.20 |
| Java host | Java 17 source/bytecode | JDK 17 or newer |

The verified toolchain is not a demand that every host use exactly those
versions. The minimum column is the support boundary. See each platform guide
for details.

## Validate before shipping

Use the same release tag that the application will ship. A successful smoke
test renders an active page, replaces available cover placeholders, appends a
later page when a token exists, refreshes page one, and opens an SDK-built URL.
An empty feed can be valid when no stream is active; use diagnostics before
treating it as an integration failure.

Each platform guide ends with a concrete acceptance checklist.

This release contains a breaking API change: `buildLivestreamUrl` requires an
OTP for each call. Hosts must complete the partner-server OTP flow before
upgrading; anonymous room URLs are no longer available.

## Common integration failures

- Reusing an OTP or reopening a previously built room URL. Fetch a fresh OTP
  and build a new URL for every room open.
- Fetching the OTP while loading the feed instead of in the card tap handler.
- Sending the affiliate signing key or full redirect URL to the mobile app.
- Replacing onboarding tracker servers with `domain_tracker_config.domains`
  from the affiliate login response.
- Rewriting the API/frontend host or query chosen by the SDK.

## Release contents

| Path | Purpose |
| --- | --- |
| `feed_util/` | Public Dart package |
| `livestream_sdk_core/` | Pure-Dart implementation dependency |
| `android/aar-repo/` | Versioned Maven artifacts for Android hosts |
| `feed_util/example/` | Runnable Flutter/iOS host |
| `android/example/` | Runnable native Java host |
| `docs/` | Public integration and support guides |
| `CHANGELOG.md` | Release history and source revision |

Always pin a tag. Files on the default branch represent only the newest synced
release, and the upstream source revision for a release is recorded in
`.source`.
