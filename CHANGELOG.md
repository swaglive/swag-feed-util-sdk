# Changelog

## v0.9.0  (2026-09-16, source d1817265)

- d1817265 fix(feed_util): publish-only 的版號檢查改看真正被 stamp 的兩份整合文件 (#1344)
- 534e3e2e ci(feed_util): SDK 打包發佈 workflow —— pack → 人工核可 → 推 dist repo + 上傳 GCS (#1343)
- 6e3bf4b1 feat : add otp func to open live in feed util
- df5460e3 fix(feed_util): 補上 response body 中途停擺的 timeout,Dio 的 receiveTimeout 只管到 headers
- 9acf074e fix(feed_util): 以 interceptor 套用 timeout,讓 SDK core 直接 fetch 的 tracker / feed 請求也受限
- ed39cb61 fix(feed_util): SDK 預設 HTTP client 加上連線與接收 timeout,避免網路靜默丟包時無限卡在 Loading
- fa2ea93a feat(feed_util): 直播間 URL 加上 sdk=1 識別參數,供 webapp 對 SDK 觀眾去水印
- ec0d5572 Merge pull request #1336 from swaglive/fix/sdk
- 50534b37 Merge pull request #1335 from swaglive/sdk/errorcode-script
- 8116ca25 feat: add debugMode to LivestreamSdkConfig for enhanced diagnostics (#1334)
- ce505ebe fix(livestream): 每次抓 feed 都跟隨 302 轉址,不再重用會過期的 feed 路徑 (#1332)
- 66247b7c 新增跨平台診斷 Log 保存與匯出流程 (#1328)
- 20789584 feat: add warning logs for missing username cache in buildLivestreamUrl
- e451d67c feat: implement WebView event reporting for main-page lifecycle and network errors
- 8c7c8290 refactor: update livestream URL structure to use usernames instead of IDs
- 128f6b31 Enhance documentation and integration instructions for feed_util
- 46672f04 chore: update distribution documentation and add internal development guide
- c5ccdef0 Enhance distribution documentation and examples

## v0.8.0  (2026-07-17, source f7bf1e9a)

- 94b2b2f2 [GENP-3261] 增加直播資訊的 log (#1298)

## v0.7.0  (2026-07-15, source 30141769)

- 30141769 Support livestream auto play (#1283)
- 26192286 [GENP-3261] 加回 mdm=1 (#1282)

## v0.6.0  (2026-07-15, source 7a7dd13b)

- 7a7dd13b Simplify docs (#1275)
- db370e30 [GENP-3261] 將  config 加入 web link (#1272)
- dfe1ec56 [GENP-3261] 隱藏下線的直播 (#1270)

## v0.5.0  (2026-07-09, source 8123626d)

- 8123626d Add logs and print them (#1249)
- c4e46056 Update bundle id (#1250)
- 525ea531 改上原生平台的介面 (#1244)

## v0.4.0  (2026-07-09, source f2b18520)

- initial release

