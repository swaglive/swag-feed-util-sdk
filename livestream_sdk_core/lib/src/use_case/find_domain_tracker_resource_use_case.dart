import '../exception/domain_tracker_exceptions.dart';
import '../model/domain_tracker_resource.dart';
import '../model/domain_tracker_resource_result.dart';
import '../model/selected_domain_tracker_resources.dart';
import '../port/domain_tracker_best_servers_store.dart';
import '../port/domain_tracker_logger.dart';
import '../repository/domain_tracker_repository.dart';
import 'find_domain_tracker_best_resource_use_case.dart';

/// FindServerUseCase is responsible for discovering and selecting the optimal servers
/// for API, CDN, and frontend services based on their health and response times.
///
/// The selection process involves:
/// 1. Fetching available servers for each service type
/// 2. Performing health checks with RTT measurement
/// 3. Selecting the best performing server for each service
///
/// Extracted from webview-user-app — algorithm unchanged; labels, repository,
/// best-resource use case, and the best-servers cache come from the
/// constructor instead of EnvConfig/GetIt/SharedPreferenceService.
final class FindDomainTrackerResourceUseCase {
  FindDomainTrackerResourceUseCase({
    required this.domainTracker,
    required DomainTrackerRepositoryFactory repositoryFactory,
    required FindDomainTrackerBestResourceUseCase findBestResourceUseCase,
    List<String>? labels,
    DomainTrackerBestServersStore? bestServersStore,
    DomainTrackerLogger logger = const NoopDomainTrackerLogger(),
  }) : _repository = repositoryFactory(domainTracker.host),
       _findBestResourceUseCase = findBestResourceUseCase,
       _labels = labels,
       _bestServersStore = bestServersStore,
       _logger = logger;

  final Uri domainTracker;
  final DomainTrackerRepository _repository;
  final FindDomainTrackerBestResourceUseCase _findBestResourceUseCase;
  final List<String>? _labels;
  final DomainTrackerBestServersStore? _bestServersStore;
  final DomainTrackerLogger _logger;

  /// Executes the server discovery and selection process.
  /// Throws an exception if no healthy servers are found.
  /// Returns the best performing servers for each service type.
  Future<SelectedDomainTrackerResources> call() async {
    final List<String>? labels = _labels;

    // Get all resource types
    final resourceTypes = await _repository.getResourceTypes(labels: labels);

    // Fall back to remote server discovery
    final allTypeResources = await _fetchAllTypeResources(
      resourceTypes,
      labels,
    );

    // Check if any resource type is empty
    final List<String> emptyResourceTypes = [];
    for (final resources in allTypeResources.entries) {
      if (resources.value.isEmpty) {
        emptyResourceTypes.add(resources.key);
      }
    }
    if (emptyResourceTypes.isNotEmpty) {
      throw HealthyResourceNotFoundException(
        code: HealthyResourceNotFoundException.codeServerResourceNotFound,
        message:
            'Cannot get server resources from config server ("${domainTracker.host}") for [${emptyResourceTypes.join(', ')}]',
        resourceTypes: emptyResourceTypes,
      );
    }

    // Find the best resource for each type
    final results = (await Future.wait(
      resourceTypes.map((type) async {
        final group = allTypeResources[type];
        if (group == null || group.isEmpty) {
          return DomainTrackerResourceUnhealthyResult(resourceType: type);
        }
        final keys = group.keys.toList()..sort();
        for (final key in keys) {
          final groupResources = group[key] ?? [];
          final result = await _findBestResourceUseCase.call(
            resourceType: type,
            resources: groupResources,
            repository: _repository,
          );
          if (result is DomainTrackerResourceHealthyResult) {
            return result;
          }
        }
        return DomainTrackerResourceUnhealthyResult(resourceType: type);
      }),
    ));

    final List<DomainTrackerResourceHealthyResult> bestResults = [];
    DomainTrackerResource? bestFrontendResource;
    final List<String> notFoundResourceTypes = [];
    final StringBuffer bestResultsLog = StringBuffer();
    for (final DomainTrackerResourceResult result in results) {
      switch (result) {
        case DomainTrackerResourceHealthyResult(
          :final resourceType,
          :final resource,
          :final measurement,
        ):
          bestResults.add(result);
          if (resource.type == 'frontend') {
            bestFrontendResource = resource;
          }

          final Duration? rtt = measurement?.rtt;
          final String? eoLogUuid = measurement?.eoLogUuid;
          final String? eoCacheStatus = measurement?.eoCacheStatus;
          final logAttributes = [
            resource.uri.toString(),
            if (rtt != null) 'rtt: $rtt',
            if (eoLogUuid != null) 'eoLogUuid: $eoLogUuid',
            if (eoCacheStatus != null) 'eoCacheStatus: $eoCacheStatus',
          ];
          bestResultsLog.writeln(
            'Best [$resourceType] Resource Found: ${logAttributes.join(',')}',
          );
          break;
        case DomainTrackerResourceUnhealthyResult(:final resourceType):
          notFoundResourceTypes.add(resourceType);
          bestResultsLog.writeln('Best [$resourceType] Resource Not Found');
          break;
      }
    }
    _logger.debug(bestResultsLog.toString());

    if (notFoundResourceTypes.isNotEmpty) {
      throw HealthyResourceNotFoundException(
        code: HealthyResourceNotFoundException.codeHealthyResourceNotFound,
        message:
            'Can not find healthy resource, type is [${notFoundResourceTypes.join(', ')}]',
        resourceTypes: notFoundResourceTypes,
      );
    }

    // Cache the selected resources
    final Uri? cachedFrontendUri = _bestServersStore?.getCachedFrontendUri();
    _bestServersStore?.saveBestResources(bestResults);

    final remoteConfigOverrides = bestResults.fold(<String, String>{}, (
      configs,
      result,
    ) {
      final resource = result.resource;
      return configs..addAll(resource.metadata?.remoteConfigOverrides ?? {});
    });
    _logger.debug('Remote config overrides: $remoteConfigOverrides');

    return SelectedDomainTrackerResources(
      uris: Map.fromEntries(
        bestResults.map((e) => MapEntry(e.resource.type, e.resource.uri)),
      ),
      overrideRemoteConfigs: remoteConfigOverrides,
      isFrontendChanged: bestFrontendResource?.uri != cachedFrontendUri,
    );
  }

  /// Fetches resource list for all resource types, and groups them by priority
  Future<Map<String, Map<int, List<DomainTrackerResource>>>>
  _fetchAllTypeResources(List<String> types, List<String>? labels) async {
    final result = await Future.wait(
      types.map(
        (
          type,
        ) => _repository.getResourceList(type: type, labels: labels).catchError((
          Object e,
        ) {
          _logger.debug(
            'Failed to get resource list from config server ("${domainTracker.host}") for type: $type',
            error: e,
          );
          return <DomainTrackerResource>[];
        }),
      ),
    );

    final Map<String, Map<int, List<DomainTrackerResource>>> serversList = {};
    for (final (int index, String type) in types.indexed) {
      final List<DomainTrackerResource> resources = result[index];
      final Map<int, List<DomainTrackerResource>> priorityGroups = {};
      for (final resource in resources) {
        priorityGroups.putIfAbsent(resource.priority, () => []).add(resource);
      }
      serversList[type] = priorityGroups;
    }
    return serversList;
  }
}
