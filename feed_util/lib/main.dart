import 'package:flutter/widgets.dart';

import 'feed_util_channel.dart';

/// Headless entry point for **native hosts** (Android Java add-to-app).
///
/// The native `FeedUtil` facade boots the Flutter engine with this entrypoint;
/// it only wires the `feed_util/method` MethodChannel — no UI, because a native
/// host renders its own. Must stay top-level and `@pragma('vm:entry-point')` so
/// tree-shaking keeps it; the name is referenced by `FeedUtil.kt` /
/// `FeedUtil.swift` (`DART_ENTRYPOINT`).
@pragma('vm:entry-point')
void feedUtilHeadlessMain() {
  WidgetsFlutterBinding.ensureInitialized();
  FeedUtilChannel.instance.init();
}

/// Default `flutter run` entrypoint. This module ships **no UI of its own** — a
/// Flutter host consumes the Dart `LivestreamSdk` API directly (see
/// `examples/flutter` for a runnable external-consumer example). `main`
/// just wires the channel so the module stays attachable headless.
void main() => feedUtilHeadlessMain();
