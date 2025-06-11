// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Order _$OrderFromJson(Map<String, dynamic> json) {
  return _Order.fromJson(json);
}

/// @nodoc
mixin _$Order {
  String get id => throw _privateConstructorUsedError;
  String get restaurantName => throw _privateConstructorUsedError;
  List<CartItem> get items => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get tax => throw _privateConstructorUsedError;
  double get deliveryCost => throw _privateConstructorUsedError;
  double get discount => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  int get estimatedDeliveryTime => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get estimatedArrival => throw _privateConstructorUsedError;

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderCopyWith<Order> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) then) =
      _$OrderCopyWithImpl<$Res, Order>;
  @useResult
  $Res call({
    String id,
    String restaurantName,
    List<CartItem> items,
    OrderStatus status,
    double subtotal,
    double tax,
    double deliveryCost,
    double discount,
    double total,
    int estimatedDeliveryTime,
    DateTime createdAt,
    DateTime? estimatedArrival,
  });
}

/// @nodoc
class _$OrderCopyWithImpl<$Res, $Val extends Order>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? restaurantName = null,
    Object? items = null,
    Object? status = null,
    Object? subtotal = null,
    Object? tax = null,
    Object? deliveryCost = null,
    Object? discount = null,
    Object? total = null,
    Object? estimatedDeliveryTime = null,
    Object? createdAt = null,
    Object? estimatedArrival = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            restaurantName:
                null == restaurantName
                    ? _value.restaurantName
                    : restaurantName // ignore: cast_nullable_to_non_nullable
                        as String,
            items:
                null == items
                    ? _value.items
                    : items // ignore: cast_nullable_to_non_nullable
                        as List<CartItem>,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as OrderStatus,
            subtotal:
                null == subtotal
                    ? _value.subtotal
                    : subtotal // ignore: cast_nullable_to_non_nullable
                        as double,
            tax:
                null == tax
                    ? _value.tax
                    : tax // ignore: cast_nullable_to_non_nullable
                        as double,
            deliveryCost:
                null == deliveryCost
                    ? _value.deliveryCost
                    : deliveryCost // ignore: cast_nullable_to_non_nullable
                        as double,
            discount:
                null == discount
                    ? _value.discount
                    : discount // ignore: cast_nullable_to_non_nullable
                        as double,
            total:
                null == total
                    ? _value.total
                    : total // ignore: cast_nullable_to_non_nullable
                        as double,
            estimatedDeliveryTime:
                null == estimatedDeliveryTime
                    ? _value.estimatedDeliveryTime
                    : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
                        as int,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            estimatedArrival:
                freezed == estimatedArrival
                    ? _value.estimatedArrival
                    : estimatedArrival // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderImplCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$$OrderImplCopyWith(
    _$OrderImpl value,
    $Res Function(_$OrderImpl) then,
  ) = __$$OrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String restaurantName,
    List<CartItem> items,
    OrderStatus status,
    double subtotal,
    double tax,
    double deliveryCost,
    double discount,
    double total,
    int estimatedDeliveryTime,
    DateTime createdAt,
    DateTime? estimatedArrival,
  });
}

/// @nodoc
class __$$OrderImplCopyWithImpl<$Res>
    extends _$OrderCopyWithImpl<$Res, _$OrderImpl>
    implements _$$OrderImplCopyWith<$Res> {
  __$$OrderImplCopyWithImpl(
    _$OrderImpl _value,
    $Res Function(_$OrderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? restaurantName = null,
    Object? items = null,
    Object? status = null,
    Object? subtotal = null,
    Object? tax = null,
    Object? deliveryCost = null,
    Object? discount = null,
    Object? total = null,
    Object? estimatedDeliveryTime = null,
    Object? createdAt = null,
    Object? estimatedArrival = freezed,
  }) {
    return _then(
      _$OrderImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        restaurantName:
            null == restaurantName
                ? _value.restaurantName
                : restaurantName // ignore: cast_nullable_to_non_nullable
                    as String,
        items:
            null == items
                ? _value._items
                : items // ignore: cast_nullable_to_non_nullable
                    as List<CartItem>,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as OrderStatus,
        subtotal:
            null == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                    as double,
        tax:
            null == tax
                ? _value.tax
                : tax // ignore: cast_nullable_to_non_nullable
                    as double,
        deliveryCost:
            null == deliveryCost
                ? _value.deliveryCost
                : deliveryCost // ignore: cast_nullable_to_non_nullable
                    as double,
        discount:
            null == discount
                ? _value.discount
                : discount // ignore: cast_nullable_to_non_nullable
                    as double,
        total:
            null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                    as double,
        estimatedDeliveryTime:
            null == estimatedDeliveryTime
                ? _value.estimatedDeliveryTime
                : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
                    as int,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        estimatedArrival:
            freezed == estimatedArrival
                ? _value.estimatedArrival
                : estimatedArrival // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderImpl implements _Order {
  const _$OrderImpl({
    required this.id,
    required this.restaurantName,
    required final List<CartItem> items,
    this.status = OrderStatus.confirmed,
    required this.subtotal,
    required this.tax,
    required this.deliveryCost,
    required this.discount,
    required this.total,
    required this.estimatedDeliveryTime,
    required this.createdAt,
    this.estimatedArrival,
  }) : _items = items;

  factory _$OrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderImplFromJson(json);

  @override
  final String id;
  @override
  final String restaurantName;
  final List<CartItem> _items;
  @override
  List<CartItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final OrderStatus status;
  @override
  final double subtotal;
  @override
  final double tax;
  @override
  final double deliveryCost;
  @override
  final double discount;
  @override
  final double total;
  @override
  final int estimatedDeliveryTime;
  @override
  final DateTime createdAt;
  @override
  final DateTime? estimatedArrival;

  @override
  String toString() {
    return 'Order(id: $id, restaurantName: $restaurantName, items: $items, status: $status, subtotal: $subtotal, tax: $tax, deliveryCost: $deliveryCost, discount: $discount, total: $total, estimatedDeliveryTime: $estimatedDeliveryTime, createdAt: $createdAt, estimatedArrival: $estimatedArrival)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.restaurantName, restaurantName) ||
                other.restaurantName == restaurantName) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.tax, tax) || other.tax == tax) &&
            (identical(other.deliveryCost, deliveryCost) ||
                other.deliveryCost == deliveryCost) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.estimatedDeliveryTime, estimatedDeliveryTime) ||
                other.estimatedDeliveryTime == estimatedDeliveryTime) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.estimatedArrival, estimatedArrival) ||
                other.estimatedArrival == estimatedArrival));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    restaurantName,
    const DeepCollectionEquality().hash(_items),
    status,
    subtotal,
    tax,
    deliveryCost,
    discount,
    total,
    estimatedDeliveryTime,
    createdAt,
    estimatedArrival,
  );

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      __$$OrderImplCopyWithImpl<_$OrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderImplToJson(this);
  }
}

abstract class _Order implements Order {
  const factory _Order({
    required final String id,
    required final String restaurantName,
    required final List<CartItem> items,
    final OrderStatus status,
    required final double subtotal,
    required final double tax,
    required final double deliveryCost,
    required final double discount,
    required final double total,
    required final int estimatedDeliveryTime,
    required final DateTime createdAt,
    final DateTime? estimatedArrival,
  }) = _$OrderImpl;

  factory _Order.fromJson(Map<String, dynamic> json) = _$OrderImpl.fromJson;

  @override
  String get id;
  @override
  String get restaurantName;
  @override
  List<CartItem> get items;
  @override
  OrderStatus get status;
  @override
  double get subtotal;
  @override
  double get tax;
  @override
  double get deliveryCost;
  @override
  double get discount;
  @override
  double get total;
  @override
  int get estimatedDeliveryTime;
  @override
  DateTime get createdAt;
  @override
  DateTime? get estimatedArrival;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
