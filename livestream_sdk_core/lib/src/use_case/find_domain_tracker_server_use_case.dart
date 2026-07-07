import 'dart:async';

import '../exception/domain_tracker_exceptions.dart';
import '../port/domain_tracker_logger.dart';
import '../repository/domain_tracker_repository.dart';

/// Races a health check over all config servers and returns the first one to
/// respond healthy (spec §04 step 1).
///
/// Extracted from webview-user-app — algorithm unchanged; servers/repository
/// come from the constructor instead of EnvConfig/GetIt.
final class FindDomainTrackerServerUseCase {
  FindDomainTrackerServerUseCase({
    required List<Uri> servers,
    required DomainTrackerRepositoryFactory repositoryFactory,
    DomainTrackerLogger logger = const NoopDomainTrackerLogger(),
  }) : _servers = servers,
       _repositoryFactory = repositoryFactory,
       _logger = logger;

  final List<Uri> _servers;
  final DomainTrackerRepositoryFactory _repositoryFactory;
  final DomainTrackerLogger _logger;

  Future<Uri> call() async {
    final servers = _servers;
    if (servers.isEmpty) {
      throw const DomainTrackerServerNotFoundException(
        message: 'There is no config server define in env variable',
      );
    }

    final Completer<Uri> completer = Completer();

    Future.wait<void>(
      servers.map<Future<void>>(
        (server) => _repositoryFactory(server.host)
            .checkHealth()
            .then<void>((health) {
              _logger.debug(
                'Found healthy config server: $server',
                context: {
                  'rtt': health.rtt,
                  'responseHeaders': health.responseHeaders,
                },
              );
              if (!completer.isCompleted) {
                _logger.debug('Selected healthy config server: $server');
                completer.complete(server);
              }
            })
            .catchError((Object e) {
              _logger.warning(
                'Failed to check health of config server: $server',
                error: e,
              );
            }),
      ),
    ).whenComplete(() {
      if (!completer.isCompleted) {
        _logger.warning(
          'After all health checks, no healthy config server found, $servers',
        );
        completer.completeError(
          DomainTrackerServerNotFoundException(
            message: 'No healthy config server found, $servers',
            servers: servers,
          ),
        );
      }
    });

    return completer.future;
  }
}
