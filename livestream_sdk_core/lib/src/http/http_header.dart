/// HTTP header names used by the SDK's encrypted-response handling.
///
/// Config-injected port of the subset of packages/core's `HttpHeader` that the
/// [AesDecryptFusedTransformer] and [EncryptedDomainInterceptor] rely on — kept
/// byte-identical to core so a response encrypted by the same backend decrypts
/// here unchanged.
abstract final class HttpHeader {
  const HttpHeader._();

  /// Server-declared real content type of the *decrypted* body (the wire
  /// `Content-Type` is the encrypted envelope's type until decryption).
  static const xContentType = 'X-Content-Type';

  static const xEncryptedIv = 'X-Encrypted-IV';
  static const xEncryptedAlgo = 'X-Encrypted-Algo';
  static const xEncryptedKeyId = 'X-Encrypted-Key-ID';
  static const xEncryptedChunkSize = 'X-Encrypted-Chunk-Size';
}
