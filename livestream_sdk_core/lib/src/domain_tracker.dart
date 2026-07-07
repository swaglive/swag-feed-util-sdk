import 'exception/domain_tracker_exceptions.dart';
import 'model/resolved_domains.dart';
import 'model/selected_domain_tracker_resources.dart';
import 'port/domain_tracker_best_servers_store.dart';
import 'port/domain_tracker_health_reporter.dart';
import 'port/domain_tracker_logger.dart';
import 'repository/domain_tracker_repository.dart';
import 'use_case/find_domain_tracker_best_resource_use_case.dart';
import 'use_case/find_domain_tracker_resource_use_case.dart';
import 'use_case/find_domain_tracker_server_use_case.dart';
import 'use_case/measure_domain_tracker_resource_use_case.dart';

/// Facade over the domain-tracker pipeline (spec §04) for consumers that just
/// want domains — most notably feed_util's LivestreamSdk.
///
/// Input: the caller's tracker parameters ([trackerServers], optional
/// [resourceLabels]) plus a [repositoryFactory] backed by any Dio client
/// (must carry the auth + time-profiling interceptors). Output:
/// [ResolvedDomains] — the resolved `api` base for backend access and the
/// `frontend` public domain — via [resolve]:
///
/// 1. race checkHealth() over [trackerServers] → healthy config server
///    (throws [DomainTrackerServerNotFoundException] when all fail)
/// 2. getResourceTypes([resourceLabels]) + getResourceList()
/// 3. per priority group, race checkResourceHealth() → best resource per type
///    (throws [HealthyResourceNotFoundException] when a type has none)
/// 4. return the `api` + `frontend` bases (plus the full type→uri map)
final class DomainTracker {
  DomainTracker({
    required List<Uri> trackerServers,
    required DomainTrackerRepositoryFactory repositoryFactory,
    List<String>? resourceLabels,
    DomainTrackerLogger logger = const NoopDomainTrackerLogger(),
    DomainTrackerHealthReporter healthReporter =
        const NoopDomainTrackerHealthReporter(),
    DomainTrackerBestServersStore? bestServersStore,
    DomainTrackerProcessIdProvider? processIdProvider,
  }) : _trackerServers = trackerServers,
       _repositoryFactory = repositoryFactory,
       _resourceLabels = resourceLabels,
       _logger = logger,
       _healthReporter = healthReporter,
       _bestServersStore = bestServersStore,
       _processIdProvider = processIdProvider;

  static const String apiResourceType = 'api';
  static const String frontendResourceType = 'frontend';

  final List<Uri> _trackerServers;
  final DomainTrackerRepositoryFactory _repositoryFactory;
  final List<String>? _resourceLabels;
  final DomainTrackerLogger _logger;
  final DomainTrackerHealthReporter _healthReporter;
  final DomainTrackerBestServersStore? _bestServersStore;
  final DomainTrackerProcessIdProvider? _processIdProvider;

  /// Runs the full pipeline. Stateless — callers own caching/single-flight
  /// (feed_util's LivestreamSdkImpl already single-flights around this).
  Future<ResolvedDomains> resolve() async {
    final selected = await resolveSelectedResources();

    final Uri? api = selected.uris[apiResourceType];
    final Uri? frontend = selected.uris[frontendResourceType];
    if (api == null || frontend == null) {
      final missing = [
        if (api == null) apiResourceType,
        if (frontend == null) frontendResourceType,
      ];
      throw HealthyResourceNotFoundException(
        code: HealthyResourceNotFoundException.codeHealthyResourceNotFound,
        message:
            'Config server did not provide required resource types [${missing.join(', ')}]',
        resourceTypes: missing,
      );
    }

    return ResolvedDomains(
      api: api,
      frontend: frontend,
      uris: selected.uris,
      remoteConfigOverrides: selected.overrideRemoteConfigs,
      isFrontendChanged: selected.isFrontendChanged,
    );
  }

  /// Steps 1–3 only; exposed for consumers that need the raw selection
  /// (all resource types) rather than the api/frontend pair.
  Future<SelectedDomainTrackerResources> resolveSelectedResources() async {
    final Uri configServer = await FindDomainTrackerServerUseCase(
      servers: _trackerServers,
      repositoryFactory: _repositoryFactory,
      logger: _logger,
    ).call();

    return FindDomainTrackerResourceUseCase(
      domainTracker: configServer,
      repositoryFactory: _repositoryFactory,
      findBestResourceUseCase: FindDomainTrackerBestResourceUseCase(
        measureResourceUseCase: MeasureDomainTrackerResourceUseCase(
          logger: _logger,
          processIdProvider: _processIdProvider,
        ),
        healthReporter: _healthReporter,
      ),
      labels: _resourceLabels,
      bestServersStore: _bestServersStore,
      logger: _logger,
    ).call();
  }
}
