import 'livestream_item.dart';

/// Opaque pagination cursor.
///
/// Never inspect or construct one yourself: pass `null` (no token) to
/// [LivestreamSdk.getLivestreamList] for the first page, then hand back
/// [LivestreamPage.nextToken] verbatim for each following page. Safe to
/// serialize and restore (it's a plain string) if you persist scroll state.
extension type const PageToken(String raw) {}

/// One page of the livestream feed.
class LivestreamPage {
  const LivestreamPage({required this.items, this.nextToken});

  /// The livestream cards on this page, in feed order.
  final List<LivestreamItem> items;

  /// Cursor for the next page; pass it back to
  /// `getLivestreamList(pageToken: …)`. `null` means this is the last page.
  final PageToken? nextToken;

  /// Internal wire form used by the SDK's native bridge — not needed when
  /// calling the Dart API directly.
  Map<String, Object?> toMap() => {
    'items': [for (final item in items) item.toMap()],
    'nextToken': nextToken?.raw,
  };
}
