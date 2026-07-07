// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'domain_tracker_resource.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DomainTrackerResource {

/// The type of the resource
 String get type;/// The URI of the resource
 Uri get uri;/// Path to check the health of the resource
 String get healthCheckPath;/// HTTP method to check the health of the resource
 String get healthCheckMethod;/// Priority of the resource, 0 is the highest priority
 int get priority;/// The score of the resource
 int get score;/// When the resource was last checked
 DateTime? get lastChecked;/// When the resource was created
 DateTime? get createdAt;/// Metadata of the resource
 DomainTrackerResourceMetadata? get metadata;
/// Create a copy of DomainTrackerResource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTrackerResourceCopyWith<DomainTrackerResource> get copyWith => _$DomainTrackerResourceCopyWithImpl<DomainTrackerResource>(this as DomainTrackerResource, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTrackerResource&&(identical(other.type, type) || other.type == type)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.healthCheckPath, healthCheckPath) || other.healthCheckPath == healthCheckPath)&&(identical(other.healthCheckMethod, healthCheckMethod) || other.healthCheckMethod == healthCheckMethod)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.score, score) || other.score == score)&&(identical(other.lastChecked, lastChecked) || other.lastChecked == lastChecked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}


@override
int get hashCode => Object.hash(runtimeType,type,uri,healthCheckPath,healthCheckMethod,priority,score,lastChecked,createdAt,metadata);

@override
String toString() {
  return 'DomainTrackerResource(type: $type, uri: $uri, healthCheckPath: $healthCheckPath, healthCheckMethod: $healthCheckMethod, priority: $priority, score: $score, lastChecked: $lastChecked, createdAt: $createdAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DomainTrackerResourceCopyWith<$Res>  {
  factory $DomainTrackerResourceCopyWith(DomainTrackerResource value, $Res Function(DomainTrackerResource) _then) = _$DomainTrackerResourceCopyWithImpl;
@useResult
$Res call({
 String type, Uri uri, String healthCheckPath, String healthCheckMethod, int priority, int score, DateTime? lastChecked, DateTime? createdAt, DomainTrackerResourceMetadata? metadata
});


$DomainTrackerResourceMetadataCopyWith<$Res>? get metadata;

}
/// @nodoc
class _$DomainTrackerResourceCopyWithImpl<$Res>
    implements $DomainTrackerResourceCopyWith<$Res> {
  _$DomainTrackerResourceCopyWithImpl(this._self, this._then);

  final DomainTrackerResource _self;
  final $Res Function(DomainTrackerResource) _then;

/// Create a copy of DomainTrackerResource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? uri = null,Object? healthCheckPath = null,Object? healthCheckMethod = null,Object? priority = null,Object? score = null,Object? lastChecked = freezed,Object? createdAt = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as Uri,healthCheckPath: null == healthCheckPath ? _self.healthCheckPath : healthCheckPath // ignore: cast_nullable_to_non_nullable
as String,healthCheckMethod: null == healthCheckMethod ? _self.healthCheckMethod : healthCheckMethod // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,lastChecked: freezed == lastChecked ? _self.lastChecked : lastChecked // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as DomainTrackerResourceMetadata?,
  ));
}
/// Create a copy of DomainTrackerResource
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainTrackerResourceMetadataCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $DomainTrackerResourceMetadataCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [DomainTrackerResource].
extension DomainTrackerResourcePatterns on DomainTrackerResource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainTrackerResource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainTrackerResource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainTrackerResource value)  $default,){
final _that = this;
switch (_that) {
case _DomainTrackerResource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainTrackerResource value)?  $default,){
final _that = this;
switch (_that) {
case _DomainTrackerResource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  Uri uri,  String healthCheckPath,  String healthCheckMethod,  int priority,  int score,  DateTime? lastChecked,  DateTime? createdAt,  DomainTrackerResourceMetadata? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainTrackerResource() when $default != null:
return $default(_that.type,_that.uri,_that.healthCheckPath,_that.healthCheckMethod,_that.priority,_that.score,_that.lastChecked,_that.createdAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  Uri uri,  String healthCheckPath,  String healthCheckMethod,  int priority,  int score,  DateTime? lastChecked,  DateTime? createdAt,  DomainTrackerResourceMetadata? metadata)  $default,) {final _that = this;
switch (_that) {
case _DomainTrackerResource():
return $default(_that.type,_that.uri,_that.healthCheckPath,_that.healthCheckMethod,_that.priority,_that.score,_that.lastChecked,_that.createdAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  Uri uri,  String healthCheckPath,  String healthCheckMethod,  int priority,  int score,  DateTime? lastChecked,  DateTime? createdAt,  DomainTrackerResourceMetadata? metadata)?  $default,) {final _that = this;
switch (_that) {
case _DomainTrackerResource() when $default != null:
return $default(_that.type,_that.uri,_that.healthCheckPath,_that.healthCheckMethod,_that.priority,_that.score,_that.lastChecked,_that.createdAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc


class _DomainTrackerResource extends DomainTrackerResource {
  const _DomainTrackerResource({required this.type, required this.uri, required this.healthCheckPath, required this.healthCheckMethod, required this.priority, required this.score, this.lastChecked, this.createdAt, this.metadata}): super._();
  

/// The type of the resource
@override final  String type;
/// The URI of the resource
@override final  Uri uri;
/// Path to check the health of the resource
@override final  String healthCheckPath;
/// HTTP method to check the health of the resource
@override final  String healthCheckMethod;
/// Priority of the resource, 0 is the highest priority
@override final  int priority;
/// The score of the resource
@override final  int score;
/// When the resource was last checked
@override final  DateTime? lastChecked;
/// When the resource was created
@override final  DateTime? createdAt;
/// Metadata of the resource
@override final  DomainTrackerResourceMetadata? metadata;

/// Create a copy of DomainTrackerResource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainTrackerResourceCopyWith<_DomainTrackerResource> get copyWith => __$DomainTrackerResourceCopyWithImpl<_DomainTrackerResource>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainTrackerResource&&(identical(other.type, type) || other.type == type)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.healthCheckPath, healthCheckPath) || other.healthCheckPath == healthCheckPath)&&(identical(other.healthCheckMethod, healthCheckMethod) || other.healthCheckMethod == healthCheckMethod)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.score, score) || other.score == score)&&(identical(other.lastChecked, lastChecked) || other.lastChecked == lastChecked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}


@override
int get hashCode => Object.hash(runtimeType,type,uri,healthCheckPath,healthCheckMethod,priority,score,lastChecked,createdAt,metadata);

@override
String toString() {
  return 'DomainTrackerResource(type: $type, uri: $uri, healthCheckPath: $healthCheckPath, healthCheckMethod: $healthCheckMethod, priority: $priority, score: $score, lastChecked: $lastChecked, createdAt: $createdAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DomainTrackerResourceCopyWith<$Res> implements $DomainTrackerResourceCopyWith<$Res> {
  factory _$DomainTrackerResourceCopyWith(_DomainTrackerResource value, $Res Function(_DomainTrackerResource) _then) = __$DomainTrackerResourceCopyWithImpl;
@override @useResult
$Res call({
 String type, Uri uri, String healthCheckPath, String healthCheckMethod, int priority, int score, DateTime? lastChecked, DateTime? createdAt, DomainTrackerResourceMetadata? metadata
});


@override $DomainTrackerResourceMetadataCopyWith<$Res>? get metadata;

}
/// @nodoc
class __$DomainTrackerResourceCopyWithImpl<$Res>
    implements _$DomainTrackerResourceCopyWith<$Res> {
  __$DomainTrackerResourceCopyWithImpl(this._self, this._then);

  final _DomainTrackerResource _self;
  final $Res Function(_DomainTrackerResource) _then;

/// Create a copy of DomainTrackerResource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? uri = null,Object? healthCheckPath = null,Object? healthCheckMethod = null,Object? priority = null,Object? score = null,Object? lastChecked = freezed,Object? createdAt = freezed,Object? metadata = freezed,}) {
  return _then(_DomainTrackerResource(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as Uri,healthCheckPath: null == healthCheckPath ? _self.healthCheckPath : healthCheckPath // ignore: cast_nullable_to_non_nullable
as String,healthCheckMethod: null == healthCheckMethod ? _self.healthCheckMethod : healthCheckMethod // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,lastChecked: freezed == lastChecked ? _self.lastChecked : lastChecked // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as DomainTrackerResourceMetadata?,
  ));
}

/// Create a copy of DomainTrackerResource
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainTrackerResourceMetadataCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $DomainTrackerResourceMetadataCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}

/// @nodoc
mixin _$DomainTrackerResourceMetadata {

 bool? get skipHealthCheck; Map<String, String>? get remoteConfigOverrides; DomainTrackerResourceHealthCheckConfig? get healthCheckConfig;
/// Create a copy of DomainTrackerResourceMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTrackerResourceMetadataCopyWith<DomainTrackerResourceMetadata> get copyWith => _$DomainTrackerResourceMetadataCopyWithImpl<DomainTrackerResourceMetadata>(this as DomainTrackerResourceMetadata, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTrackerResourceMetadata&&(identical(other.skipHealthCheck, skipHealthCheck) || other.skipHealthCheck == skipHealthCheck)&&const DeepCollectionEquality().equals(other.remoteConfigOverrides, remoteConfigOverrides)&&(identical(other.healthCheckConfig, healthCheckConfig) || other.healthCheckConfig == healthCheckConfig));
}


@override
int get hashCode => Object.hash(runtimeType,skipHealthCheck,const DeepCollectionEquality().hash(remoteConfigOverrides),healthCheckConfig);

@override
String toString() {
  return 'DomainTrackerResourceMetadata(skipHealthCheck: $skipHealthCheck, remoteConfigOverrides: $remoteConfigOverrides, healthCheckConfig: $healthCheckConfig)';
}


}

/// @nodoc
abstract mixin class $DomainTrackerResourceMetadataCopyWith<$Res>  {
  factory $DomainTrackerResourceMetadataCopyWith(DomainTrackerResourceMetadata value, $Res Function(DomainTrackerResourceMetadata) _then) = _$DomainTrackerResourceMetadataCopyWithImpl;
@useResult
$Res call({
 bool? skipHealthCheck, Map<String, String>? remoteConfigOverrides, DomainTrackerResourceHealthCheckConfig? healthCheckConfig
});


$DomainTrackerResourceHealthCheckConfigCopyWith<$Res>? get healthCheckConfig;

}
/// @nodoc
class _$DomainTrackerResourceMetadataCopyWithImpl<$Res>
    implements $DomainTrackerResourceMetadataCopyWith<$Res> {
  _$DomainTrackerResourceMetadataCopyWithImpl(this._self, this._then);

  final DomainTrackerResourceMetadata _self;
  final $Res Function(DomainTrackerResourceMetadata) _then;

/// Create a copy of DomainTrackerResourceMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? skipHealthCheck = freezed,Object? remoteConfigOverrides = freezed,Object? healthCheckConfig = freezed,}) {
  return _then(_self.copyWith(
skipHealthCheck: freezed == skipHealthCheck ? _self.skipHealthCheck : skipHealthCheck // ignore: cast_nullable_to_non_nullable
as bool?,remoteConfigOverrides: freezed == remoteConfigOverrides ? _self.remoteConfigOverrides : remoteConfigOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,healthCheckConfig: freezed == healthCheckConfig ? _self.healthCheckConfig : healthCheckConfig // ignore: cast_nullable_to_non_nullable
as DomainTrackerResourceHealthCheckConfig?,
  ));
}
/// Create a copy of DomainTrackerResourceMetadata
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainTrackerResourceHealthCheckConfigCopyWith<$Res>? get healthCheckConfig {
    if (_self.healthCheckConfig == null) {
    return null;
  }

  return $DomainTrackerResourceHealthCheckConfigCopyWith<$Res>(_self.healthCheckConfig!, (value) {
    return _then(_self.copyWith(healthCheckConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [DomainTrackerResourceMetadata].
extension DomainTrackerResourceMetadataPatterns on DomainTrackerResourceMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainTrackerResourceMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainTrackerResourceMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainTrackerResourceMetadata value)  $default,){
final _that = this;
switch (_that) {
case _DomainTrackerResourceMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainTrackerResourceMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _DomainTrackerResourceMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? skipHealthCheck,  Map<String, String>? remoteConfigOverrides,  DomainTrackerResourceHealthCheckConfig? healthCheckConfig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainTrackerResourceMetadata() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? skipHealthCheck,  Map<String, String>? remoteConfigOverrides,  DomainTrackerResourceHealthCheckConfig? healthCheckConfig)  $default,) {final _that = this;
switch (_that) {
case _DomainTrackerResourceMetadata():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? skipHealthCheck,  Map<String, String>? remoteConfigOverrides,  DomainTrackerResourceHealthCheckConfig? healthCheckConfig)?  $default,) {final _that = this;
switch (_that) {
case _DomainTrackerResourceMetadata() when $default != null:
return $default(_that.skipHealthCheck,_that.remoteConfigOverrides,_that.healthCheckConfig);case _:
  return null;

}
}

}

/// @nodoc


class _DomainTrackerResourceMetadata implements DomainTrackerResourceMetadata {
  const _DomainTrackerResourceMetadata({this.skipHealthCheck, final  Map<String, String>? remoteConfigOverrides, this.healthCheckConfig}): _remoteConfigOverrides = remoteConfigOverrides;
  

@override final  bool? skipHealthCheck;
 final  Map<String, String>? _remoteConfigOverrides;
@override Map<String, String>? get remoteConfigOverrides {
  final value = _remoteConfigOverrides;
  if (value == null) return null;
  if (_remoteConfigOverrides is EqualUnmodifiableMapView) return _remoteConfigOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DomainTrackerResourceHealthCheckConfig? healthCheckConfig;

/// Create a copy of DomainTrackerResourceMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainTrackerResourceMetadataCopyWith<_DomainTrackerResourceMetadata> get copyWith => __$DomainTrackerResourceMetadataCopyWithImpl<_DomainTrackerResourceMetadata>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainTrackerResourceMetadata&&(identical(other.skipHealthCheck, skipHealthCheck) || other.skipHealthCheck == skipHealthCheck)&&const DeepCollectionEquality().equals(other._remoteConfigOverrides, _remoteConfigOverrides)&&(identical(other.healthCheckConfig, healthCheckConfig) || other.healthCheckConfig == healthCheckConfig));
}


@override
int get hashCode => Object.hash(runtimeType,skipHealthCheck,const DeepCollectionEquality().hash(_remoteConfigOverrides),healthCheckConfig);

@override
String toString() {
  return 'DomainTrackerResourceMetadata(skipHealthCheck: $skipHealthCheck, remoteConfigOverrides: $remoteConfigOverrides, healthCheckConfig: $healthCheckConfig)';
}


}

/// @nodoc
abstract mixin class _$DomainTrackerResourceMetadataCopyWith<$Res> implements $DomainTrackerResourceMetadataCopyWith<$Res> {
  factory _$DomainTrackerResourceMetadataCopyWith(_DomainTrackerResourceMetadata value, $Res Function(_DomainTrackerResourceMetadata) _then) = __$DomainTrackerResourceMetadataCopyWithImpl;
@override @useResult
$Res call({
 bool? skipHealthCheck, Map<String, String>? remoteConfigOverrides, DomainTrackerResourceHealthCheckConfig? healthCheckConfig
});


@override $DomainTrackerResourceHealthCheckConfigCopyWith<$Res>? get healthCheckConfig;

}
/// @nodoc
class __$DomainTrackerResourceMetadataCopyWithImpl<$Res>
    implements _$DomainTrackerResourceMetadataCopyWith<$Res> {
  __$DomainTrackerResourceMetadataCopyWithImpl(this._self, this._then);

  final _DomainTrackerResourceMetadata _self;
  final $Res Function(_DomainTrackerResourceMetadata) _then;

/// Create a copy of DomainTrackerResourceMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? skipHealthCheck = freezed,Object? remoteConfigOverrides = freezed,Object? healthCheckConfig = freezed,}) {
  return _then(_DomainTrackerResourceMetadata(
skipHealthCheck: freezed == skipHealthCheck ? _self.skipHealthCheck : skipHealthCheck // ignore: cast_nullable_to_non_nullable
as bool?,remoteConfigOverrides: freezed == remoteConfigOverrides ? _self._remoteConfigOverrides : remoteConfigOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,healthCheckConfig: freezed == healthCheckConfig ? _self.healthCheckConfig : healthCheckConfig // ignore: cast_nullable_to_non_nullable
as DomainTrackerResourceHealthCheckConfig?,
  ));
}

/// Create a copy of DomainTrackerResourceMetadata
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainTrackerResourceHealthCheckConfigCopyWith<$Res>? get healthCheckConfig {
    if (_self.healthCheckConfig == null) {
    return null;
  }

  return $DomainTrackerResourceHealthCheckConfigCopyWith<$Res>(_self.healthCheckConfig!, (value) {
    return _then(_self.copyWith(healthCheckConfig: value));
  });
}
}

/// @nodoc
mixin _$DomainTrackerResourceHealthCheckConfig {

 int? get rangeInBytes; Duration? get measureDuration;
/// Create a copy of DomainTrackerResourceHealthCheckConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTrackerResourceHealthCheckConfigCopyWith<DomainTrackerResourceHealthCheckConfig> get copyWith => _$DomainTrackerResourceHealthCheckConfigCopyWithImpl<DomainTrackerResourceHealthCheckConfig>(this as DomainTrackerResourceHealthCheckConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTrackerResourceHealthCheckConfig&&(identical(other.rangeInBytes, rangeInBytes) || other.rangeInBytes == rangeInBytes)&&(identical(other.measureDuration, measureDuration) || other.measureDuration == measureDuration));
}


@override
int get hashCode => Object.hash(runtimeType,rangeInBytes,measureDuration);

@override
String toString() {
  return 'DomainTrackerResourceHealthCheckConfig(rangeInBytes: $rangeInBytes, measureDuration: $measureDuration)';
}


}

/// @nodoc
abstract mixin class $DomainTrackerResourceHealthCheckConfigCopyWith<$Res>  {
  factory $DomainTrackerResourceHealthCheckConfigCopyWith(DomainTrackerResourceHealthCheckConfig value, $Res Function(DomainTrackerResourceHealthCheckConfig) _then) = _$DomainTrackerResourceHealthCheckConfigCopyWithImpl;
@useResult
$Res call({
 int? rangeInBytes, Duration? measureDuration
});




}
/// @nodoc
class _$DomainTrackerResourceHealthCheckConfigCopyWithImpl<$Res>
    implements $DomainTrackerResourceHealthCheckConfigCopyWith<$Res> {
  _$DomainTrackerResourceHealthCheckConfigCopyWithImpl(this._self, this._then);

  final DomainTrackerResourceHealthCheckConfig _self;
  final $Res Function(DomainTrackerResourceHealthCheckConfig) _then;

/// Create a copy of DomainTrackerResourceHealthCheckConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rangeInBytes = freezed,Object? measureDuration = freezed,}) {
  return _then(_self.copyWith(
rangeInBytes: freezed == rangeInBytes ? _self.rangeInBytes : rangeInBytes // ignore: cast_nullable_to_non_nullable
as int?,measureDuration: freezed == measureDuration ? _self.measureDuration : measureDuration // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainTrackerResourceHealthCheckConfig].
extension DomainTrackerResourceHealthCheckConfigPatterns on DomainTrackerResourceHealthCheckConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainTrackerResourceHealthCheckConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainTrackerResourceHealthCheckConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainTrackerResourceHealthCheckConfig value)  $default,){
final _that = this;
switch (_that) {
case _DomainTrackerResourceHealthCheckConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainTrackerResourceHealthCheckConfig value)?  $default,){
final _that = this;
switch (_that) {
case _DomainTrackerResourceHealthCheckConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? rangeInBytes,  Duration? measureDuration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainTrackerResourceHealthCheckConfig() when $default != null:
return $default(_that.rangeInBytes,_that.measureDuration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? rangeInBytes,  Duration? measureDuration)  $default,) {final _that = this;
switch (_that) {
case _DomainTrackerResourceHealthCheckConfig():
return $default(_that.rangeInBytes,_that.measureDuration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? rangeInBytes,  Duration? measureDuration)?  $default,) {final _that = this;
switch (_that) {
case _DomainTrackerResourceHealthCheckConfig() when $default != null:
return $default(_that.rangeInBytes,_that.measureDuration);case _:
  return null;

}
}

}

/// @nodoc


class _DomainTrackerResourceHealthCheckConfig implements DomainTrackerResourceHealthCheckConfig {
  const _DomainTrackerResourceHealthCheckConfig({this.rangeInBytes, this.measureDuration});
  

@override final  int? rangeInBytes;
@override final  Duration? measureDuration;

/// Create a copy of DomainTrackerResourceHealthCheckConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainTrackerResourceHealthCheckConfigCopyWith<_DomainTrackerResourceHealthCheckConfig> get copyWith => __$DomainTrackerResourceHealthCheckConfigCopyWithImpl<_DomainTrackerResourceHealthCheckConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainTrackerResourceHealthCheckConfig&&(identical(other.rangeInBytes, rangeInBytes) || other.rangeInBytes == rangeInBytes)&&(identical(other.measureDuration, measureDuration) || other.measureDuration == measureDuration));
}


@override
int get hashCode => Object.hash(runtimeType,rangeInBytes,measureDuration);

@override
String toString() {
  return 'DomainTrackerResourceHealthCheckConfig(rangeInBytes: $rangeInBytes, measureDuration: $measureDuration)';
}


}

/// @nodoc
abstract mixin class _$DomainTrackerResourceHealthCheckConfigCopyWith<$Res> implements $DomainTrackerResourceHealthCheckConfigCopyWith<$Res> {
  factory _$DomainTrackerResourceHealthCheckConfigCopyWith(_DomainTrackerResourceHealthCheckConfig value, $Res Function(_DomainTrackerResourceHealthCheckConfig) _then) = __$DomainTrackerResourceHealthCheckConfigCopyWithImpl;
@override @useResult
$Res call({
 int? rangeInBytes, Duration? measureDuration
});




}
/// @nodoc
class __$DomainTrackerResourceHealthCheckConfigCopyWithImpl<$Res>
    implements _$DomainTrackerResourceHealthCheckConfigCopyWith<$Res> {
  __$DomainTrackerResourceHealthCheckConfigCopyWithImpl(this._self, this._then);

  final _DomainTrackerResourceHealthCheckConfig _self;
  final $Res Function(_DomainTrackerResourceHealthCheckConfig) _then;

/// Create a copy of DomainTrackerResourceHealthCheckConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rangeInBytes = freezed,Object? measureDuration = freezed,}) {
  return _then(_DomainTrackerResourceHealthCheckConfig(
rangeInBytes: freezed == rangeInBytes ? _self.rangeInBytes : rangeInBytes // ignore: cast_nullable_to_non_nullable
as int?,measureDuration: freezed == measureDuration ? _self.measureDuration : measureDuration // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

// dart format on
