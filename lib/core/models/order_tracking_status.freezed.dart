// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_tracking_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderTrackingStatus _$OrderTrackingStatusFromJson(Map<String, dynamic> json) {
  return _OrderTrackingStatus.fromJson(json);
}

/// @nodoc
mixin _$OrderTrackingStatus {
  OrderStatusType get status => throw _privateConstructorUsedError;
  DateTime? get time => throw _privateConstructorUsedError;
  String? get estimated => throw _privateConstructorUsedError;

  /// Serializes this OrderTrackingStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderTrackingStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderTrackingStatusCopyWith<OrderTrackingStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderTrackingStatusCopyWith<$Res> {
  factory $OrderTrackingStatusCopyWith(
    OrderTrackingStatus value,
    $Res Function(OrderTrackingStatus) then,
  ) = _$OrderTrackingStatusCopyWithImpl<$Res, OrderTrackingStatus>;
  @useResult
  $Res call({OrderStatusType status, DateTime? time, String? estimated});
}

/// @nodoc
class _$OrderTrackingStatusCopyWithImpl<$Res, $Val extends OrderTrackingStatus>
    implements $OrderTrackingStatusCopyWith<$Res> {
  _$OrderTrackingStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderTrackingStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? time = freezed,
    Object? estimated = freezed,
  }) {
    return _then(
      _value.copyWith(
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as OrderStatusType,
            time:
                freezed == time
                    ? _value.time
                    : time // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            estimated:
                freezed == estimated
                    ? _value.estimated
                    : estimated // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderTrackingStatusImplCopyWith<$Res>
    implements $OrderTrackingStatusCopyWith<$Res> {
  factory _$$OrderTrackingStatusImplCopyWith(
    _$OrderTrackingStatusImpl value,
    $Res Function(_$OrderTrackingStatusImpl) then,
  ) = __$$OrderTrackingStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({OrderStatusType status, DateTime? time, String? estimated});
}

/// @nodoc
class __$$OrderTrackingStatusImplCopyWithImpl<$Res>
    extends _$OrderTrackingStatusCopyWithImpl<$Res, _$OrderTrackingStatusImpl>
    implements _$$OrderTrackingStatusImplCopyWith<$Res> {
  __$$OrderTrackingStatusImplCopyWithImpl(
    _$OrderTrackingStatusImpl _value,
    $Res Function(_$OrderTrackingStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderTrackingStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? time = freezed,
    Object? estimated = freezed,
  }) {
    return _then(
      _$OrderTrackingStatusImpl(
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as OrderStatusType,
        time:
            freezed == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        estimated:
            freezed == estimated
                ? _value.estimated
                : estimated // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderTrackingStatusImpl implements _OrderTrackingStatus {
  const _$OrderTrackingStatusImpl({
    required this.status,
    required this.time,
    this.estimated,
  });

  factory _$OrderTrackingStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderTrackingStatusImplFromJson(json);

  @override
  final OrderStatusType status;
  @override
  final DateTime? time;
  @override
  final String? estimated;

  @override
  String toString() {
    return 'OrderTrackingStatus(status: $status, time: $time, estimated: $estimated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderTrackingStatusImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.estimated, estimated) ||
                other.estimated == estimated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, time, estimated);

  /// Create a copy of OrderTrackingStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderTrackingStatusImplCopyWith<_$OrderTrackingStatusImpl> get copyWith =>
      __$$OrderTrackingStatusImplCopyWithImpl<_$OrderTrackingStatusImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderTrackingStatusImplToJson(this);
  }
}

abstract class _OrderTrackingStatus implements OrderTrackingStatus {
  const factory _OrderTrackingStatus({
    required final OrderStatusType status,
    required final DateTime? time,
    final String? estimated,
  }) = _$OrderTrackingStatusImpl;

  factory _OrderTrackingStatus.fromJson(Map<String, dynamic> json) =
      _$OrderTrackingStatusImpl.fromJson;

  @override
  OrderStatusType get status;
  @override
  DateTime? get time;
  @override
  String? get estimated;

  /// Create a copy of OrderTrackingStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderTrackingStatusImplCopyWith<_$OrderTrackingStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
