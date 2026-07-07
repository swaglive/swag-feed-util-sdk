import 'livestream_item.dart';

/// Opaque pagination cursor (spec §03).
///
/// Callers never inspect it: pass `null` for the first page, then hand back
/// [LivestreamPage.nextToken] verbatim. The SDK encodes backend paging state
/// (Link-header next URL, or page/limit) inside — switching the backend to
/// cursor paging later doesn't change this API.
extension type const PageToken(String raw) {}

/// One page of the livestream feed (spec §03).
class LivestreamPage {
  const LivestreamPage({required this.items, this.nextToken});

  final List<LivestreamItem> items;

  /// `null` means there is no next page.
  final PageToken? nextToken;

  /// Wire form sent to native over the MethodChannel (bridge contract).
  /// `fromMap` + round-trip tests are task B2.
  Map<String, Object?> toMap() => {
    'items': [for (final item in items) item.toMap()],
    'nextToken': nextToken?.raw,
  };
}
