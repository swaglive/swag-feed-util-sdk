# Public API reference

This document defines the supported application-facing contract. Flutter
hosts import `package:feed_util/feed_util.dart`; Android hosts import types from
`live.swag.feedutil`. Internal `src/` libraries, FlutterEngine, MethodChannel,
and Maven coordinates other than the facade are not public API.

## Cross-platform operation map

| Operation | Flutter | Android Kotlin | Android Java |
| --- | --- | --- | --- |
| Initialize | `LivestreamSdk(config)` | `FeedUtil.initialize(context, config)` | `FeedUtil.initialize(context, config, callback)` |
| First/next page | `getLivestreamList` | suspend `getLivestreamList` | callback `getLivestreamList` overloads |
| Cover | `getCoverImage` | suspend `getCoverImage` | callback `getCoverImage` |
| Watch URL | `buildLivestreamUrl` | suspend `buildLivestreamUrl` | callback `buildLivestreamUrl` |
| WebView event | `reportWebViewEvent` | `reportWebViewEvent` | `reportWebViewEvent` |
| Release | Application-scoped instance | `FeedUtil.shutdown()` | `FeedUtil.shutdown()` |

The SDK performs no automatic request retry. Retryable error metadata is part
of the public contract.

## Configuration

### `LivestreamSdkConfig`

| Member | Type | Required | Contract |
| --- | --- | --- | --- |
| `trackerServers` | List of strings | Yes | At least one non-empty host or full URL supplied by Swag |
| `trackerAuthToken` | Nullable string | No | Runtime override supplied only when the target environment requires it |
| `trackerLabels` | Nullable list of strings | No | Resource filters supplied by Swag; `null` accepts all labels |
| `debugMode` | Boolean | No | Defaults to `false`; enables sanitized console diagnostics for this SDK lifecycle |

Configuration is immutable after Flutter construction or Android
initialization. Never commit or log a real auth token.

## Flutter API

### `LivestreamSdk(LivestreamSdkConfig config)`

Creates one application-scoped SDK. Construction is synchronous; domain
resolution happens lazily on the first feed request. Invalid tracker server
configuration throws `LivestreamSdkException(invalidArgument)`.

### `Future<LivestreamPage> getLivestreamList(...)`

```dart
Future<LivestreamPage> getLivestreamList(
  String feedId, {
  PageToken? pageToken,
  bool bustCache = false,
});
```

- `feedId` must be non-empty and supplied by Swag.
- `pageToken == null` requests page one.
- A token must come from the previous page and be passed back unchanged.
- `bustCache` is for explicit page-one refresh only.
- The first request also resolves service domains.
- Returned items preserve backend feed order after offline items are removed.
- Throws `LivestreamSdkException`; inspect `code` and `code.isRetryable`.

### `Future<Uint8List?> getCoverImage(String livestreamId)`

- Pass a non-empty `LivestreamItem.id` from this SDK instance.
- Returns decrypted image bytes.
- Returns `null` for no current cover, an unknown id, or a cover not found.
- Requests for the same id are coalesced and cached in memory.
- Transport/decryption failures throw `LivestreamSdkException`.

### `String buildLivestreamUrl(String livestreamId, {required String otp})`

- Call after a successful feed request.
- Pass an id returned by this SDK instance.
- Pass a fresh, non-blank, single-use OTP for this room open.
- Returns a self-contained URL that must be loaded unchanged.
- Throws `illegalState` before domains are resolved.
- Throws `invalidArgument` for an empty/unknown id or blank OTP.
- The SDK does not fetch, validate, store, refresh, or log the OTP.
- Discard the URL after opening it. Every later open requires a new OTP and URL.

### `void reportWebViewEvent(WebViewLogEvent event)`

Reports a significant event from the host-owned livestream WebView to the
sanitized diagnostic console when `debugMode` is enabled. The event API accepts
no URL or free-form description.

## Android lifecycle API

### `FeedUtil.initialize`

Kotlin:

```kotlin
suspend fun initialize(
    context: Context,
    config: LivestreamSdkConfig,
)
```

Java:

```java
static void FeedUtil.initialize(
    Context context,
    LivestreamSdkConfig config,
    CompletionCallback callback
)
```

The implementation uses `context.applicationContext`. It starts the internal
engine, waits for Dart readiness, applies config, and completes on the Android
main thread. Kotlin success returns `Unit`; failure throws
`FeedUtilException`. Java receives `onSuccess` or `onError`.

Calls with the same configuration are idempotent, including while an earlier
call is still initializing. A different config returns `ILLEGAL_STATE` until
`shutdown` is called. Empty/blank tracker servers return `INVALID_ARGUMENT`.

### `FeedUtil.isInitialized`

Kotlin Boolean property; Java method `FeedUtil.isInitialized()`. It becomes
true only after initialization has completed successfully.

### `FeedUtil.shutdown()`

Destroys the internal engine, clears domain/cover/URL state, and returns the
facade to its uninitialized state. It is safe to call repeatedly. Pending
initialization callbacks receive `ILLEGAL_STATE`.

Normal applications retain the initialized SDK for the process lifetime.

## Android feature API

All Java callbacks are delivered on the Android main thread. Kotlin suspend
functions resume or throw using the caller's coroutine continuation. Calling a
feature method before successful initialization returns/throws
`ILLEGAL_STATE`.

### `getLivestreamList`

Kotlin:

```kotlin
suspend fun getLivestreamList(
    feedId: String,
    pageToken: String? = null,
    bustCache: Boolean = false,
): LivestreamPage
```

Java overloads:

```java
FeedUtil.getLivestreamList(feedId, callback);
FeedUtil.getLivestreamList(feedId, pageToken, callback);
FeedUtil.getLivestreamList(feedId, pageToken, bustCache, callback);
```

The feed, pagination, refresh, ordering, and errors match the Flutter method.
`pageToken` is a nullable opaque string on Android.

### `getCoverImage`

Kotlin returns `ByteArray?`; Java calls:

```java
FeedUtil.getCoverImage(livestreamId, ResultCallback<byte[]> callback);
```

`null` has the same no-cover/unknown-id meaning as Flutter. An empty id returns
`INVALID_ARGUMENT`.

### `buildLivestreamUrl`

Kotlin returns `String`; Java calls:

```kotlin
FeedUtil.buildLivestreamUrl(livestreamId, otp)
```

```java
FeedUtil.buildLivestreamUrl(livestreamId, otp, ResultCallback<String> callback);
```

Call only with an item id returned after initialization. Unknown/empty ids
or a blank OTP return `INVALID_ARGUMENT`; OTP validation occurs before bridge
or network work. Calling before initialization returns `ILLEGAL_STATE`. Java
callbacks are delivered on the main thread. The supplied OTP is passed through
without trimming and is query-encoded in the returned URL.

### `reportWebViewEvent`

Synchronous Kotlin/Java method accepting `WebViewLogEvent`. It records only
sanitized fields when diagnostics are enabled.

## Page and item models

### `LivestreamPage`

| Member | Flutter | Android | Contract |
| --- | --- | --- | --- |
| `items` | `List<LivestreamItem>` | `List<LivestreamItem>` | Visible cards in backend feed order |
| `nextToken` | `PageToken?` | `String?` | Opaque next-page cursor; `null` means no later page |

### `LivestreamItem`

| Member | Type/nullability | Contract |
| --- | --- | --- |
| `id` | Non-null string | Stable value for cover and watch-URL methods |
| `username` | Non-null string | Account handle and display-name fallback |
| `displayName` | Nullable string | Preferred display name |
| `title` | Nullable string | Current stream title |
| `sessionId` | Nullable string | Current live session identifier |
| `status` | Enum | `free`, `exclusive`, `performing`, `funding`, `offline`; Android also has forward-compatible `UNKNOWN` |
| `viewers` | Integer | Current viewer count |
| `score` | Nullable number | Average rating from 0.0 to 5.0 |
| `reviewCount` | Integer | Number of ratings behind `score` |
| `badges` | List of strings | Raw backend badge tags |
| `countryFlag` | Nullable string | Country rendered as a flag emoji when known |
| `isVipSponsor` | Boolean | VIP sponsor badge flag |
| `isNewbie` | Boolean | New streamer badge flag |
| `hasToy` | Boolean | Interactive toy badge flag |
| `fundingTarget` | Nullable integer | Funding-show ticket goal |
| `fundingProgress` | Nullable integer | Funding-show tickets sold |

The cover and watch URL are intentionally resolved through SDK methods rather
than stored in the item model.

## Error contract

Flutter errors are `LivestreamSdkException` with
`LivestreamSdkErrorCode`. Android errors are `FeedUtilException` with
`FeedUtilErrorCode`, plus a stable snake-case `wireCode`.

| Wire code | Flutter enum | Android enum | Retryable | Meaning |
| --- | --- | --- | --- | --- |
| `invalid_argument` | `invalidArgument` | `INVALID_ARGUMENT` | No | A required value or item id is invalid |
| `illegal_state` | `illegalState` | `ILLEGAL_STATE` | No | Initialization/call order is invalid |
| `domain_unreachable` | `domainUnreachable` | `DOMAIN_UNREACHABLE` | Yes | No configured service domain is reachable |
| `network_timeout` | `networkTimeout` | `NETWORK_TIMEOUT` | Yes | A transport request timed out |
| `network_failure` | `networkFailure` | `NETWORK_FAILURE` | Yes | A transport request failed |
| `bad_response` | `badResponse` | `BAD_RESPONSE` | No | Backend/bridge response shape is unsupported |
| `decryption_failure` | `decryptionFailure` | `DECRYPTION_FAILURE` | No | Encrypted content could not be processed |
| `internal_failure` | `internalFailure` | `INTERNAL_FAILURE` | No | The operation failed outside another public category |

Messages are fixed and sanitized. They contain no raw exception, URL, host,
header, body, token, environment key/value, user id, or livestream id.

## WebView diagnostic event model

`WebViewLogEvent` has controlled factories for page start, page finish, HTTP
error, and network error. Network categories are DNS, timeout, connection,
TLS, offline, cancelled, and unknown. Optional fields are status code, platform
error code, and whether the failure belongs to the main frame.

Report significant lifecycle and failure events only. Do not report successful
subresources or JavaScript console output. See
[Troubleshooting](troubleshooting.md) for the event catalog.
