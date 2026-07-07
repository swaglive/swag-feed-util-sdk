// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selected_domain_tracker_resources.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SelectedDomainTrackerResources {

 Map<String, Uri> get uris; Map<String, String> get overrideRemoteConfigs; bool get isFrontendChanged;
/// Create a copy of SelectedDomainTrackerResources
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectedDomainTrackerResourcesCopyWith<SelectedDomainTrackerResources> get copyWith => _$SelectedDomainTrackerResourcesCopyWithImpl<SelectedDomainTrackerResources>(this as SelectedDomainTrackerResources, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectedDomainTrackerResources&&const DeepCollectionEquality().equals(other.uris, uris)&&const DeepCollectionEquality().equals(other.overrideRemoteConfigs, overrideRemoteConfigs)&&(identical(other.isFrontendChanged, isFrontendChanged) || other.isFrontendChanged == isFrontendChanged));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(uris),const DeepCollectionEquality().hash(overrideRemoteConfigs),isFrontendChanged);

@override
String toString() {
  return 'SelectedDomainTrackerResources(uris: $uris, overrideRemoteConfigs: $overrideRemoteConfigs, isFrontendChanged: $isFrontendChanged)';
}


}

/// @nodoc
abstract mixin class $SelectedDomainTrackerResourcesCopyWith<$Res>  {
  factory $SelectedDomainTrackerResourcesCopyWith(SelectedDomainTrackerResources value, $Res Function(SelectedDomainTrackerResources) _then) = _$SelectedDomainTrackerResourcesCopyWithImpl;
@useResult
$Res call({
 Map<String, Uri> uris, Map<String, String> overrideRemoteConfigs, bool isFrontendChanged
});




}
/// @nodoc
class _$SelectedDomainTrackerResourcesCopyWithImpl<$Res>
    implements $SelectedDomainTrackerResourcesCopyWith<$Res> {
  _$SelectedDomainTrackerResourcesCopyWithImpl(this._self, this._then);

  final SelectedDomainTrackerResources _self;
  final $Res Function(SelectedDomainTrackerResources) _then;

/// Create a copy of SelectedDomainTrackerResources
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uris = null,Object? overrideRemoteConfigs = null,Object? isFrontendChanged = null,}) {
  return _then(_self.copyWith(
uris: null == uris ? _self.uris : uris // ignore: cast_nullable_to_non_nullable
as Map<String, Uri>,overrideRemoteConfigs: null == overrideRemoteConfigs ? _self.overrideRemoteConfigs : overrideRemoteConfigs // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isFrontendChanged: null == isFrontendChanged ? _self.isFrontendChanged : isFrontendChanged // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SelectedDomainTrackerResources].
extension SelectedDomainTrackerResourcesPatterns on SelectedDomainTrackerResources {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectedDomainTrackerResources value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectedDomainTrackerResources() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectedDomainTrackerResources value)  $default,){
final _that = this;
switch (_that) {
case _SelectedDomainTrackerResources():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectedDomainTrackerResources value)?  $default,){
final _that = this;
switch (_that) {
case _SelectedDomainTrackerResources() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, Uri> uris,  Map<String, String> overrideRemoteConfigs,  bool isFrontendChanged)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectedDomainTrackerResources() when $default != null:
return $default(_that.uris,_that.overrideRemoteConfigs,_that.isFrontendChanged);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, Uri> uris,  Map<String, String> overrideRemoteConfigs,  bool isFrontendChanged)  $default,) {final _that = this;
switch (_that) {
case _SelectedDomainTrackerResources():
return $default(_that.uris,_that.overrideRemoteConfigs,_that.isFrontendChanged);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, Uri> uris,  Map<String, String> overrideRemoteConfigs,  bool isFrontendChanged)?  $default,) {final _that = this;
switch (_that) {
case _SelectedDomainTrackerResources() when $default != null:
return $default(_that.uris,_that.overrideRemoteConfigs,_that.isFrontendChanged);case _:
  return null;

}
}

}

/// @nodoc


class _SelectedDomainTrackerResources implements SelectedDomainTrackerResources {
  const _SelectedDomainTrackerResources({required final  Map<String, Uri> uris, required final  Map<String, String> overrideRemoteConfigs, required this.isFrontendChanged}): _uris = uris,_overrideRemoteConfigs = overrideRemoteConfigs;
  

 final  Map<String, Uri> _uris;
@override Map<String, Uri> get uris {
  if (_uris is EqualUnmodifiableMapView) return _uris;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_uris);
}

 final  Map<String, String> _overrideRemoteConfigs;
@override Map<String, String> get overrideRemoteConfigs {
  if (_overrideRemoteConfigs is EqualUnmodifiableMapView) return _overrideRemoteConfigs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_overrideRemoteConfigs);
}

@override final  bool isFrontendChanged;

/// Create a copy of SelectedDomainTrackerResources
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectedDomainTrackerResourcesCopyWith<_SelectedDomainTrackerResources> get copyWith => __$SelectedDomainTrackerResourcesCopyWithImpl<_SelectedDomainTrackerResources>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectedDomainTrackerResources&&const DeepCollectionEquality().equals(other._uris, _uris)&&const DeepCollectionEquality().equals(other._overrideRemoteConfigs, _overrideRemoteConfigs)&&(identical(other.isFrontendChanged, isFrontendChanged) || other.isFrontendChanged == isFrontendChanged));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_uris),const DeepCollectionEquality().hash(_overrideRemoteConfigs),isFrontendChanged);

@override
String toString() {
  return 'SelectedDomainTrackerResources(uris: $uris, overrideRemoteConfigs: $overrideRemoteConfigs, isFrontendChanged: $isFrontendChanged)';
}


}

/// @nodoc
abstract mixin class _$SelectedDomainTrackerResourcesCopyWith<$Res> implements $SelectedDomainTrackerResourcesCopyWith<$Res> {
  factory _$SelectedDomainTrackerResourcesCopyWith(_SelectedDomainTrackerResources value, $Res Function(_SelectedDomainTrackerResources) _then) = __$SelectedDomainTrackerResourcesCopyWithImpl;
@override @useResult
$Res call({
 Map<String, Uri> uris, Map<String, String> overrideRemoteConfigs, bool isFrontendChanged
});




}
/// @nodoc
class __$SelectedDomainTrackerResourcesCopyWithImpl<$Res>
    implements _$SelectedDomainTrackerResourcesCopyWith<$Res> {
  __$SelectedDomainTrackerResourcesCopyWithImpl(this._self, this._then);

  final _SelectedDomainTrackerResources _self;
  final $Res Function(_SelectedDomainTrackerResources) _then;

/// Create a copy of SelectedDomainTrackerResources
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uris = null,Object? overrideRemoteConfigs = null,Object? isFrontendChanged = null,}) {
  return _then(_SelectedDomainTrackerResources(
uris: null == uris ? _self._uris : uris // ignore: cast_nullable_to_non_nullable
as Map<String, Uri>,overrideRemoteConfigs: null == overrideRemoteConfigs ? _self._overrideRemoteConfigs : overrideRemoteConfigs // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isFrontendChanged: null == isFrontendChanged ? _self.isFrontendChanged : isFrontendChanged // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
