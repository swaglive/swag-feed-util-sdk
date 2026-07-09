/// Pure-Dart domain-tracker core (GENP-3261 WS-A).
///
/// Shared by the user apps (which plug in their HttpRequestable-based
/// repository, log_kit, SharedPreferenceService and debug manager through the
/// ports) and by feed_util's Livestream SDK (which uses
/// [DioDomainTrackerRepository] with an injected Dio and the no-op defaults).
library;

export 'src/data/dio_domain_tracker_repository.dart';
export 'src/domain_tracker.dart';
export 'src/exception/domain_tracker_exceptions.dart';
export 'src/http/aes_decrypt_fused_transformer.dart';
export 'src/http/domain_tracker_auth_interceptor.dart';
export 'src/http/encrypted_domain_interceptor.dart';
export 'src/http/http_header.dart';
export 'src/http/time_profiling.dart';
export 'src/model/domain_tracker_resource.dart';
export 'src/model/domain_tracker_resource_measurement.dart';
export 'src/model/domain_tracker_resource_result.dart';
export 'src/model/resolved_domains.dart';
export 'src/model/selected_domain_tracker_resources.dart';
export 'src/port/domain_tracker_best_servers_store.dart';
export 'src/port/domain_tracker_health_reporter.dart';
export 'src/port/domain_tracker_logger.dart';
export 'src/repository/domain_tracker_repository.dart';
export 'src/use_case/fetch_domain_tracker_server_echo_use_case.dart';
export 'src/use_case/find_domain_tracker_best_resource_use_case.dart';
export 'src/use_case/find_domain_tracker_resource_use_case.dart';
export 'src/use_case/find_domain_tracker_server_use_case.dart';
export 'src/use_case/measure_domain_tracker_resource_use_case.dart';

// --- Livestream feed (GENP-3261 WS-B) ---
export 'src/data/dio_livestream_feed_repository.dart';
export 'src/data/livestream_feed_path_normalizer.dart';
export 'src/data/snapshot_url_builder.dart';
export 'src/model/livestream.dart';
export 'src/model/livestream_metadata.dart';
export 'src/model/livestream_mode.dart';
export 'src/model/livestream_status.dart';
export 'src/model/stream_schedule.dart';
export 'src/repository/livestream_feed_repository.dart';
export 'src/use_case/enrich_livestream_titles_use_case.dart';
export 'src/use_case/get_livestream_list_use_case.dart';
export 'src/use_case/get_stream_schedule_use_case.dart';
