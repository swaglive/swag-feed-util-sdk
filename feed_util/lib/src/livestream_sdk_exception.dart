/// Stable, sanitized SDK error categories.
///
/// Use [isRetryable] to decide whether the host should offer a retry action.
/// The SDK never retries a request implicitly.
enum LivestreamSdkErrorCode {
  invalidArgument,
  illegalState,
  domainUnreachable,
  networkTimeout,
  networkFailure,
  badResponse,
  decryptionFailure,
  internalFailure;

  /// Whether retrying the same operation may succeed without changing its
  /// arguments or the SDK lifecycle.
  ///
  /// The SDK deliberately does not retry requests behind the host's back.
  /// Use this value to decide whether to show a retry action while preserving
  /// the current page or placeholder.
  bool get isRetryable => switch (this) {
    domainUnreachable || networkTimeout || networkFailure => true,
    invalidArgument ||
    illegalState ||
    badResponse ||
    decryptionFailure ||
    internalFailure => false,
  };

  String get wireName => switch (this) {
    invalidArgument => 'invalid_argument',
    illegalState => 'illegal_state',
    domainUnreachable => 'domain_unreachable',
    networkTimeout => 'network_timeout',
    networkFailure => 'network_failure',
    badResponse => 'bad_response',
    decryptionFailure => 'decryption_failure',
    internalFailure => 'internal_failure',
  };

  String get message => switch (this) {
    invalidArgument => 'An SDK argument is invalid.',
    illegalState => 'The SDK is not ready for this operation.',
    domainUnreachable => 'No service domain is currently reachable.',
    networkTimeout => 'The SDK request timed out.',
    networkFailure => 'The SDK request failed.',
    badResponse => 'The SDK received an invalid response.',
    decryptionFailure => 'The SDK could not process encrypted content.',
    internalFailure => 'The SDK could not complete the operation.',
  };
}

/// Public SDK exception with no raw cause, transport details, or sensitive
/// message content.
final class LivestreamSdkException implements Exception {
  const LivestreamSdkException(this.code);

  final LivestreamSdkErrorCode code;

  String get message => code.message;

  @override
  String toString() => 'LivestreamSdkException(${code.wireName}): $message';
}
