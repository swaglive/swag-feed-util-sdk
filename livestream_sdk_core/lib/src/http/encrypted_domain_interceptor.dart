import 'package:dio/dio.dart';

/// Reroutes public-asset requests to the AES-encrypted mirror host so the
/// response comes back encrypted (and is then decrypted by
/// `AesDecryptFusedTransformer`).
///
/// Config-injected port of packages/core's `EncryptedDomainInterceptor`, which
/// reads `basePublicUri` / `baseEncryptedPublicUri` from `RemoteConfig`. This
/// package forbids get_it / remote_config_kit, so the two hosts arrive as
/// supplier callbacks instead — letting the consumer feed them lazily from the
/// domain-tracker-resolved bases (which aren't known when the Dio client is
/// built).
///
/// No-op unless both hosts are available and the request already targets the
/// public host — mirroring core's behavior when the `useEncryptedPublicUri`
/// flag is off. This makes the interceptor safe to always install.
class EncryptedDomainInterceptor extends Interceptor {
  EncryptedDomainInterceptor({
    required String? Function() publicHost,
    required String? Function() encryptedPublicHost,
  }) : _publicHost = publicHost,
       _encryptedPublicHost = encryptedPublicHost;

  final String? Function() _publicHost;
  final String? Function() _encryptedPublicHost;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final publicHost = _publicHost();
    final encryptedHost = _encryptedPublicHost();

    if (publicHost != null &&
        publicHost.isNotEmpty &&
        encryptedHost != null &&
        encryptedHost.isNotEmpty &&
        options.uri.host == publicHost) {
      // Swap the host to the encrypted mirror. Passing a full URL as `path`
      // overrides the client baseUrl (same trick as core).
      final newOptions = options.copyWith(
        path: options.uri.replace(host: encryptedHost).toString(),
      );
      return handler.next(newOptions);
    }

    handler.next(options);
  }
}
