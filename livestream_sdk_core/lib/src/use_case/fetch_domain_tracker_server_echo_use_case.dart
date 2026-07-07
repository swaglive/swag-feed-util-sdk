import '../repository/domain_tracker_repository.dart';

/// Fetches the config server's echo payload (debug info); `null` on failure.
class FetchDomainTrackerServerEchoUseCase {
  FetchDomainTrackerServerEchoUseCase({
    required DomainTrackerRepositoryFactory repositoryFactory,
  }) : _repositoryFactory = repositoryFactory;

  final DomainTrackerRepositoryFactory _repositoryFactory;

  Future<String?> call({required Uri domainTracker}) => _repositoryFactory(
    domainTracker.host,
  ).echo().catchError((Object e) => null);
}
