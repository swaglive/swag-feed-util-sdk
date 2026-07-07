// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'domain_tracker_resource_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainTrackerResourceResponse {

 String? get type; String? get url;/// Path to check the health of the resource
@JsonKey(name: 'health_check_path') String? get healthCheckPath;/// HTTP method to check the health of the resource
@JsonKey(name: 'health_check_method') String? get healthCheckMethod;/// Priority of the resource, 0 is the highest priority
 int? get priority;/// Availability score (percentage), between 0 and 100
 int? get score;/// When the resource was last checked
@JsonKey(name: 'last_checked') DateTime? get lastChecked;/// When the resource was created
 DateTime? get createdAt;/// Metadata of the resource
 DomainTrackerResourceMetadataResponse? get metadata;
/// Create a copy of DomainTrackerResourceResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTrackerResourceResponseCopyWith<DomainTrackerResourceResponse> get copyWith => _$DomainTrackerResourceResponseCopyWithImpl<DomainTrackerResourceResponse>(this as DomainTrackerResourceResponse, _$identity);

  /// Serializes this DomainTrackerResourceResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTrackerResourceResponse&&(identical(other.type, type) || other.type == type)&&(identical(other.url, url) || other.url == url)&&(identical(other.healthCheckPath, healthCheckPath) || other.healthCheckPath == healthCheckPath)&&(identical(other.healthCheckMethod, healthCheckMethod) || other.healthCheckMethod == healthCheckMethod)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.score, score) || other.score == score)&&(identical(other.lastChecked, lastChecked) || other.lastChecked == lastChecked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,url,healthCheckPath,healthCheckMethod,priority,score,lastChecked,createdAt,metadata);

@override
String toString() {
  return 'DomainTrackerResourceResponse(type: $type, url: $url, healthCheckPath: $healthCheckPath, healthCheckMethod: $healthCheckMethod, priority: $priority, score: $score, lastChecked: $lastChecked, createdAt: $createdAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DomainTrackerResourceResponseCopyWith<$Res>  {
  factory $DomainTrackerResourceResponseCopyWith(DomainTrackerResourceResponse value, $Res Function(DomainTrackerResourceResponse) _then) = _$DomainTrackerResourceResponseCopyWithImpl;
@useResult
$Res call({
 String? type, String? url,@JsonKey(name: 'health_check_path') String? healthCheckPath,@JsonKey(name: 'health_check_method') String? healthCheckMethod, int? priority, int? score,@JsonKey(name: 'last_checked') DateTime? lastChecked, DateTime? createdAt, DomainTrackerResourceMetadataResponse? metadata
});


$DomainTrackerResourceMetadataResponseCopyWith<$Res>? get metadata;

}
/// @nodoc
class _$DomainTrackerResourceResponseCopyWithImpl<$Res>
    implements $DomainTrackerResourceResponseCopyWith<$Res> {
  _$DomainTrackerResourceResponseCopyWithImpl(this._self, this._then);

  final DomainTrackerResourceResponse _self;
  final $Res Function(DomainTrackerResourceResponse) _then;

/// Create a copy of DomainTrackerResourceResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? url = freezed,Object? healthCheckPath = freezed,Object? healthCheckMethod = freezed,Object? priority = freezed,Object? score = freezed,Object? lastChecked = freezed,Object? createdAt = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,healthCheckPath: freezed == healthCheckPath ? _self.healthCheckPath : healthCheckPath // ignore: cast_nullable_to_non_nullable
as String?,healthCheckMethod: freezed == healthCheckMethod ? _self.healthCheckMethod : healthCheckMethod // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int?,lastChecked: freezed == lastChecked ? _self.lastChecked : lastChecked // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as DomainTrackerResourceMetadataResponse?,
  ));
}
/// Create a copy of DomainTrackerResourceResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainTrackerResourceMetadataResponseCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $DomainTrackerResourceMetadataResponseCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [DomainTrackerResourceResponse].
extension DomainTrackerResourceResponsePatterns on DomainTrackerResourceResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainTrackerResourceResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainTrackerResourceResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainTrackerResourceResponse value)  $default,){
final _that = this;
switch (_that) {
case _DomainTrackerResourceResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainTrackerResourceResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DomainTrackerResourceResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? type,  String? url, @JsonKey(name: 'health_check_path')  String? healthCheckPath, @JsonKey(name: 'health_check_method')  String? healthCheckMethod,  int? priority,  int? score, @JsonKey(name: 'last_checked')  DateTime? lastChecked,  DateTime? createdAt,  DomainTrackerResourceMetadataResponse? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainTrackerResourceResponse() when $default != null:
return $default(_that.type,_that.url,_that.healthCheckPath,_that.healthCheckMethod,_that.priority,_that.score,_that.lastChecked,_that.createdAt,_that.metadata);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? type,  String? url, @JsonKey(name: 'health_check_path')  String? healthCheckPath, @JsonKey(name: 'health_check_method')  String? healthCheckMethod,  int? priority,  int? score, @JsonKey(name: 'last_checked')  DateTime? lastChecked,  DateTime? createdAt,  DomainTrackerResourceMetadataResponse? metadata)  $default,) {final _that = this;
switch (_that) {
case _DomainTrackerResourceResponse():
return $default(_that.type,_that.url,_that.healthCheckPath,_that.healthCheckMethod,_that.priority,_that.score,_that.lastChecked,_that.createdAt,_that.metadata);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? type,  String? url, @JsonKey(name: 'health_check_path')  String? healthCheckPath, @JsonKey(name: 'health_check_method')  String? healthCheckMethod,  int? priority,  int? score, @JsonKey(name: 'last_checked')  DateTime? lastChecked,  DateTime? createdAt,  DomainTrackerResourceMetadataResponse? metadata)?  $default,) {final _that = this;
switch (_that) {
case _DomainTrackerResourceResponse() when $default != null:
return $default(_that.type,_that.url,_that.healthCheckPath,_that.healthCheckMethod,_that.priority,_that.score,_that.lastChecked,_that.createdAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainTrackerResourceResponse implements DomainTrackerResourceResponse {
  const _DomainTrackerResourceResponse({this.type, this.url, @JsonKey(name: 'health_check_path') this.healthCheckPath, @JsonKey(name: 'health_check_method') this.healthCheckMethod, this.priority, this.score, @JsonKey(name: 'last_checked') this.lastChecked, this.createdAt, this.metadata});
  factory _DomainTrackerResourceResponse.fromJson(Map<String, dynamic> json) => _$DomainTrackerResourceResponseFromJson(json);

@override final  String? type;
@override final  String? url;
/// Path to check the health of the resource
@override@JsonKey(name: 'health_check_path') final  String? healthCheckPath;
/// HTTP method to check the health of the resource
@override@JsonKey(name: 'health_check_method') final  String? healthCheckMethod;
/// Priority of the resource, 0 is the highest priority
@override final  int? priority;
/// Availability score (percentage), between 0 and 100
@override final  int? score;
/// When the resource was last checked
@override@JsonKey(name: 'last_checked') final  DateTime? lastChecked;
/// When the resource was created
@override final  DateTime? createdAt;
/// Metadata of the resource
@override final  DomainTrackerResourceMetadataResponse? metadata;

/// Create a copy of DomainTrackerResourceResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainTrackerResourceResponseCopyWith<_DomainTrackerResourceResponse> get copyWith => __$DomainTrackerResourceResponseCopyWithImpl<_DomainTrackerResourceResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainTrackerResourceResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainTrackerResourceResponse&&(identical(other.type, type) || other.type == type)&&(identical(other.url, url) || other.url == url)&&(identical(other.healthCheckPath, healthCheckPath) || other.healthCheckPath == healthCheckPath)&&(identical(other.healthCheckMethod, healthCheckMethod) || other.healthCheckMethod == healthCheckMethod)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.score, score) || other.score == score)&&(identical(other.lastChecked, lastChecked) || other.lastChecked == lastChecked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,url,healthCheckPath,healthCheckMethod,priority,score,lastChecked,createdAt,metadata);

@override
String toString() {
  return 'DomainTrackerResourceResponse(type: $type, url: $url, healthCheckPath: $healthCheckPath, healthCheckMethod: $healthCheckMethod, priority: $priority, score: $score, lastChecked: $lastChecked, createdAt: $createdAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DomainTrackerResourceResponseCopyWith<$Res> implements $DomainTrackerResourceResponseCopyWith<$Res> {
  factory _$DomainTrackerResourceResponseCopyWith(_DomainTrackerResourceResponse value, $Res Function(_DomainTrackerResourceResponse) _then) = __$DomainTrackerResourceResponseCopyWithImpl;
@override @useResult
$Res call({
 String? type, String? url,@JsonKey(name: 'health_check_path') String? healthCheckPath,@JsonKey(name: 'health_check_method') String? healthCheckMethod, int? priority, int? score,@JsonKey(name: 'last_checked') DateTime? lastChecked, DateTime? createdAt, DomainTrackerResourceMetadataResponse? metadata
});


@override $DomainTrackerResourceMetadataResponseCopyWith<$Res>? get metadata;

}
/// @nodoc
class __$DomainTrackerResourceResponseCopyWithImpl<$Res>
    implements _$DomainTrackerResourceResponseCopyWith<$Res> {
  __$DomainTrackerResourceResponseCopyWithImpl(this._self, this._then);

  final _DomainTrackerResourceResponse _self;
  final $Res Function(_DomainTrackerResourceResponse) _then;

/// Create a copy of DomainTrackerResourceResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? url = freezed,Object? healthCheckPath = freezed,Object? healthCheckMethod = freezed,Object? priority = freezed,Object? score = freezed,Object? lastChecked = freezed,Object? createdAt = freezed,Object? metadata = freezed,}) {
  return _then(_DomainTrackerResourceResponse(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,healthCheckPath: freezed == healthCheckPath ? _self.healthCheckPath : healthCheckPath // ignore: cast_nullable_to_non_nullable
as String?,healthCheckMethod: freezed == healthCheckMethod ? _self.healthCheckMethod : healthCheckMethod // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int?,lastChecked: freezed == lastChecked ? _self.lastChecked : lastChecked // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as DomainTrackerResourceMetadataResponse?,
  ));
}

/// Create a copy of DomainTrackerResourceResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainTrackerResourceMetadataResponseCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $DomainTrackerResourceMetadataResponseCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// @nodoc
mixin _$DomainTrackerResourceMetadataResponse {

/// Whether to skip the health check for this resource
@JsonKey(name: 'skip_health_check') bool? get skipHealthCheck;/// Remote configs which needs to be overrided for this resource
@JsonKey(name: 'remote_config_overrides') Map<String, String>? get remoteConfigOverrides;/// Configs for how to do the health check
@JsonKey(name: 'health_check_config') DomainTrackerResourceHealthCheckConfigResponse? get healthCheckConfig;
/// Create a copy of DomainTrackerResourceMetadataResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTrackerResourceMetadataResponseCopyWith<DomainTrackerResourceMetadataResponse> get copyWith => _$DomainTrackerResourceMetadataResponseCopyWithImpl<DomainTrackerResourceMetadataResponse>(this as DomainTrackerResourceMetadataResponse, _$identity);

  /// Serializes this DomainTrackerResourceMetadataResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTrackerResourceMetadataResponse&&(identical(other.skipHealthCheck, skipHealthCheck) || other.skipHealthCheck == skipHealthCheck)&&const DeepCollectionEquality().equals(other.remoteConfigOverrides, remoteConfigOverrides)&&(identical(other.healthCheckConfig, healthCheckConfig) || other.healthCheckConfig == healthCheckConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,skipHealthCheck,const DeepCollectionEquality().hash(remoteConfigOverrides),healthCheckConfig);

@override
String toString() {
  return 'DomainTrackerResourceMetadataResponse(skipHealthCheck: $skipHealthCheck, remoteConfigOverrides: $remoteConfigOverrides, healthCheckConfig: $healthCheckConfig)';
}


}

/// @nodoc
abstract mixin class $DomainTrackerResourceMetadataResponseCopyWith<$Res>  {
  factory $DomainTrackerResourceMetadataResponseCopyWith(DomainTrackerResourceMetadataResponse value, $Res Function(DomainTrackerResourceMetadataResponse) _then) = _$DomainTrackerResourceMetadataResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'skip_health_check') bool? skipHealthCheck,@JsonKey(name: 'remote_config_overrides') Map<String, String>? remoteConfigOverrides,@JsonKey(name: 'health_check_config') DomainTrackerResourceHealthCheckConfigResponse? healthCheckConfig
});


$DomainTrackerResourceHealthCheckConfigResponseCopyWith<$Res>? get healthCheckConfig;

}
/// @nodoc
class _$DomainTrackerResourceMetadataResponseCopyWithImpl<$Res>
    implements $DomainTrackerResourceMetadataResponseCopyWith<$Res> {
  _$DomainTrackerResourceMetadataResponseCopyWithImpl(this._self, this._then);

  final DomainTrackerResourceMetadataResponse _self;
  final $Res Function(DomainTrackerResourceMetadataResponse) _then;

/// Create a copy of DomainTrackerResourceMetadataResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? skipHealthCheck = freezed,Object? remoteConfigOverrides = freezed,Object? healthCheckConfig = freezed,}) {
  return _then(_self.copyWith(
skipHealthCheck: freezed == skipHealthCheck ? _self.skipHealthCheck : skipHealthCheck // ignore: cast_nullable_to_non_nullable
as bool?,remoteConfigOverrides: freezed == remoteConfigOverrides ? _self.remoteConfigOverrides : remoteConfigOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,healthCheckConfig: freezed == healthCheckConfig ? _self.healthCheckConfig : healthCheckConfig // ignore: cast_nullable_to_non_nullable
as DomainTrackerResourceHealthCheckConfigResponse?,
  ));
}
/// Create a copy of DomainTrackerResourceMetadataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainTrackerResourceHealthCheckConfigResponseCopyWith<$Res>? get healthCheckConfig {
    if (_self.healthCheckConfig == null) {
    return null;
  }

  return $DomainTrackerResourceHealthCheckConfigResponseCopyWith<$Res>(_self.healthCheckConfig!, (value) {
    return _then(_self.copyWith(healthCheckConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [DomainTrackerResourceMetadataResponse].
extension DomainTrackerResourceMetadataResponsePatterns on DomainTrackerResourceMetadataResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainTrackerResourceMetadataResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainTrackerResourceMetadataResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainTrackerResourceMetadataResponse value)  $default,){
final _that = this;
switch (_that) {
case _DomainTrackerResourceMetadataResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainTrackerResourceMetadataResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DomainTrackerResourceMetadataResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'skip_health_check')  bool? skipHealthCheck, @JsonKey(name: 'remote_config_overrides')  Map<String, String>? remoteConfigOverrides, @JsonKey(name: 'health_check_config')  DomainTrackerResourceHealthCheckConfigResponse? healthCheckConfig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainTrackerResourceMetadataResponse() when $default != null:
return $default(_that.skipHealthCheck,_that.remoteConfigOverrides,_that.healthCheckConfig);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'skip_health_check')  bool? skipHealthCheck, @JsonKey(name: 'remote_config_overrides')  Map<String, String>? remoteConfigOverrides, @JsonKey(name: 'health_check_config')  DomainTrackerResourceHealthCheckConfigResponse? healthCheckConfig)  $default,) {final _that = this;
switch (_that) {
case _DomainTrackerResourceMetadataResponse():
return $default(_that.skipHealthCheck,_that.remoteConfigOverrides,_that.healthCheckConfig);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'skip_health_check')  bool? skipHealthCheck, @JsonKey(name: 'remote_config_overrides')  Map<String, String>? remoteConfigOverrides, @JsonKey(name: 'health_check_config')  DomainTrackerResourceHealthCheckConfigResponse? healthCheckConfig)?  $default,) {final _that = this;
switch (_that) {
case _DomainTrackerResourceMetadataResponse() when $default != null:
return $default(_that.skipHealthCheck,_that.remoteConfigOverrides,_that.healthCheckConfig);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainTrackerResourceMetadataResponse implements DomainTrackerResourceMetadataResponse {
  const _DomainTrackerResourceMetadataResponse({@JsonKey(name: 'skip_health_check') this.skipHealthCheck, @JsonKey(name: 'remote_config_overrides') final  Map<String, String>? remoteConfigOverrides, @JsonKey(name: 'health_check_config') this.healthCheckConfig}): _remoteConfigOverrides = remoteConfigOverrides;
  factory _DomainTrackerResourceMetadataResponse.fromJson(Map<String, dynamic> json) => _$DomainTrackerResourceMetadataResponseFromJson(json);

/// Whether to skip the health check for this resource
@override@JsonKey(name: 'skip_health_check') final  bool? skipHealthCheck;
/// Remote configs which needs to be overrided for this resource
 final  Map<String, String>? _remoteConfigOverrides;
/// Remote configs which needs to be overrided for this resource
@override@JsonKey(name: 'remote_config_overrides') Map<String, String>? get remoteConfigOverrides {
  final value = _remoteConfigOverrides;
  if (value == null) return null;
  if (_remoteConfigOverrides is EqualUnmodifiableMapView) return _remoteConfigOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Configs for how to do the health check
@override@JsonKey(name: 'health_check_config') final  DomainTrackerResourceHealthCheckConfigResponse? healthCheckConfig;

/// Create a copy of DomainTrackerResourceMetadataResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainTrackerResourceMetadataResponseCopyWith<_DomainTrackerResourceMetadataResponse> get copyWith => __$DomainTrackerResourceMetadataResponseCopyWithImpl<_DomainTrackerResourceMetadataResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainTrackerResourceMetadataResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainTrackerResourceMetadataResponse&&(identical(other.skipHealthCheck, skipHealthCheck) || other.skipHealthCheck == skipHealthCheck)&&const DeepCollectionEquality().equals(other._remoteConfigOverrides, _remoteConfigOverrides)&&(identical(other.healthCheckConfig, healthCheckConfig) || other.healthCheckConfig == healthCheckConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,skipHealthCheck,const DeepCollectionEquality().hash(_remoteConfigOverrides),healthCheckConfig);

@override
String toString() {
  return 'DomainTrackerResourceMetadataResponse(skipHealthCheck: $skipHealthCheck, remoteConfigOverrides: $remoteConfigOverrides, healthCheckConfig: $healthCheckConfig)';
}


}

/// @nodoc
abstract mixin class _$DomainTrackerResourceMetadataResponseCopyWith<$Res> implements $DomainTrackerResourceMetadataResponseCopyWith<$Res> {
  factory _$DomainTrackerResourceMetadataResponseCopyWith(_DomainTrackerResourceMetadataResponse value, $Res Function(_DomainTrackerResourceMetadataResponse) _then) = __$DomainTrackerResourceMetadataResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'skip_health_check') bool? skipHealthCheck,@JsonKey(name: 'remote_config_overrides') Map<String, String>? remoteConfigOverrides,@JsonKey(name: 'health_check_config') DomainTrackerResourceHealthCheckConfigResponse? healthCheckConfig
});


@override $DomainTrackerResourceHealthCheckConfigResponseCopyWith<$Res>? get healthCheckConfig;

}
/// @nodoc
class __$DomainTrackerResourceMetadataResponseCopyWithImpl<$Res>
    implements _$DomainTrackerResourceMetadataResponseCopyWith<$Res> {
  __$DomainTrackerResourceMetadataResponseCopyWithImpl(this._self, this._then);

  final _DomainTrackerResourceMetadataResponse _self;
  final $Res Function(_DomainTrackerResourceMetadataResponse) _then;

/// Create a copy of DomainTrackerResourceMetadataResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? skipHealthCheck = freezed,Object? remoteConfigOverrides = freezed,Object? healthCheckConfig = freezed,}) {
  return _then(_DomainTrackerResourceMetadataResponse(
skipHealthCheck: freezed == skipHealthCheck ? _self.skipHealthCheck : skipHealthCheck // ignore: cast_nullable_to_non_nullable
as bool?,remoteConfigOverrides: freezed == remoteConfigOverrides ? _self._remoteConfigOverrides : remoteConfigOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,healthCheckConfig: freezed == healthCheckConfig ? _self.healthCheckConfig : healthCheckConfig // ignore: cast_nullable_to_non_nullable
as DomainTrackerResourceHealthCheckConfigResponse?,
  ));
}

/// Create a copy of DomainTrackerResourceMetadataResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainTrackerResourceHealthCheckConfigResponseCopyWith<$Res>? get healthCheckConfig {
    if (_self.healthCheckConfig == null) {
    return null;
  }

  return $DomainTrackerResourceHealthCheckConfigResponseCopyWith<$Res>(_self.healthCheckConfig!, (value) {
    return _then(_self.copyWith(healthCheckConfig: value));
  });
}
}


/// @nodoc
mixin _$DomainTrackerResourceHealthCheckConfigResponse {

 int? get range;@MillisecondsToDurationConverter() Duration? get duration;
/// Create a copy of DomainTrackerResourceHealthCheckConfigResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTrackerResourceHealthCheckConfigResponseCopyWith<DomainTrackerResourceHealthCheckConfigResponse> get copyWith => _$DomainTrackerResourceHealthCheckConfigResponseCopyWithImpl<DomainTrackerResourceHealthCheckConfigResponse>(this as DomainTrackerResourceHealthCheckConfigResponse, _$identity);

  /// Serializes this DomainTrackerResourceHealthCheckConfigResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTrackerResourceHealthCheckConfigResponse&&(identical(other.range, range) || other.range == range)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,range,duration);

@override
String toString() {
  return 'DomainTrackerResourceHealthCheckConfigResponse(range: $range, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $DomainTrackerResourceHealthCheckConfigResponseCopyWith<$Res>  {
  factory $DomainTrackerResourceHealthCheckConfigResponseCopyWith(DomainTrackerResourceHealthCheckConfigResponse value, $Res Function(DomainTrackerResourceHealthCheckConfigResponse) _then) = _$DomainTrackerResourceHealthCheckConfigResponseCopyWithImpl;
@useResult
$Res call({
 int? range,@MillisecondsToDurationConverter() Duration? duration
});




}
/// @nodoc
class _$DomainTrackerResourceHealthCheckConfigResponseCopyWithImpl<$Res>
    implements $DomainTrackerResourceHealthCheckConfigResponseCopyWith<$Res> {
  _$DomainTrackerResourceHealthCheckConfigResponseCopyWithImpl(this._self, this._then);

  final DomainTrackerResourceHealthCheckConfigResponse _self;
  final $Res Function(DomainTrackerResourceHealthCheckConfigResponse) _then;

/// Create a copy of DomainTrackerResourceHealthCheckConfigResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? range = freezed,Object? duration = freezed,}) {
  return _then(_self.copyWith(
range: freezed == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as int?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainTrackerResourceHealthCheckConfigResponse].
extension DomainTrackerResourceHealthCheckConfigResponsePatterns on DomainTrackerResourceHealthCheckConfigResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainTrackerResourceHealthCheckConfigResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainTrackerResourceHealthCheckConfigResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainTrackerResourceHealthCheckConfigResponse value)  $default,){
final _that = this;
switch (_that) {
case _DomainTrackerResourceHealthCheckConfigResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainTrackerResourceHealthCheckConfigResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DomainTrackerResourceHealthCheckConfigResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? range, @MillisecondsToDurationConverter()  Duration? duration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainTrackerResourceHealthCheckConfigResponse() when $default != null:
return $default(_that.range,_that.duration);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? range, @MillisecondsToDurationConverter()  Duration? duration)  $default,) {final _that = this;
switch (_that) {
case _DomainTrackerResourceHealthCheckConfigResponse():
return $default(_that.range,_that.duration);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? range, @MillisecondsToDurationConverter()  Duration? duration)?  $default,) {final _that = this;
switch (_that) {
case _DomainTrackerResourceHealthCheckConfigResponse() when $default != null:
return $default(_that.range,_that.duration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainTrackerResourceHealthCheckConfigResponse implements DomainTrackerResourceHealthCheckConfigResponse {
  const _DomainTrackerResourceHealthCheckConfigResponse({this.range, @MillisecondsToDurationConverter() this.duration});
  factory _DomainTrackerResourceHealthCheckConfigResponse.fromJson(Map<String, dynamic> json) => _$DomainTrackerResourceHealthCheckConfigResponseFromJson(json);

@override final  int? range;
@override@MillisecondsToDurationConverter() final  Duration? duration;

/// Create a copy of DomainTrackerResourceHealthCheckConfigResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainTrackerResourceHealthCheckConfigResponseCopyWith<_DomainTrackerResourceHealthCheckConfigResponse> get copyWith => __$DomainTrackerResourceHealthCheckConfigResponseCopyWithImpl<_DomainTrackerResourceHealthCheckConfigResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainTrackerResourceHealthCheckConfigResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainTrackerResourceHealthCheckConfigResponse&&(identical(other.range, range) || other.range == range)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,range,duration);

@override
String toString() {
  return 'DomainTrackerResourceHealthCheckConfigResponse(range: $range, duration: $duration)';
}


}

/// @nodoc
abstract mixin class _$DomainTrackerResourceHealthCheckConfigResponseCopyWith<$Res> implements $DomainTrackerResourceHealthCheckConfigResponseCopyWith<$Res> {
  factory _$DomainTrackerResourceHealthCheckConfigResponseCopyWith(_DomainTrackerResourceHealthCheckConfigResponse value, $Res Function(_DomainTrackerResourceHealthCheckConfigResponse) _then) = __$DomainTrackerResourceHealthCheckConfigResponseCopyWithImpl;
@override @useResult
$Res call({
 int? range,@MillisecondsToDurationConverter() Duration? duration
});




}
/// @nodoc
class __$DomainTrackerResourceHealthCheckConfigResponseCopyWithImpl<$Res>
    implements _$DomainTrackerResourceHealthCheckConfigResponseCopyWith<$Res> {
  __$DomainTrackerResourceHealthCheckConfigResponseCopyWithImpl(this._self, this._then);

  final _DomainTrackerResourceHealthCheckConfigResponse _self;
  final $Res Function(_DomainTrackerResourceHealthCheckConfigResponse) _then;

/// Create a copy of DomainTrackerResourceHealthCheckConfigResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? range = freezed,Object? duration = freezed,}) {
  return _then(_DomainTrackerResourceHealthCheckConfigResponse(
range: freezed == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as int?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

// dart format on
