# Troubleshooting

The SDK exposes fixed error categories and opt-in sanitized console events.
Start with the public error, then use the event stream to identify whether the
failure occurred during domain resolution, feed loading, cover loading, URL
building, or the host WebView.

Diagnostics never replace host error states. The SDK performs no hidden
request retry.

## Enable diagnostics temporarily

Set `debugMode` in the immutable SDK configuration before constructing or
initializing the SDK.

Flutter:

```dart
const LivestreamSdkConfig(
  trackerServers: ['<tracker-host-from-Swag>'],
  debugMode: true,
);
```

Android:

```kotlin
LivestreamSdkConfig(
    trackerServers = listOf("<tracker-host-from-Swag>"),
    debugMode = true,
)
```

Disable it again for the normal production lifecycle after reproducing the
issue.

## Capture output

Flutter events appear in the `flutter run` / platform console stream. Filter
for lines beginning with `[FeedUtil]`.

Android facade events use the `FeedUtil` Logcat tag:

```sh
adb logcat -s FeedUtil
```

Each line has a fixed shape:

```text
[FeedUtil][LEVEL] schemaVersion=1 sdkVersion=1.0.0 platform=... session=... event=... fields...
```

`trace` associates start/completion/failure events for one operation.
`durationMs` is local elapsed time. Repeated events are rate-limited; a
`diagnostics.suppressed` event reports that safe duplicates were omitted.

## Diagnostic event catalog

| Event | Important fields | Meaning |
| --- | --- | --- |
| `sdk.configured` | `trackerServers`, `trackerLabels` | SDK accepted configuration; values are counts only |
| `sdk.stopped` | None | Android facade was shut down |
| `domain.resolve.started` | `trace`, `candidates` | First feed/URL-context operation began domain discovery |
| `domain.tracker.signal` | `signal`, `sequence` | Sanitized tracker progress or candidate/resource failure |
| `domain.resolve.completed` | `trace`, `durationMs`, `resourceCount`, `frontendChanged` | Reachable resources were resolved |
| `domain.resolve.failed` | `trace`, `durationMs`, `error` | No domain result was available |
| `encryption.config.applied` | `keyCount` | Valid encrypted-cover configuration was applied |
| `encryption.config.ignored` | `reason` | Published encryption configuration had invalid format |
| `feed.fetch.started` | `trace`, `page`, `bustCache` | A feed page request began |
| `feed.response.observed` | `stage`, `status`, `itemCount` | Sanitized response summary for feed or schedule enrichment |
| `feed.enrichment.warning` | `error` | Schedule enrichment was incomplete; items may be filtered as offline |
| `feed.fetch.completed` | `trace`, `durationMs`, `itemCount`, `filteredCount` | A visible page was produced |
| `feed.fetch.failed` | `trace`, `durationMs`, `error` | Feed operation returned a public error |
| `cover.fetch.started` | `trace` | A visible-card cover request began |
| `cover.fetch.completed` | `trace`, `durationMs`, `outcome` | Cover result was `success`, `unavailable`, `not_found`, or `empty` |
| `cover.fetch.failed` | `trace`, `durationMs`, `error` | Cover request returned a public error |
| `livestream.url.built` | `outcome`, `usernameCache`, `otp=present` | A watch URL was built from a known feed item and a non-blank OTP; the OTP value is never logged |
| `livestream.url.failed` | `outcome`, `error` | URL call order, item id, or OTP was invalid |
| `webview.page.started` | `frame` | Host reported page navigation start |
| `webview.page.finished` | `frame` | Host reported page navigation completion |
| `webview.http.failed` | `status`, `frame` | Host WebView received an HTTP error response |
| `webview.network.failed` | `category`, `code`, `frame` | Host WebView reported DNS/timeout/connection/TLS/offline/cancelled/unknown failure |
| `diagnostics.suppressed` | `source`, `count` | Duplicate safe events were rate-limited |

`frame` is `main`, `subresource`, or `unknown`. A failed subresource does not
always mean the main livestream page failed.

## Error and retry policy

| Error | Retry same operation? | Host action |
| --- | --- | --- |
| `domain_unreachable` | Yes | Check connectivity/configuration, then expose retry |
| `network_timeout` | Yes | Preserve current UI and expose retry |
| `network_failure` | Yes | Preserve current UI and expose retry |
| `invalid_argument` | No | Correct the supplied value or item ownership |
| `illegal_state` | No | Correct initialization/call order |
| `bad_response` | No | Record release tag and report the stable event sequence |
| `decryption_failure` | No | Keep the cover placeholder and report the release/environment |
| `internal_failure` | No | Record release tag and report the stable event sequence |

For pagination, preserve existing items and retry the same token. For covers,
preserve the placeholder. For a user refresh, request page one with
`bustCache = true`; do not apply it to a next-page token.

## Symptom lookup

| Symptom | Evidence to inspect | Checks |
| --- | --- | --- |
| `domain_unreachable` | `domain.resolve.*`, `domain.tracker.signal` | Device connectivity, Android `INTERNET` permission, tracker server count, whether the target environment requires a token/labels |
| Feed fails | `feed.fetch.failed` | Public error, release tag, feed ID ownership, retryability |
| Empty or short feed | `feed.fetch.completed`, `feed.enrichment.warning` | `itemCount`, `filteredCount`; offline streams are removed and no active stream can be valid |
| Pagination repeats/fails | `feed.fetch.started` | Host guards duplicate calls, passes the previous opaque token unchanged, and does not use `bustCache` |
| Cover stays placeholder | `cover.fetch.completed` / `failed` | `unavailable` and `not_found` are valid no-cover states; confirm id came from this SDK instance |
| URL call fails | `livestream.url.failed` | Successful feed happened first, id came from its returned item, and OTP is non-blank |
| Room login returns 401 | Host WebView/network inspection | Discard the OTP and URL; fetch a fresh OTP from the partner server and rebuild. Never replay a room URL |
| WebView blank/404 | `webview.http.failed`, `webview.network.failed` | Main-frame status/category and whether the SDK URL was loaded unchanged; compare the runnable example |
| List or room fails only in a region | `domain.resolve.*`, then feed/WebView events | Keep the onboarding tracker list unchanged and verify both API and frontend hosts selected by Domain Tracker are reachable on that device/network |
| Android call returns `ILLEGAL_STATE` | Initialization result and `FeedUtil.isInitialized` | Wait for `initialize` success; do not use a different config without shutdown |

## Safe support report

Include:

- SDK release tag and host platform;
- minimum reproducible sequence of SDK operations;
- public error enum and wire code;
- relevant `[FeedUtil]` lines from one diagnostic session;
- whether the failure is main-frame or subresource when applicable;
- application/OS/toolchain versions from the compatibility matrix.

Do not include:

- tracker token, OTP, server hostnames, or tracker labels;
- feed ID, livestream/user/session identifiers;
- complete URLs or WebView history;
- request/response headers, bodies, or remote-config key/value pairs;
- raw exceptions or JavaScript console output.

The SDK event model and fixed messages are designed to exclude those values.
There is no public diagnostic listener, file persistence, upload, or raw
payload mode.
