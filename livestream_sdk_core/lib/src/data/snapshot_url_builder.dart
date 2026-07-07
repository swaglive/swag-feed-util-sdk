/// Builds a livestream cover (snapshot) request URL from an encrypted snapshot
/// path.
///
/// Mirrors the app's `LivestreamUrlUtils.snapshotUriFromPath`: an absolute
/// snapshot URL (scheme + authority) is used as-is, otherwise the path is
/// resolved against [publicBase]. Any query already on the snapshot is kept,
/// then `hostname` and `size` are added.
///
/// `hostname` is set to [publicBase]'s host on purpose — the encrypted-domain
/// interceptor swaps only the *connection* host to the encrypted mirror, while
/// the CDN keys the origin off this query parameter.
Uri buildSnapshotUrl({
  required String snapshotPath,
  required Uri publicBase,
  String size = '512x512',
}) {
  final normalized = snapshotPath.trim();
  final parsed = Uri.tryParse(normalized);
  final isAbsoluteUrl =
      parsed != null && parsed.hasScheme && parsed.hasAuthority;
  final resolved = isAbsoluteUrl ? parsed : publicBase.resolve(normalized);

  return resolved.replace(
    queryParameters: {
      ...resolved.queryParameters,
      'hostname': publicBase.host,
      'size': size,
    },
  );
}
