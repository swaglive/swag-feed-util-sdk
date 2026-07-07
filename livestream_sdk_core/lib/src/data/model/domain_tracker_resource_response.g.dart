// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domain_tracker_resource_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainTrackerResourceResponse _$DomainTrackerResourceResponseFromJson(
  Map<String, dynamic> json,
) => _DomainTrackerResourceResponse(
  type: json['type'] as String?,
  url: json['url'] as String?,
  healthCheckPath: json['health_check_path'] as String?,
  healthCheckMethod: json['health_check_method'] as String?,
  priority: (json['priority'] as num?)?.toInt(),
  score: (json['score'] as num?)?.toInt(),
  lastChecked: json['last_checked'] == null
      ? null
      : DateTime.parse(json['last_checked'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  metadata: json['metadata'] == null
      ? null
      : DomainTrackerResourceMetadataResponse.fromJson(
          json['metadata'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$DomainTrackerResourceResponseToJson(
  _DomainTrackerResourceResponse instance,
) => <String, dynamic>{
  'type': instance.type,
  'url': instance.url,
  'health_check_path': instance.healthCheckPath,
  'health_check_method': instance.healthCheckMethod,
  'priority': instance.priority,
  'score': instance.score,
  'last_checked': instance.lastChecked?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'metadata': instance.metadata,
};

_DomainTrackerResourceMetadataResponse
_$DomainTrackerResourceMetadataResponseFromJson(Map<String, dynamic> json) =>
    _DomainTrackerResourceMetadataResponse(
      skipHealthCheck: json['skip_health_check'] as bool?,
      remoteConfigOverrides:
          (json['remote_config_overrides'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ),
      healthCheckConfig: json['health_check_config'] == null
          ? null
          : DomainTrackerResourceHealthCheckConfigResponse.fromJson(
              json['health_check_config'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$DomainTrackerResourceMetadataResponseToJson(
  _DomainTrackerResourceMetadataResponse instance,
) => <String, dynamic>{
  'skip_health_check': instance.skipHealthCheck,
  'remote_config_overrides': instance.remoteConfigOverrides,
  'health_check_config': instance.healthCheckConfig,
};

_DomainTrackerResourceHealthCheckConfigResponse
_$DomainTrackerResourceHealthCheckConfigResponseFromJson(
  Map<String, dynamic> json,
) => _DomainTrackerResourceHealthCheckConfigResponse(
  range: (json['range'] as num?)?.toInt(),
  duration: _$JsonConverterFromJson<int, Duration>(
    json['duration'],
    const MillisecondsToDurationConverter().fromJson,
  ),
);

Map<String, dynamic> _$DomainTrackerResourceHealthCheckConfigResponseToJson(
  _DomainTrackerResourceHealthCheckConfigResponse instance,
) => <String, dynamic>{
  'range': instance.range,
  'duration': _$JsonConverterToJson<int, Duration>(
    instance.duration,
    const MillisecondsToDurationConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
