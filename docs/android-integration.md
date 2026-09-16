# Native Android integration

This guide is for an Android application written in Kotlin or Java. The host
uses the typed `FeedUtil` facade; FlutterEngine and MethodChannel are private
implementation details.

The AAR requires Android API 24 or newer and Java 17 bytecode. Kotlin hosts
must use Kotlin 2.2 or newer. See the [API reference](api-reference.md) for the
exact contract.

## 1. Add the release repository

Use the same pinned release tag in the raw Maven URL that the application will
ship.

```kotlin
// settings.gradle.kts
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven(
            url = uri(
                "https://raw.githubusercontent.com/" +
                    "swaglive/swag-feed-util-sdk/v0.9.0/android/aar-repo"
            )
        )
        maven(url = "https://storage.googleapis.com/download.flutter.io")
    }
}
```

Add the one public facade dependency. `1.0` is the Maven coordinate inside a
release repository; the Git tag selects the release.

```kotlin
// app/build.gradle.kts
dependencies {
    implementation("live.swag.feedutil:feed-util:1.0")
}
```

The facade pulls its Flutter module and native dependencies transitively. Do
not add the internal Flutter AAR coordinates yourself.

## 2. Declare network access

The release AAR does not inject host permissions.

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
```

Missing this permission normally surfaces as `DOMAIN_UNREACHABLE` in a release
build.

## 3. Initialize once

`initialize` starts the application-scoped engine, waits until Dart is ready,
and applies the immutable configuration. A successful return/callback means
feature calls are safe.

Repeated initialization with the same config is idempotent and joins any
in-flight initialization. A different config returns `ILLEGAL_STATE`; call
`shutdown` first only when a test or host process intentionally needs a fresh
SDK.

### Kotlin suspend API

Call the suspend API from a host-owned coroutine scope. The SDK does not force
a coroutine framework dependency on the host.

```kotlin
suspend fun initializeFeedUtil(context: Context) {
    val config = LivestreamSdkConfig(
        trackerServers = listOf("<tracker-host-from-Swag>"),
        trackerAuthToken = runtimeTokenOrNull,
        trackerLabels = null,
        debugMode = false,
    )

    try {
        FeedUtil.initialize(context.applicationContext, config)
    } catch (error: FeedUtilException) {
        showInitializationError(
            error.message.orEmpty(),
            canRetry = error.isRetryable,
        )
    }
}
```

### Java callback API

```java
LivestreamSdkConfig config = new LivestreamSdkConfig(
    trackerServers,
    runtimeTokenOrNull,
    null,
    false
);

FeedUtil.initialize(getApplicationContext(), config, new CompletionCallback() {
    @Override public void onSuccess() {
        loadFirstPage();
    }

    @Override public void onError(FeedUtilException error) {
        showInitializationError(
            error.getMessage(),
            error.isRetryable()
        );
    }
});
```

Java callbacks are delivered on the Android main thread. Never commit the
tracker token; load it from runtime or ignored local configuration.

## 4. Load the feed

### Kotlin

```kotlin
var items: List<LivestreamItem> = emptyList()
var nextToken: String? = null

suspend fun loadFirstPage(refresh: Boolean = false) {
    try {
        val page = FeedUtil.getLivestreamList(
            feedId = "<feed-id-from-Swag>",
            bustCache = refresh,
        )
        items = page.items
        nextToken = page.nextToken
        renderLoadedOrEmpty(items)
    } catch (error: FeedUtilException) {
        renderFeedError(error.message.orEmpty(), error.isRetryable)
    }
}

suspend fun loadNextPage() {
    val token = nextToken ?: return
    try {
        val page = FeedUtil.getLivestreamList(
            feedId = "<feed-id-from-Swag>",
            pageToken = token,
        )
        items = items + page.items
        nextToken = page.nextToken
        renderAppended(page.items)
    } catch (error: FeedUtilException) {
        // Preserve existing items and retry this same token when allowed.
        renderPaginationError(error.message.orEmpty(), error.isRetryable)
    }
}
```

### Java

```java
FeedUtil.getLivestreamList(
    "<feed-id-from-Swag>",
    new ResultCallback<LivestreamPage>() {
        @Override public void onSuccess(LivestreamPage page) {
            renderLoadedOrEmpty(page.getItems());
            nextToken = page.getNextToken();
        }

        @Override public void onError(FeedUtilException error) {
            renderFeedError(error.getMessage(), error.isRetryable());
        }
    }
);
```

Use the overload with `pageToken` to append another page. Treat the token as
opaque and guard against concurrent load-more calls. For an explicit refresh,
call the four-argument Java overload with a `null` token and `bustCache = true`,
then replace the current items.

Host state must distinguish loading, loaded, empty, retryable error, and
non-retryable error. Offline streams are filtered by the SDK, so an empty page
can be valid.

## 5. Load visible covers

`null` means the livestream currently has no cover. Keep a host-owned
placeholder for `null`, loading, and error states.

```kotlin
val bytes: ByteArray? = try {
    FeedUtil.getCoverImage(item.id)
} catch (_: FeedUtilException) {
    null
}
showCoverOrPlaceholder(bytes)
```

```java
FeedUtil.getCoverImage(item.getId(), new ResultCallback<byte[]>() {
    @Override public void onSuccess(byte[] bytes) {
        showCoverOrPlaceholder(bytes);
    }

    @Override public void onError(FeedUtilException error) {
        showCoverOrPlaceholder(null);
    }
});
```

Fetch lazily as cards become visible. Decode large images away from the UI
thread; callbacks themselves arrive on the main thread.

## 6. Render nullable fields safely

The host controls card visuals but must provide functional fallbacks.

| Field | Recommended functional fallback |
| --- | --- |
| `displayName` | Use `username` |
| `title` | Use a localized untitled label or omit the row |
| `score` | Omit rating when `null` |
| `countryFlag` | Omit the flag when `null` |
| funding fields | Render only for applicable funding shows |
| cover bytes | Keep a placeholder when `null` or failed |

## 7. Get an OTP from your server

In the card tap handler, ask your own backend for a fresh room OTP. Your
backend performs the signed `POST /affiliate/v1/login` request described in
the backend-owned reference linked from the
[Partner Integration Hub](https://app.notion.com/p/3c9926e209a3819b9673ea479a169997).
Return only the OTP to the app; keep the affiliate signing key and full
redirect URL on the server. The mobile SDK does not implement this
server-to-server exchange.

| Credential | SDK location | Purpose | Lifetime |
| --- | --- | --- | --- |
| Tracker auth token | `LivestreamSdkConfig` | Domain Tracker requests | Long-lived, per environment |
| OTP | `buildLivestreamUrl` | Log the member into one room open | Single-use and time-limited |

Keep the onboarding tracker servers as static SDK configuration and ignore
`domain_tracker_config.domains` from the affiliate login response. Domain
Tracker continues to choose healthy API and frontend hosts for the current
network and region.

Fetch on every tap, not while loading the feed. Never cache or reuse an OTP or
the resulting room URL.

## 8. Open a livestream

Build the URL from an item returned by this initialized SDK, after a successful
feed request.

```kotlin
try {
    val otp = myServer.fetchSwagOtp(memberId)
    val url = FeedUtil.buildLivestreamUrl(item.id, otp)
    openHostWebView(url)
} catch (error: FeedUtilException) {
    showOpenError(error.message.orEmpty())
}
```

```java
myServer.fetchSwagOtp(memberId, otp -> {
    FeedUtil.buildLivestreamUrl(item.getId(), otp, new ResultCallback<String>() {
        @Override public void onSuccess(String url) {
            openHostWebView(url);
        }

        @Override public void onError(FeedUtilException error) {
            showOpenError(error.getMessage());
        }
    });
});
```

Load the returned URL unchanged and only once, then discard it when the
WebView closes. Reopening the same or another room requires a fresh OTP and a
new URL. A 401 from room OTP login normally means that the OTP expired or was
already consumed. The SDK emits no room-closed event because the host owns the
WebView. The runnable
[`android/example`](../android/example) contains the reference host WebView;
its WebView configuration is an example concern rather than part of the SDK
API contract.

## 9. Handle typed errors

Use `FeedUtilException.code` for control flow and `wireCode` only for a stable
cross-platform report value.

```kotlin
when (error.code) {
    FeedUtilErrorCode.DOMAIN_UNREACHABLE,
    FeedUtilErrorCode.NETWORK_TIMEOUT,
    FeedUtilErrorCode.NETWORK_FAILURE -> showRetry()
    FeedUtilErrorCode.INVALID_ARGUMENT -> reportIntegrationBug()
    else -> showStableFailure(error.message.orEmpty())
}
```

The equivalent Java enum is returned by `error.getCode()`. The SDK performs no
hidden request retry; `error.isRetryable` / `error.isRetryable()` is the
canonical retry decision. See [Troubleshooting](troubleshooting.md).

## 10. Shutdown

Normal applications keep the SDK for the process lifetime. Tests, tools, or a
host that intentionally changes environments may release it explicitly:

```kotlin
FeedUtil.shutdown()
```

After shutdown, feature methods fail with `ILLEGAL_STATE` until initialization
succeeds again.

## Acceptance checklist

- [ ] The Maven URL pins the intended release tag.
- [ ] The app declares only `live.swag.feedutil:feed-util:1.0`.
- [ ] The host manifest declares `android.permission.INTERNET`.
- [ ] No token is committed to source control.
- [ ] The affiliate signing key and full redirect URL never reach the app.
- [ ] Initialization success is observed before feature calls.
- [ ] Loading, empty, retryable-error, and non-retryable-error states render.
- [ ] Page one loads and a non-null token appends exactly one later page.
- [ ] Pull-to-refresh replaces page one and uses `bustCache = true`.
- [ ] Visible cards load covers off the UI thread and preserve placeholders.
- [ ] Nullable model fields use host fallbacks.
- [ ] Every card tap fetches a fresh OTP from the partner server.
- [ ] Tapping a returned item opens the unchanged SDK URL once, then discards it.
- [ ] Reopening any room fetches a new OTP and builds a new URL.
- [ ] Diagnostics can be captured from Logcat without environment/user data.

Build the complete release example before shipping:

```sh
cd android/example
./gradlew :app:testDebugUnitTest :app:assembleRelease :app:lintRelease
```
