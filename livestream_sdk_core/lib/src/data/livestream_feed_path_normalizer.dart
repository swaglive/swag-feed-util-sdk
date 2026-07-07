/// Normalizes a raw feed path to the canonical `feeds/…` form.
///
/// Strips surrounding slashes and prefixes `feeds/` unless already present.
/// Mirrors the app's `normalizeLivestreamFeedPath`.
String normalizeLivestreamFeedPath(String path) {
  final cleanPath = path.replaceAll(RegExp(r'^/+|/+$'), '');
  return cleanPath.startsWith('feeds') ? cleanPath : 'feeds/$cleanPath';
}
