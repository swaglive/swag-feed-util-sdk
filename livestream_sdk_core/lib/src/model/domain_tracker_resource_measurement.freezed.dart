// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'domain_tracker_resource_measurement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DomainTrackerResourceMeasurement {

 Uri get uri; bool get isHealthy; Duration? get rtt; String? get eoLogUuid; String? get eoCacheStatus; String? get debugMessage; int? get receivedBytes; bool get fullyDownloaded;
/// Create a copy of DomainTrackerResourceMeasurement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTrackerResourceMeasurementCopyWith<DomainTrackerResourceMeasurement> get copyWith => _$DomainTrackerResourceMeasurementCopyWithImpl<DomainTrackerResourceMeasurement>(this as DomainTrackerResourceMeasurement, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTrackerResourceMeasurement&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.isHealthy, isHealthy) || other.isHealthy == isHealthy)&&(identical(other.rtt, rtt) || other.rtt == rtt)&&(identical(other.eoLogUuid, eoLogUuid) || other.eoLogUuid == eoLogUuid)&&(identical(other.eoCacheStatus, eoCacheStatus) || other.eoCacheStatus == eoCacheStatus)&&(identical(other.debugMessage, debugMessage) || other.debugMessage == debugMessage)&&(identical(other.receivedBytes, receivedBytes) || other.receivedBytes == receivedBytes)&&(identical(other.fullyDownloaded, fullyDownloaded) || other.fullyDownloaded == fullyDownloaded));
}


@override
int get hashCode => Object.hash(runtimeType,uri,isHealthy,rtt,eoLogUuid,eoCacheStatus,debugMessage,receivedBytes,fullyDownloaded);

@override
String toString() {
  return 'DomainTrackerResourceMeasurement(uri: $uri, isHealthy: $isHealthy, rtt: $rtt, eoLogUuid: $eoLogUuid, eoCacheStatus: $eoCacheStatus, debugMessage: $debugMessage, receivedBytes: $receivedBytes, fullyDownloaded: $fullyDownloaded)';
}


}

/// @nodoc
abstract mixin class $DomainTrackerResourceMeasurementCopyWith<$Res>  {
  factory $DomainTrackerResourceMeasurementCopyWith(DomainTrackerResourceMeasurement value, $Res Function(DomainTrackerResourceMeasurement) _then) = _$DomainTrackerResourceMeasurementCopyWithImpl;
@useResult
$Res call({
 Uri uri, bool isHealthy, Duration? rtt, String? eoLogUuid, String? eoCacheStatus, String? debugMessage, int? receivedBytes, bool fullyDownloaded
});




}
/// @nodoc
class _$DomainTrackerResourceMeasurementCopyWithImpl<$Res>
    implements $DomainTrackerResourceMeasurementCopyWith<$Res> {
  _$DomainTrackerResourceMeasurementCopyWithImpl(this._self, this._then);

  final DomainTrackerResourceMeasurement _self;
  final $Res Function(DomainTrackerResourceMeasurement) _then;

/// Create a copy of DomainTrackerResourceMeasurement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? isHealthy = null,Object? rtt = freezed,Object? eoLogUuid = freezed,Object? eoCacheStatus = freezed,Object? debugMessage = freezed,Object? receivedBytes = freezed,Object? fullyDownloaded = null,}) {
  return _then(_self.copyWith(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as Uri,isHealthy: null == isHealthy ? _self.isHealthy : isHealthy // ignore: cast_nullable_to_non_nullable
as bool,rtt: freezed == rtt ? _self.rtt : rtt // ignore: cast_nullable_to_non_nullable
as Duration?,eoLogUuid: freezed == eoLogUuid ? _self.eoLogUuid : eoLogUuid // ignore: cast_nullable_to_non_nullable
as String?,eoCacheStatus: freezed == eoCacheStatus ? _self.eoCacheStatus : eoCacheStatus // ignore: cast_nullable_to_non_nullable
as String?,debugMessage: freezed == debugMessage ? _self.debugMessage : debugMessage // ignore: cast_nullable_to_non_nullable
as String?,receivedBytes: freezed == receivedBytes ? _self.receivedBytes : receivedBytes // ignore: cast_nullable_to_non_nullable
as int?,fullyDownloaded: null == fullyDownloaded ? _self.fullyDownloaded : fullyDownloaded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainTrackerResourceMeasurement].
extension DomainTrackerResourceMeasurementPatterns on DomainTrackerResourceMeasurement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainTrackerResourceMeasurement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainTrackerResourceMeasurement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainTrackerResourceMeasurement value)  $default,){
final _that = this;
switch (_that) {
case _DomainTrackerResourceMeasurement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainTrackerResourceMeasurement value)?  $default,){
final _that = this;
switch (_that) {
case _DomainTrackerResourceMeasurement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uri uri,  bool isHealthy,  Duration? rtt,  String? eoLogUuid,  String? eoCacheStatus,  String? debugMessage,  int? receivedBytes,  bool fullyDownloaded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainTrackerResourceMeasurement() when $default != null:
return $default(_that.uri,_that.isHealthy,_that.rtt,_that.eoLogUuid,_that.eoCacheStatus,_that.debugMessage,_that.receivedBytes,_that.fullyDownloaded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uri uri,  bool isHealthy,  Duration? rtt,  String? eoLogUuid,  String? eoCacheStatus,  String? debugMessage,  int? receivedBytes,  bool fullyDownloaded)  $default,) {final _that = this;
switch (_that) {
case _DomainTrackerResourceMeasurement():
return $default(_that.uri,_that.isHealthy,_that.rtt,_that.eoLogUuid,_that.eoCacheStatus,_that.debugMessage,_that.receivedBytes,_that.fullyDownloaded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uri uri,  bool isHealthy,  Duration? rtt,  String? eoLogUuid,  String? eoCacheStatus,  String? debugMessage,  int? receivedBytes,  bool fullyDownloaded)?  $default,) {final _that = this;
switch (_that) {
case _DomainTrackerResourceMeasurement() when $default != null:
return $default(_that.uri,_that.isHealthy,_that.rtt,_that.eoLogUuid,_that.eoCacheStatus,_that.debugMessage,_that.receivedBytes,_that.fullyDownloaded);case _:
  return null;

}
}

}

/// @nodoc


class _DomainTrackerResourceMeasurement implements DomainTrackerResourceMeasurement {
  const _DomainTrackerResourceMeasurement({required this.uri, required this.isHealthy, this.rtt, this.eoLogUuid, this.eoCacheStatus, this.debugMessage, this.receivedBytes, this.fullyDownloaded = false});
  

@override final  Uri uri;
@override final  bool isHealthy;
@override final  Duration? rtt;
@override final  String? eoLogUuid;
@override final  String? eoCacheStatus;
@override final  String? debugMessage;
@override final  int? receivedBytes;
@override@JsonKey() final  bool fullyDownloaded;

/// Create a copy of DomainTrackerResourceMeasurement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainTrackerResourceMeasurementCopyWith<_DomainTrackerResourceMeasurement> get copyWith => __$DomainTrackerResourceMeasurementCopyWithImpl<_DomainTrackerResourceMeasurement>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainTrackerResourceMeasurement&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.isHealthy, isHealthy) || other.isHealthy == isHealthy)&&(identical(other.rtt, rtt) || other.rtt == rtt)&&(identical(other.eoLogUuid, eoLogUuid) || other.eoLogUuid == eoLogUuid)&&(identical(other.eoCacheStatus, eoCacheStatus) || other.eoCacheStatus == eoCacheStatus)&&(identical(other.debugMessage, debugMessage) || other.debugMessage == debugMessage)&&(identical(other.receivedBytes, receivedBytes) || other.receivedBytes == receivedBytes)&&(identical(other.fullyDownloaded, fullyDownloaded) || other.fullyDownloaded == fullyDownloaded));
}


@override
int get hashCode => Object.hash(runtimeType,uri,isHealthy,rtt,eoLogUuid,eoCacheStatus,debugMessage,receivedBytes,fullyDownloaded);

@override
String toString() {
  return 'DomainTrackerResourceMeasurement(uri: $uri, isHealthy: $isHealthy, rtt: $rtt, eoLogUuid: $eoLogUuid, eoCacheStatus: $eoCacheStatus, debugMessage: $debugMessage, receivedBytes: $receivedBytes, fullyDownloaded: $fullyDownloaded)';
}


}

/// @nodoc
abstract mixin class _$DomainTrackerResourceMeasurementCopyWith<$Res> implements $DomainTrackerResourceMeasurementCopyWith<$Res> {
  factory _$DomainTrackerResourceMeasurementCopyWith(_DomainTrackerResourceMeasurement value, $Res Function(_DomainTrackerResourceMeasurement) _then) = __$DomainTrackerResourceMeasurementCopyWithImpl;
@override @useResult
$Res call({
 Uri uri, bool isHealthy, Duration? rtt, String? eoLogUuid, String? eoCacheStatus, String? debugMessage, int? receivedBytes, bool fullyDownloaded
});




}
/// @nodoc
class __$DomainTrackerResourceMeasurementCopyWithImpl<$Res>
    implements _$DomainTrackerResourceMeasurementCopyWith<$Res> {
  __$DomainTrackerResourceMeasurementCopyWithImpl(this._self, this._then);

  final _DomainTrackerResourceMeasurement _self;
  final $Res Function(_DomainTrackerResourceMeasurement) _then;

/// Create a copy of DomainTrackerResourceMeasurement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? isHealthy = null,Object? rtt = freezed,Object? eoLogUuid = freezed,Object? eoCacheStatus = freezed,Object? debugMessage = freezed,Object? receivedBytes = freezed,Object? fullyDownloaded = null,}) {
  return _then(_DomainTrackerResourceMeasurement(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as Uri,isHealthy: null == isHealthy ? _self.isHealthy : isHealthy // ignore: cast_nullable_to_non_nullable
as bool,rtt: freezed == rtt ? _self.rtt : rtt // ignore: cast_nullable_to_non_nullable
as Duration?,eoLogUuid: freezed == eoLogUuid ? _self.eoLogUuid : eoLogUuid // ignore: cast_nullable_to_non_nullable
as String?,eoCacheStatus: freezed == eoCacheStatus ? _self.eoCacheStatus : eoCacheStatus // ignore: cast_nullable_to_non_nullable
as String?,debugMessage: freezed == debugMessage ? _self.debugMessage : debugMessage // ignore: cast_nullable_to_non_nullable
as String?,receivedBytes: freezed == receivedBytes ? _self.receivedBytes : receivedBytes // ignore: cast_nullable_to_non_nullable
as int?,fullyDownloaded: null == fullyDownloaded ? _self.fullyDownloaded : fullyDownloaded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
