// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_tracking_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OrderTrackingState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )
    loaded,
    required TResult Function(String message) error,
    required TResult Function() noOrder,
    required TResult Function(String orderId, String reason) orderCancelled,
    required TResult Function(String orderId, DateTime deliveryTime)
    orderDelivered,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult? Function(String message)? error,
    TResult? Function()? noOrder,
    TResult? Function(String orderId, String reason)? orderCancelled,
    TResult? Function(String orderId, DateTime deliveryTime)? orderDelivered,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult Function(String message)? error,
    TResult Function()? noOrder,
    TResult Function(String orderId, String reason)? orderCancelled,
    TResult Function(String orderId, DateTime deliveryTime)? orderDelivered,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_NoOrder value) noOrder,
    required TResult Function(_OrderCancelled value) orderCancelled,
    required TResult Function(_OrderDelivered value) orderDelivered,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_NoOrder value)? noOrder,
    TResult? Function(_OrderCancelled value)? orderCancelled,
    TResult? Function(_OrderDelivered value)? orderDelivered,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_NoOrder value)? noOrder,
    TResult Function(_OrderCancelled value)? orderCancelled,
    TResult Function(_OrderDelivered value)? orderDelivered,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderTrackingStateCopyWith<$Res> {
  factory $OrderTrackingStateCopyWith(
    OrderTrackingState value,
    $Res Function(OrderTrackingState) then,
  ) = _$OrderTrackingStateCopyWithImpl<$Res, OrderTrackingState>;
}

/// @nodoc
class _$OrderTrackingStateCopyWithImpl<$Res, $Val extends OrderTrackingState>
    implements $OrderTrackingStateCopyWith<$Res> {
  _$OrderTrackingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
    _$InitialImpl value,
    $Res Function(_$InitialImpl) then,
  ) = __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$OrderTrackingStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'OrderTrackingState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )
    loaded,
    required TResult Function(String message) error,
    required TResult Function() noOrder,
    required TResult Function(String orderId, String reason) orderCancelled,
    required TResult Function(String orderId, DateTime deliveryTime)
    orderDelivered,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult? Function(String message)? error,
    TResult? Function()? noOrder,
    TResult? Function(String orderId, String reason)? orderCancelled,
    TResult? Function(String orderId, DateTime deliveryTime)? orderDelivered,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult Function(String message)? error,
    TResult Function()? noOrder,
    TResult Function(String orderId, String reason)? orderCancelled,
    TResult Function(String orderId, DateTime deliveryTime)? orderDelivered,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_NoOrder value) noOrder,
    required TResult Function(_OrderCancelled value) orderCancelled,
    required TResult Function(_OrderDelivered value) orderDelivered,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_NoOrder value)? noOrder,
    TResult? Function(_OrderCancelled value)? orderCancelled,
    TResult? Function(_OrderDelivered value)? orderDelivered,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_NoOrder value)? noOrder,
    TResult Function(_OrderCancelled value)? orderCancelled,
    TResult Function(_OrderDelivered value)? orderDelivered,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements OrderTrackingState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$OrderTrackingStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'OrderTrackingState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )
    loaded,
    required TResult Function(String message) error,
    required TResult Function() noOrder,
    required TResult Function(String orderId, String reason) orderCancelled,
    required TResult Function(String orderId, DateTime deliveryTime)
    orderDelivered,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult? Function(String message)? error,
    TResult? Function()? noOrder,
    TResult? Function(String orderId, String reason)? orderCancelled,
    TResult? Function(String orderId, DateTime deliveryTime)? orderDelivered,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult Function(String message)? error,
    TResult Function()? noOrder,
    TResult Function(String orderId, String reason)? orderCancelled,
    TResult Function(String orderId, DateTime deliveryTime)? orderDelivered,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_NoOrder value) noOrder,
    required TResult Function(_OrderCancelled value) orderCancelled,
    required TResult Function(_OrderDelivered value) orderDelivered,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_NoOrder value)? noOrder,
    TResult? Function(_OrderCancelled value)? orderCancelled,
    TResult? Function(_OrderDelivered value)? orderDelivered,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_NoOrder value)? noOrder,
    TResult Function(_OrderCancelled value)? orderCancelled,
    TResult Function(_OrderDelivered value)? orderDelivered,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements OrderTrackingState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
    _$LoadedImpl value,
    $Res Function(_$LoadedImpl) then,
  ) = __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String orderId,
    List<OrderTrackingStatus> timeline,
    String address,
    String estimatedTime,
    String deliveryPerson,
    List<OrderProductSummary> products,
    int subtotal,
  });
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$OrderTrackingStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
    _$LoadedImpl _value,
    $Res Function(_$LoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? timeline = null,
    Object? address = null,
    Object? estimatedTime = null,
    Object? deliveryPerson = null,
    Object? products = null,
    Object? subtotal = null,
  }) {
    return _then(
      _$LoadedImpl(
        orderId:
            null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                    as String,
        timeline:
            null == timeline
                ? _value._timeline
                : timeline // ignore: cast_nullable_to_non_nullable
                    as List<OrderTrackingStatus>,
        address:
            null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                    as String,
        estimatedTime:
            null == estimatedTime
                ? _value.estimatedTime
                : estimatedTime // ignore: cast_nullable_to_non_nullable
                    as String,
        deliveryPerson:
            null == deliveryPerson
                ? _value.deliveryPerson
                : deliveryPerson // ignore: cast_nullable_to_non_nullable
                    as String,
        products:
            null == products
                ? _value._products
                : products // ignore: cast_nullable_to_non_nullable
                    as List<OrderProductSummary>,
        subtotal:
            null == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl({
    required this.orderId,
    required final List<OrderTrackingStatus> timeline,
    required this.address,
    required this.estimatedTime,
    required this.deliveryPerson,
    required final List<OrderProductSummary> products,
    required this.subtotal,
  }) : _timeline = timeline,
       _products = products;

  @override
  final String orderId;
  final List<OrderTrackingStatus> _timeline;
  @override
  List<OrderTrackingStatus> get timeline {
    if (_timeline is EqualUnmodifiableListView) return _timeline;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeline);
  }

  @override
  final String address;
  @override
  final String estimatedTime;
  @override
  final String deliveryPerson;
  final List<OrderProductSummary> _products;
  @override
  List<OrderProductSummary> get products {
    if (_products is EqualUnmodifiableListView) return _products;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_products);
  }

  @override
  final int subtotal;

  @override
  String toString() {
    return 'OrderTrackingState.loaded(orderId: $orderId, timeline: $timeline, address: $address, estimatedTime: $estimatedTime, deliveryPerson: $deliveryPerson, products: $products, subtotal: $subtotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            const DeepCollectionEquality().equals(other._timeline, _timeline) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.estimatedTime, estimatedTime) ||
                other.estimatedTime == estimatedTime) &&
            (identical(other.deliveryPerson, deliveryPerson) ||
                other.deliveryPerson == deliveryPerson) &&
            const DeepCollectionEquality().equals(other._products, _products) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    orderId,
    const DeepCollectionEquality().hash(_timeline),
    address,
    estimatedTime,
    deliveryPerson,
    const DeepCollectionEquality().hash(_products),
    subtotal,
  );

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )
    loaded,
    required TResult Function(String message) error,
    required TResult Function() noOrder,
    required TResult Function(String orderId, String reason) orderCancelled,
    required TResult Function(String orderId, DateTime deliveryTime)
    orderDelivered,
  }) {
    return loaded(
      orderId,
      timeline,
      address,
      estimatedTime,
      deliveryPerson,
      products,
      subtotal,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult? Function(String message)? error,
    TResult? Function()? noOrder,
    TResult? Function(String orderId, String reason)? orderCancelled,
    TResult? Function(String orderId, DateTime deliveryTime)? orderDelivered,
  }) {
    return loaded?.call(
      orderId,
      timeline,
      address,
      estimatedTime,
      deliveryPerson,
      products,
      subtotal,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult Function(String message)? error,
    TResult Function()? noOrder,
    TResult Function(String orderId, String reason)? orderCancelled,
    TResult Function(String orderId, DateTime deliveryTime)? orderDelivered,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(
        orderId,
        timeline,
        address,
        estimatedTime,
        deliveryPerson,
        products,
        subtotal,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_NoOrder value) noOrder,
    required TResult Function(_OrderCancelled value) orderCancelled,
    required TResult Function(_OrderDelivered value) orderDelivered,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_NoOrder value)? noOrder,
    TResult? Function(_OrderCancelled value)? orderCancelled,
    TResult? Function(_OrderDelivered value)? orderDelivered,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_NoOrder value)? noOrder,
    TResult Function(_OrderCancelled value)? orderCancelled,
    TResult Function(_OrderDelivered value)? orderDelivered,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements OrderTrackingState {
  const factory _Loaded({
    required final String orderId,
    required final List<OrderTrackingStatus> timeline,
    required final String address,
    required final String estimatedTime,
    required final String deliveryPerson,
    required final List<OrderProductSummary> products,
    required final int subtotal,
  }) = _$LoadedImpl;

  String get orderId;
  List<OrderTrackingStatus> get timeline;
  String get address;
  String get estimatedTime;
  String get deliveryPerson;
  List<OrderProductSummary> get products;
  int get subtotal;

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$OrderTrackingStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'OrderTrackingState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )
    loaded,
    required TResult Function(String message) error,
    required TResult Function() noOrder,
    required TResult Function(String orderId, String reason) orderCancelled,
    required TResult Function(String orderId, DateTime deliveryTime)
    orderDelivered,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult? Function(String message)? error,
    TResult? Function()? noOrder,
    TResult? Function(String orderId, String reason)? orderCancelled,
    TResult? Function(String orderId, DateTime deliveryTime)? orderDelivered,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult Function(String message)? error,
    TResult Function()? noOrder,
    TResult Function(String orderId, String reason)? orderCancelled,
    TResult Function(String orderId, DateTime deliveryTime)? orderDelivered,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_NoOrder value) noOrder,
    required TResult Function(_OrderCancelled value) orderCancelled,
    required TResult Function(_OrderDelivered value) orderDelivered,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_NoOrder value)? noOrder,
    TResult? Function(_OrderCancelled value)? orderCancelled,
    TResult? Function(_OrderDelivered value)? orderDelivered,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_NoOrder value)? noOrder,
    TResult Function(_OrderCancelled value)? orderCancelled,
    TResult Function(_OrderDelivered value)? orderDelivered,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements OrderTrackingState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NoOrderImplCopyWith<$Res> {
  factory _$$NoOrderImplCopyWith(
    _$NoOrderImpl value,
    $Res Function(_$NoOrderImpl) then,
  ) = __$$NoOrderImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NoOrderImplCopyWithImpl<$Res>
    extends _$OrderTrackingStateCopyWithImpl<$Res, _$NoOrderImpl>
    implements _$$NoOrderImplCopyWith<$Res> {
  __$$NoOrderImplCopyWithImpl(
    _$NoOrderImpl _value,
    $Res Function(_$NoOrderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$NoOrderImpl implements _NoOrder {
  const _$NoOrderImpl();

  @override
  String toString() {
    return 'OrderTrackingState.noOrder()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NoOrderImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )
    loaded,
    required TResult Function(String message) error,
    required TResult Function() noOrder,
    required TResult Function(String orderId, String reason) orderCancelled,
    required TResult Function(String orderId, DateTime deliveryTime)
    orderDelivered,
  }) {
    return noOrder();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult? Function(String message)? error,
    TResult? Function()? noOrder,
    TResult? Function(String orderId, String reason)? orderCancelled,
    TResult? Function(String orderId, DateTime deliveryTime)? orderDelivered,
  }) {
    return noOrder?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult Function(String message)? error,
    TResult Function()? noOrder,
    TResult Function(String orderId, String reason)? orderCancelled,
    TResult Function(String orderId, DateTime deliveryTime)? orderDelivered,
    required TResult orElse(),
  }) {
    if (noOrder != null) {
      return noOrder();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_NoOrder value) noOrder,
    required TResult Function(_OrderCancelled value) orderCancelled,
    required TResult Function(_OrderDelivered value) orderDelivered,
  }) {
    return noOrder(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_NoOrder value)? noOrder,
    TResult? Function(_OrderCancelled value)? orderCancelled,
    TResult? Function(_OrderDelivered value)? orderDelivered,
  }) {
    return noOrder?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_NoOrder value)? noOrder,
    TResult Function(_OrderCancelled value)? orderCancelled,
    TResult Function(_OrderDelivered value)? orderDelivered,
    required TResult orElse(),
  }) {
    if (noOrder != null) {
      return noOrder(this);
    }
    return orElse();
  }
}

abstract class _NoOrder implements OrderTrackingState {
  const factory _NoOrder() = _$NoOrderImpl;
}

/// @nodoc
abstract class _$$OrderCancelledImplCopyWith<$Res> {
  factory _$$OrderCancelledImplCopyWith(
    _$OrderCancelledImpl value,
    $Res Function(_$OrderCancelledImpl) then,
  ) = __$$OrderCancelledImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String orderId, String reason});
}

/// @nodoc
class __$$OrderCancelledImplCopyWithImpl<$Res>
    extends _$OrderTrackingStateCopyWithImpl<$Res, _$OrderCancelledImpl>
    implements _$$OrderCancelledImplCopyWith<$Res> {
  __$$OrderCancelledImplCopyWithImpl(
    _$OrderCancelledImpl _value,
    $Res Function(_$OrderCancelledImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? orderId = null, Object? reason = null}) {
    return _then(
      _$OrderCancelledImpl(
        orderId:
            null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                    as String,
        reason:
            null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc

class _$OrderCancelledImpl implements _OrderCancelled {
  const _$OrderCancelledImpl({required this.orderId, required this.reason});

  @override
  final String orderId;
  @override
  final String reason;

  @override
  String toString() {
    return 'OrderTrackingState.orderCancelled(orderId: $orderId, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderCancelledImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, orderId, reason);

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderCancelledImplCopyWith<_$OrderCancelledImpl> get copyWith =>
      __$$OrderCancelledImplCopyWithImpl<_$OrderCancelledImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )
    loaded,
    required TResult Function(String message) error,
    required TResult Function() noOrder,
    required TResult Function(String orderId, String reason) orderCancelled,
    required TResult Function(String orderId, DateTime deliveryTime)
    orderDelivered,
  }) {
    return orderCancelled(orderId, reason);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult? Function(String message)? error,
    TResult? Function()? noOrder,
    TResult? Function(String orderId, String reason)? orderCancelled,
    TResult? Function(String orderId, DateTime deliveryTime)? orderDelivered,
  }) {
    return orderCancelled?.call(orderId, reason);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult Function(String message)? error,
    TResult Function()? noOrder,
    TResult Function(String orderId, String reason)? orderCancelled,
    TResult Function(String orderId, DateTime deliveryTime)? orderDelivered,
    required TResult orElse(),
  }) {
    if (orderCancelled != null) {
      return orderCancelled(orderId, reason);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_NoOrder value) noOrder,
    required TResult Function(_OrderCancelled value) orderCancelled,
    required TResult Function(_OrderDelivered value) orderDelivered,
  }) {
    return orderCancelled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_NoOrder value)? noOrder,
    TResult? Function(_OrderCancelled value)? orderCancelled,
    TResult? Function(_OrderDelivered value)? orderDelivered,
  }) {
    return orderCancelled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_NoOrder value)? noOrder,
    TResult Function(_OrderCancelled value)? orderCancelled,
    TResult Function(_OrderDelivered value)? orderDelivered,
    required TResult orElse(),
  }) {
    if (orderCancelled != null) {
      return orderCancelled(this);
    }
    return orElse();
  }
}

abstract class _OrderCancelled implements OrderTrackingState {
  const factory _OrderCancelled({
    required final String orderId,
    required final String reason,
  }) = _$OrderCancelledImpl;

  String get orderId;
  String get reason;

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderCancelledImplCopyWith<_$OrderCancelledImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OrderDeliveredImplCopyWith<$Res> {
  factory _$$OrderDeliveredImplCopyWith(
    _$OrderDeliveredImpl value,
    $Res Function(_$OrderDeliveredImpl) then,
  ) = __$$OrderDeliveredImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String orderId, DateTime deliveryTime});
}

/// @nodoc
class __$$OrderDeliveredImplCopyWithImpl<$Res>
    extends _$OrderTrackingStateCopyWithImpl<$Res, _$OrderDeliveredImpl>
    implements _$$OrderDeliveredImplCopyWith<$Res> {
  __$$OrderDeliveredImplCopyWithImpl(
    _$OrderDeliveredImpl _value,
    $Res Function(_$OrderDeliveredImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? orderId = null, Object? deliveryTime = null}) {
    return _then(
      _$OrderDeliveredImpl(
        orderId:
            null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                    as String,
        deliveryTime:
            null == deliveryTime
                ? _value.deliveryTime
                : deliveryTime // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$OrderDeliveredImpl implements _OrderDelivered {
  const _$OrderDeliveredImpl({
    required this.orderId,
    required this.deliveryTime,
  });

  @override
  final String orderId;
  @override
  final DateTime deliveryTime;

  @override
  String toString() {
    return 'OrderTrackingState.orderDelivered(orderId: $orderId, deliveryTime: $deliveryTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderDeliveredImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.deliveryTime, deliveryTime) ||
                other.deliveryTime == deliveryTime));
  }

  @override
  int get hashCode => Object.hash(runtimeType, orderId, deliveryTime);

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderDeliveredImplCopyWith<_$OrderDeliveredImpl> get copyWith =>
      __$$OrderDeliveredImplCopyWithImpl<_$OrderDeliveredImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )
    loaded,
    required TResult Function(String message) error,
    required TResult Function() noOrder,
    required TResult Function(String orderId, String reason) orderCancelled,
    required TResult Function(String orderId, DateTime deliveryTime)
    orderDelivered,
  }) {
    return orderDelivered(orderId, deliveryTime);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult? Function(String message)? error,
    TResult? Function()? noOrder,
    TResult? Function(String orderId, String reason)? orderCancelled,
    TResult? Function(String orderId, DateTime deliveryTime)? orderDelivered,
  }) {
    return orderDelivered?.call(orderId, deliveryTime);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      String orderId,
      List<OrderTrackingStatus> timeline,
      String address,
      String estimatedTime,
      String deliveryPerson,
      List<OrderProductSummary> products,
      int subtotal,
    )?
    loaded,
    TResult Function(String message)? error,
    TResult Function()? noOrder,
    TResult Function(String orderId, String reason)? orderCancelled,
    TResult Function(String orderId, DateTime deliveryTime)? orderDelivered,
    required TResult orElse(),
  }) {
    if (orderDelivered != null) {
      return orderDelivered(orderId, deliveryTime);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_NoOrder value) noOrder,
    required TResult Function(_OrderCancelled value) orderCancelled,
    required TResult Function(_OrderDelivered value) orderDelivered,
  }) {
    return orderDelivered(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_NoOrder value)? noOrder,
    TResult? Function(_OrderCancelled value)? orderCancelled,
    TResult? Function(_OrderDelivered value)? orderDelivered,
  }) {
    return orderDelivered?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_NoOrder value)? noOrder,
    TResult Function(_OrderCancelled value)? orderCancelled,
    TResult Function(_OrderDelivered value)? orderDelivered,
    required TResult orElse(),
  }) {
    if (orderDelivered != null) {
      return orderDelivered(this);
    }
    return orElse();
  }
}

abstract class _OrderDelivered implements OrderTrackingState {
  const factory _OrderDelivered({
    required final String orderId,
    required final DateTime deliveryTime,
  }) = _$OrderDeliveredImpl;

  String get orderId;
  DateTime get deliveryTime;

  /// Create a copy of OrderTrackingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderDeliveredImplCopyWith<_$OrderDeliveredImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$OrderProductSummary {
  String get name => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Create a copy of OrderProductSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderProductSummaryCopyWith<OrderProductSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderProductSummaryCopyWith<$Res> {
  factory $OrderProductSummaryCopyWith(
    OrderProductSummary value,
    $Res Function(OrderProductSummary) then,
  ) = _$OrderProductSummaryCopyWithImpl<$Res, OrderProductSummary>;
  @useResult
  $Res call({String name, int quantity, int price, String? imageUrl});
}

/// @nodoc
class _$OrderProductSummaryCopyWithImpl<$Res, $Val extends OrderProductSummary>
    implements $OrderProductSummaryCopyWith<$Res> {
  _$OrderProductSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderProductSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? quantity = null,
    Object? price = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            quantity:
                null == quantity
                    ? _value.quantity
                    : quantity // ignore: cast_nullable_to_non_nullable
                        as int,
            price:
                null == price
                    ? _value.price
                    : price // ignore: cast_nullable_to_non_nullable
                        as int,
            imageUrl:
                freezed == imageUrl
                    ? _value.imageUrl
                    : imageUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderProductSummaryImplCopyWith<$Res>
    implements $OrderProductSummaryCopyWith<$Res> {
  factory _$$OrderProductSummaryImplCopyWith(
    _$OrderProductSummaryImpl value,
    $Res Function(_$OrderProductSummaryImpl) then,
  ) = __$$OrderProductSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int quantity, int price, String? imageUrl});
}

/// @nodoc
class __$$OrderProductSummaryImplCopyWithImpl<$Res>
    extends _$OrderProductSummaryCopyWithImpl<$Res, _$OrderProductSummaryImpl>
    implements _$$OrderProductSummaryImplCopyWith<$Res> {
  __$$OrderProductSummaryImplCopyWithImpl(
    _$OrderProductSummaryImpl _value,
    $Res Function(_$OrderProductSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderProductSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? quantity = null,
    Object? price = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _$OrderProductSummaryImpl(
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        quantity:
            null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                    as int,
        price:
            null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                    as int,
        imageUrl:
            freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$OrderProductSummaryImpl implements _OrderProductSummary {
  const _$OrderProductSummaryImpl({
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  @override
  final String name;
  @override
  final int quantity;
  @override
  final int price;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'OrderProductSummary(name: $name, quantity: $quantity, price: $price, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderProductSummaryImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, quantity, price, imageUrl);

  /// Create a copy of OrderProductSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderProductSummaryImplCopyWith<_$OrderProductSummaryImpl> get copyWith =>
      __$$OrderProductSummaryImplCopyWithImpl<_$OrderProductSummaryImpl>(
        this,
        _$identity,
      );
}

abstract class _OrderProductSummary implements OrderProductSummary {
  const factory _OrderProductSummary({
    required final String name,
    required final int quantity,
    required final int price,
    final String? imageUrl,
  }) = _$OrderProductSummaryImpl;

  @override
  String get name;
  @override
  int get quantity;
  @override
  int get price;
  @override
  String? get imageUrl;

  /// Create a copy of OrderProductSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderProductSummaryImplCopyWith<_$OrderProductSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
