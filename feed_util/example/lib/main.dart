import 'dart:typed_data';

import 'package:feed_util/feed_util.dart';
import 'package:flutter/material.dart';

/// External Flutter consumer of the feed_util Livestream SDK: adds `feed_util`
/// as a dependency and calls [LivestreamSdk] directly — no MethodChannel.
///
/// Real data needs the tracker auth token, baked at build time:
///   flutter run --dart-define=FEED_UTIL_TRACKER_AUTH_TOKEN=YOUR_TOKEN
void main() => runApp(const ExampleApp());

/// The livestream feed id under test.
const String _feedId = 'user_livestream-v2';

/// Real Swag domain-tracker config servers (global env; non-secret hosts).
const List<String> _trackerServers = [
  '138.113.217.111',
  '138.113.217.43',
  'wscps.henkeichu.com',
  'wscps.henkeichu.info',
  'wscps.henkeichu.net',
];

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'feed_util host example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const FeedPage(),
    );
  }
}

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final LivestreamSdk _sdk = LivestreamSdk(
    const LivestreamSdkConfig(trackerServers: _trackerServers),
  );

  final List<LivestreamItem> _items = [];
  PageToken? _nextToken;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await _sdk.getLivestreamList(_feedId);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(page.items);
        _nextToken = page.nextToken;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    final token = _nextToken;
    if (token == null || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final page = await _sdk.getLivestreamList(_feedId, pageToken: token);
      if (!mounted) return;
      setState(() {
        _items.addAll(page.items);
        _nextToken = page.nextToken;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  void _showUrl(LivestreamItem item) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(_sdk.buildLivestreamUrl(item.id))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('feed_util · $_feedId'),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      // Dispatch straight to a widget per state — each is its own element
      // subtree, so a rebuild of one branch doesn't touch the others and the
      // const branches stay const.
      body: switch ((_loading, _error, _items.isEmpty)) {
        (true, _, _) => const _LoadingView(),
        (_, final error?, _) => _ErrorView(message: error, onRetry: _refresh),
        (_, _, true) => const _EmptyView(),
        _ => _FeedGrid(
          items: _items,
          onRefresh: _refresh,
          onLoadMore: _loadMore,
          onTapItem: _showUrl,
          onLoadCover: _sdk.getCoverImage,
        ),
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('No livestreams.'));
}

/// The livestream card grid with pull-to-refresh and scroll-driven load-more.
class _FeedGrid extends StatelessWidget {
  const _FeedGrid({
    required this.items,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onTapItem,
    required this.onLoadCover,
  });

  final List<LivestreamItem> items;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final void Function(LivestreamItem item) onTapItem;
  final Future<Uint8List?> Function(String livestreamId) onLoadCover;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 400) {
            onLoadMore();
          }
          return false;
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 2,
            crossAxisSpacing: 12,
            // Square cover + two text lines; 0.78 keeps the tallest phones from
            // overflowing while leaving minimal slack on wide ones.
            childAspectRatio: 0.78,
          ),
          itemCount: items.length,
          itemBuilder: (_, index) => _LiveCard(
            item: items[index],
            onTap: () => onTapItem(items[index]),
            onLoadCover: onLoadCover,
          ),
        ),
      ),
    );
  }
}

/// Card modeled on the in-app `app_live_card`: square cover with overlays
/// (top-left badge, top-right status, viewers, score) + title/subtitle below.
class _LiveCard extends StatelessWidget {
  const _LiveCard({
    required this.item,
    required this.onTap,
    required this.onLoadCover,
  });

  final LivestreamItem item;
  final VoidCallback onTap;
  final Future<Uint8List?> Function(String livestreamId) onLoadCover;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Square thumbnail (1:1), matching the in-app livestream card.
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Decrypted cover from getCoverImage; a deterministic colored
                  // placeholder stands in while it loads or when there's none.
                  _Cover(item: item, onLoadCover: onLoadCover),
                  if (_topLeftBadge != null)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _Pill(
                        text: _topLeftBadge!.$1,
                        background: _topLeftBadge!.$2,
                      ),
                    ),
                  if (_status != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _Pill(text: _status!.$1, background: _status!.$2),
                    ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: _Pill(
                      icon: Icons.visibility,
                      text: _viewerText,
                      background: const Color(0xB3000000),
                    ),
                  ),
                  if ((item.score ?? 0) > 0)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      // Design: {flag} ⭐ {score} ({reviewCount}) at bottom-right.
                      child: _ScorePill(
                        countryFlag: _countryFlag,
                        score: item.score!,
                        reviewText: item.reviewCount > 0 ? _reviewText : '',
                        starColor: _starColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.title?.isNotEmpty == true ? item.title! : '(untitled)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            // Subtitle is just the display name (flag + score moved to the
            // bottom-right cover pill, per the Figma design).
            item.displayName ?? item.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Flag emoji from a `country:xx` badge — the exact regional-indicator
  /// conversion the in-app card uses (`livestream_model.countryFlag`). Renders
  /// on real devices and Android via the OS emoji font; the iOS *simulator* on
  /// this repo's custom engine has no color-emoji font, so it shows tofu there
  /// (the in-app card behaves the same — flags are verified on device).
  String? get _countryFlag {
    for (final badge in item.badges) {
      if (badge.startsWith('country:')) {
        final code = badge.substring('country:'.length);
        if (code.length != 2) return null;
        final upper = code.toUpperCase();
        final first = upper.codeUnitAt(0) - 0x41 + 0x1F1E6;
        final second = upper.codeUnitAt(1) - 0x41 + 0x1F1E6;
        return String.fromCharCode(first) + String.fromCharCode(second);
      }
    }
    return null;
  }

  String get _viewerText =>
      item.viewers >= 1000 ? '${item.viewers ~/ 1000}k' : '${item.viewers}';

  String get _reviewText => item.reviewCount >= 1000
      ? '${item.reviewCount ~/ 1000}k'
      : '${item.reviewCount}';

  Color get _starColor {
    final score = item.score ?? 0;
    if (score >= 4.8) return const Color(0xFFFFC400);
    if (score >= 4.1) return Colors.white;
    return const Color(0xFF9E9E9E);
  }

  /// Single top-left badge, prioritized VIP > newbie > toy (as in the app).
  (String, Color)? get _topLeftBadge {
    if (item.isVipSponsor) return ('VIP', const Color(0xFFB8860B));
    if (item.isNewbie) return ('NEW', const Color(0xFF2E7D32));
    if (item.hasToy) return ('TOY', const Color(0xFFAD1457));
    return null;
  }

  /// Top-right status pill (label, color); null hides it (offline).
  (String, Color)? get _status {
    switch (item.status) {
      case LivestreamStatus.free:
        return ('免費直播中', const Color(0xCC000000));
      case LivestreamStatus.performing:
        return ('表演中', const Color(0xFF7C4DFF));
      case LivestreamStatus.funding:
        final remaining =
            (item.fundingTarget ?? 0) - (item.fundingProgress ?? 0);
        return (
          remaining > 0 ? '剩 $remaining 張' : '募資中',
          const Color(0xFF7C4DFF),
        );
      case LivestreamStatus.exclusive:
        return ('獨家', const Color(0xFF3A6DE0));
      case LivestreamStatus.offline:
        return null;
    }
  }
}

/// Bottom-right cluster: {country} ⭐ {score} ({reviewCount}), per the design.
class _ScorePill extends StatelessWidget {
  const _ScorePill({
    this.countryFlag,
    required this.score,
    required this.reviewText,
    required this.starColor,
  });

  final String? countryFlag;
  final double score;
  final String reviewText;
  final Color starColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xB3000000),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (countryFlag != null) ...[
            // Emoji flag, matching the in-app card. Renders on device/Android;
            // tofu on the iOS simulator (this engine's simulator build has no
            // color-emoji font) — verify flags on a real device.
            Text(countryFlag!, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
          ],
          Icon(Icons.star, size: 12, color: starColor),
          const SizedBox(width: 3),
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (reviewText.isNotEmpty)
            Text(
              ' ($reviewText)',
              style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 11),
            ),
        ],
      ),
    );
  }
}

/// Fetches the decrypted cover for [item] via [onLoadCover] and shows it once
/// available. Until then — and if the stream has no cover — it falls back to
/// [_CoverPlaceholder]. Re-fetches when the card is recycled for a new id.
class _Cover extends StatefulWidget {
  const _Cover({required this.item, required this.onLoadCover});

  final LivestreamItem item;
  final Future<Uint8List?> Function(String livestreamId) onLoadCover;

  @override
  State<_Cover> createState() => _CoverState();
}

class _CoverState extends State<_Cover> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_Cover oldWidget) {
    super.didUpdateWidget(oldWidget);
    // GridView recycles cards, so the same element may render a new stream.
    if (oldWidget.item.id != widget.item.id) {
      _bytes = null;
      _load();
    }
  }

  Future<void> _load() async {
    final id = widget.item.id;
    try {
      final bytes = await widget.onLoadCover(id);
      // Guard against a stale reply after recycling/unmount.
      if (!mounted || bytes == null || id != widget.item.id) return;
      setState(() => _bytes = bytes);
    } catch (_) {
      // Keep the placeholder on any failure — the demo shouldn't crash.
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes == null) return _CoverPlaceholder(item: widget.item);
    return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.item});

  final LivestreamItem item;

  @override
  Widget build(BuildContext context) {
    // Deterministic hue from the id so each card looks distinct.
    final hue = (item.id.hashCode % 360).abs().toDouble();
    final color = HSLColor.fromAHSL(1, hue, 0.35, 0.30).toColor();
    final initial = (item.username.isNotEmpty ? item.username[0] : '?')
        .toUpperCase();
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.55),
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    this.icon,
    this.background = const Color(0xCC000000),
  });

  final String text;
  final IconData? icon;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE57373), size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
