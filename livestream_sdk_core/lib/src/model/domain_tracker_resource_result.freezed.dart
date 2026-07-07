// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'domain_tracker_resource_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DomainTrackerResourceResult {

 String get resourceType;
/// Create a copy of DomainTrackerResourceResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTrackerResourceResultCopyWith<DomainTrackerResourceResult> get copyWith => _$DomainTrackerResourceResultCopyWithImpl<DomainTrackerResourceResult>(this as DomainTrackerResourceResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTrackerResourceResult&&(identical(other.resourceType, resourceType) || other.resourceType == resourceType));
}


@override
int get hashCode => Object.hash(runtimeType,resourceType);

@override
String toString() {
  return 'DomainTrackerResourceResult(resourceType: $resourceType)';
}


}

/// @nodoc
abstract mixin class $DomainTrackerResourceResultCopyWith<$Res>  {
  factory $DomainTrackerResourceResultCopyWith(DomainTrackerResourceResult value, $Res Function(DomainTrackerResourceResult) _then) = _$DomainTrackerResourceResultCopyWithImpl;
@useResult
$Res call({
 String resourceType
});




}
/// @nodoc
class _$DomainTrackerResourceResultCopyWithImpl<$Res>
    implements $DomainTrackerResourceResultCopyWith<$Res> {
  _$DomainTrackerResourceResultCopyWithImpl(this._self, this._then);

  final DomainTrackerResourceResult _self;
  final $Res Function(DomainTrackerResourceResult) _then;

/// Create a copy of DomainTrackerResourceResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? resourceType = null,}) {
  return _then(_self.copyWith(
resourceType: null == resourceType ? _self.resourceType : resourceType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainTrackerResourceResult].
extension DomainTrackerResourceResultPatterns on DomainTrackerResourceResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DomainTrackerResourceHealthyResult value)?  healthy,TResult Function( DomainTrackerResourceUnhealthyResult value)?  unhealthy,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DomainTrackerResourceHealthyResult() when healthy != null:
return healthy(_that);case DomainTrackerResourceUnhealthyResult() when unhealthy != null:
return unhealthy(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DomainTrackerResourceHealthyResult value)  healthy,required TResult Function( DomainTrackerResourceUnhealthyResult value)  unhealthy,}){
final _that = this;
switch (_that) {
case DomainTrackerResourceHealthyResult():
return healthy(_that);case DomainTrackerResourceUnhealthyResult():
return unhealthy(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DomainTrackerResourceHealthyResult value)?  healthy,TResult? Function( DomainTrackerResourceUnhealthyResult value)?  unhealthy,}){
final _that = this;
switch (_that) {
case DomainTrackerResourceHealthyResult() when healthy != null:
return healthy(_that);case DomainTrackerResourceUnhealthyResult() when unhealthy != null:
return unhealthy(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String resourceType,  DomainTrackerResource resource,  DomainTrackerResourceMeasurement? measurement)?  healthy,TResult Function( String resourceType)?  unhealthy,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DomainTrackerResourceHealthyResult() when healthy != null:
return healthy(_that.resourceType,_that.resource,_that.measurement);case DomainTrackerResourceUnhealthyResult() when unhealthy != null:
return unhealthy(_that.resourceType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String resourceType,  DomainTrackerResource resource,  DomainTrackerResourceMeasurement? measurement)  healthy,required TResult Function( String resourceType)  unhealthy,}) {final _that = this;
switch (_that) {
case DomainTrackerResourceHealthyResult():
return healthy(_that.resourceType,_that.resource,_that.measurement);case DomainTrackerResourceUnhealthyResult():
return unhealthy(_that.resourceType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String resourceType,  DomainTrackerResource resource,  DomainTrackerResourceMeasurement? measurement)?  healthy,TResult? Function( String resourceType)?  unhealthy,}) {final _that = this;
switch (_that) {
case DomainTrackerResourceHealthyResult() when healthy != null:
return healthy(_that.resourceType,_that.resource,_that.measurement);case DomainTrackerResourceUnhealthyResult() when unhealthy != null:
return unhealthy(_that.resourceType);case _:
  return null;

}
}

}

/// @nodoc


class DomainTrackerResourceHealthyResult implements DomainTrackerResourceResult {
  const DomainTrackerResourceHealthyResult({required this.resourceType, required this.resource, required this.measurement});
  

@override final  String resourceType;
 final  DomainTrackerResource resource;
 final  DomainTrackerResourceMeasurement? measurement;

/// Create a copy of DomainTrackerResourceResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTrackerResourceHealthyResultCopyWith<DomainTrackerResourceHealthyResult> get copyWith => _$DomainTrackerResourceHealthyResultCopyWithImpl<DomainTrackerResourceHealthyResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTrackerResourceHealthyResult&&(identical(other.resourceType, resourceType) || other.resourceType == resourceType)&&(identical(other.resource, resource) || other.resource == resource)&&(identical(other.measurement, measurement) || other.measurement == measurement));
}


@override
int get hashCode => Object.hash(runtimeType,resourceType,resource,measurement);

@override
String toString() {
  return 'DomainTrackerResourceResult.healthy(resourceType: $resourceType, resource: $resource, measurement: $measurement)';
}


}

/// @nodoc
abstract mixin class $DomainTrackerResourceHealthyResultCopyWith<$Res> implements $DomainTrackerResourceResultCopyWith<$Res> {
  factory $DomainTrackerResourceHealthyResultCopyWith(DomainTrackerResourceHealthyResult value, $Res Function(DomainTrackerResourceHealthyResult) _then) = _$DomainTrackerResourceHealthyResultCopyWithImpl;
@override @useResult
$Res call({
 String resourceType, DomainTrackerResource resource, DomainTrackerResourceMeasurement? measurement
});


$DomainTrackerResourceCopyWith<$Res> get resource;$DomainTrackerResourceMeasurementCopyWith<$Res>? get measurement;

}
/// @nodoc
class _$DomainTrackerResourceHealthyResultCopyWithImpl<$Res>
    implements $DomainTrackerResourceHealthyResultCopyWith<$Res> {
  _$DomainTrackerResourceHealthyResultCopyWithImpl(this._self, this._then);

  final DomainTrackerResourceHealthyResult _self;
  final $Res Function(DomainTrackerResourceHealthyResult) _then;

/// Create a copy of DomainTrackerResourceResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? resourceType = null,Object? resource = null,Object? measurement = freezed,}) {
  return _then(DomainTrackerResourceHealthyResult(
resourceType: null == resourceType ? _self.resourceType : resourceType // ignore: cast_nullable_to_non_nullable
as String,resource: null == resource ? _self.resource : resource // ignore: cast_nullable_to_non_nullable
as DomainTrackerResource,measurement: freezed == measurement ? _self.measurement : measurement // ignore: cast_nullable_to_non_nullable
as DomainTrackerResourceMeasurement?,
  ));
}

/// Create a copy of DomainTrackerResourceResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainTrackerResourceCopyWith<$Res> get resource {
  
  return $DomainTrackerResourceCopyWith<$Res>(_self.resource, (value) {
    return _then(_self.copyWith(resource: value));
  });
}/// Create a copy of DomainTrackerResourceResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainTrackerResourceMeasurementCopyWith<$Res>? get measurement {
    if (_self.measurement == null) {
    return null;
  }

  return $DomainTrackerResourceMeasurementCopyWith<$Res>(_self.measurement!, (value) {
    return _then(_self.copyWith(measurement: value));
  });
}
}

/// @nodoc


class DomainTrackerResourceUnhealthyResult implements DomainTrackerResourceResult {
  const DomainTrackerResourceUnhealthyResult({required this.resourceType});
  

@override final  String resourceType;

/// Create a copy of DomainTrackerResourceResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTrackerResourceUnhealthyResultCopyWith<DomainTrackerResourceUnhealthyResult> get copyWith => _$DomainTrackerResourceUnhealthyResultCopyWithImpl<DomainTrackerResourceUnhealthyResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTrackerResourceUnhealthyResult&&(identical(other.resourceType, resourceType) || other.resourceType == resourceType));
}


@override
int get hashCode => Object.hash(runtimeType,resourceType);

@override
String toString() {
  return 'DomainTrackerResourceResult.unhealthy(resourceType: $resourceType)';
}


}

/// @nodoc
abstract mixin class $DomainTrackerResourceUnhealthyResultCopyWith<$Res> implements $DomainTrackerResourceResultCopyWith<$Res> {
  factory $DomainTrackerResourceUnhealthyResultCopyWith(DomainTrackerResourceUnhealthyResult value, $Res Function(DomainTrackerResourceUnhealthyResult) _then) = _$DomainTrackerResourceUnhealthyResultCopyWithImpl;
@override @useResult
$Res call({
 String resourceType
});




}
/// @nodoc
class _$DomainTrackerResourceUnhealthyResultCopyWithImpl<$Res>
    implements $DomainTrackerResourceUnhealthyResultCopyWith<$Res> {
  _$DomainTrackerResourceUnhealthyResultCopyWithImpl(this._self, this._then);

  final DomainTrackerResourceUnhealthyResult _self;
  final $Res Function(DomainTrackerResourceUnhealthyResult) _then;

/// Create a copy of DomainTrackerResourceResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? resourceType = null,}) {
  return _then(DomainTrackerResourceUnhealthyResult(
resourceType: null == resourceType ? _self.resourceType : resourceType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
