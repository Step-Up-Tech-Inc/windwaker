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
  @JsonKey(name: 'customer_id')
  String get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'store_id')
  String get storeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'driver_id')
  String? get driverId => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_method')
  DeliveryMethod get deliveryMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method')
  OrderPaymentMethod get paymentMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_label')
  String? get addressLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_detail')
  String? get addressDetail => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_fee')
  double get deliveryFee => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_status')
  PaymentStatus get paymentStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_reference')
  String? get paymentReference => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_proof_path')
  String? get paymentProofPath => throw _privateConstructorUsedError;

  /// Poblado por el repositorio desde el join `order_items(*)`.
  List<OrderItem> get items => throw _privateConstructorUsedError;

  /// Poblado por el repositorio desde el join `stores(...)`.
  @JsonKey(name: 'store_name')
  String? get storeName => throw _privateConstructorUsedError;
  @JsonKey(name: 'store_sinpe_number')
  String? get storeSinpeNumber => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'customer_id') String customerId,
    @JsonKey(name: 'store_id') String storeId,
    @JsonKey(name: 'driver_id') String? driverId,
    OrderStatus status,
    @JsonKey(name: 'delivery_method') DeliveryMethod deliveryMethod,
    @JsonKey(name: 'payment_method') OrderPaymentMethod paymentMethod,
    @JsonKey(name: 'address_label') String? addressLabel,
    @JsonKey(name: 'address_detail') String? addressDetail,
    double? latitude,
    double? longitude,
    double subtotal,
    @JsonKey(name: 'delivery_fee') double deliveryFee,
    double total,
    String? notes,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'payment_status') PaymentStatus paymentStatus,
    @JsonKey(name: 'payment_reference') String? paymentReference,
    @JsonKey(name: 'payment_proof_path') String? paymentProofPath,
    List<OrderItem> items,
    @JsonKey(name: 'store_name') String? storeName,
    @JsonKey(name: 'store_sinpe_number') String? storeSinpeNumber,
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
    Object? customerId = null,
    Object? storeId = null,
    Object? driverId = freezed,
    Object? status = null,
    Object? deliveryMethod = null,
    Object? paymentMethod = null,
    Object? addressLabel = freezed,
    Object? addressDetail = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? subtotal = null,
    Object? deliveryFee = null,
    Object? total = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? paymentStatus = null,
    Object? paymentReference = freezed,
    Object? paymentProofPath = freezed,
    Object? items = null,
    Object? storeName = freezed,
    Object? storeSinpeNumber = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            customerId:
                null == customerId
                    ? _value.customerId
                    : customerId // ignore: cast_nullable_to_non_nullable
                        as String,
            storeId:
                null == storeId
                    ? _value.storeId
                    : storeId // ignore: cast_nullable_to_non_nullable
                        as String,
            driverId:
                freezed == driverId
                    ? _value.driverId
                    : driverId // ignore: cast_nullable_to_non_nullable
                        as String?,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as OrderStatus,
            deliveryMethod:
                null == deliveryMethod
                    ? _value.deliveryMethod
                    : deliveryMethod // ignore: cast_nullable_to_non_nullable
                        as DeliveryMethod,
            paymentMethod:
                null == paymentMethod
                    ? _value.paymentMethod
                    : paymentMethod // ignore: cast_nullable_to_non_nullable
                        as OrderPaymentMethod,
            addressLabel:
                freezed == addressLabel
                    ? _value.addressLabel
                    : addressLabel // ignore: cast_nullable_to_non_nullable
                        as String?,
            addressDetail:
                freezed == addressDetail
                    ? _value.addressDetail
                    : addressDetail // ignore: cast_nullable_to_non_nullable
                        as String?,
            latitude:
                freezed == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            longitude:
                freezed == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            subtotal:
                null == subtotal
                    ? _value.subtotal
                    : subtotal // ignore: cast_nullable_to_non_nullable
                        as double,
            deliveryFee:
                null == deliveryFee
                    ? _value.deliveryFee
                    : deliveryFee // ignore: cast_nullable_to_non_nullable
                        as double,
            total:
                null == total
                    ? _value.total
                    : total // ignore: cast_nullable_to_non_nullable
                        as double,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                freezed == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            paymentStatus:
                null == paymentStatus
                    ? _value.paymentStatus
                    : paymentStatus // ignore: cast_nullable_to_non_nullable
                        as PaymentStatus,
            paymentReference:
                freezed == paymentReference
                    ? _value.paymentReference
                    : paymentReference // ignore: cast_nullable_to_non_nullable
                        as String?,
            paymentProofPath:
                freezed == paymentProofPath
                    ? _value.paymentProofPath
                    : paymentProofPath // ignore: cast_nullable_to_non_nullable
                        as String?,
            items:
                null == items
                    ? _value.items
                    : items // ignore: cast_nullable_to_non_nullable
                        as List<OrderItem>,
            storeName:
                freezed == storeName
                    ? _value.storeName
                    : storeName // ignore: cast_nullable_to_non_nullable
                        as String?,
            storeSinpeNumber:
                freezed == storeSinpeNumber
                    ? _value.storeSinpeNumber
                    : storeSinpeNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
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
    @JsonKey(name: 'customer_id') String customerId,
    @JsonKey(name: 'store_id') String storeId,
    @JsonKey(name: 'driver_id') String? driverId,
    OrderStatus status,
    @JsonKey(name: 'delivery_method') DeliveryMethod deliveryMethod,
    @JsonKey(name: 'payment_method') OrderPaymentMethod paymentMethod,
    @JsonKey(name: 'address_label') String? addressLabel,
    @JsonKey(name: 'address_detail') String? addressDetail,
    double? latitude,
    double? longitude,
    double subtotal,
    @JsonKey(name: 'delivery_fee') double deliveryFee,
    double total,
    String? notes,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'payment_status') PaymentStatus paymentStatus,
    @JsonKey(name: 'payment_reference') String? paymentReference,
    @JsonKey(name: 'payment_proof_path') String? paymentProofPath,
    List<OrderItem> items,
    @JsonKey(name: 'store_name') String? storeName,
    @JsonKey(name: 'store_sinpe_number') String? storeSinpeNumber,
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
    Object? customerId = null,
    Object? storeId = null,
    Object? driverId = freezed,
    Object? status = null,
    Object? deliveryMethod = null,
    Object? paymentMethod = null,
    Object? addressLabel = freezed,
    Object? addressDetail = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? subtotal = null,
    Object? deliveryFee = null,
    Object? total = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? paymentStatus = null,
    Object? paymentReference = freezed,
    Object? paymentProofPath = freezed,
    Object? items = null,
    Object? storeName = freezed,
    Object? storeSinpeNumber = freezed,
  }) {
    return _then(
      _$OrderImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        customerId:
            null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                    as String,
        storeId:
            null == storeId
                ? _value.storeId
                : storeId // ignore: cast_nullable_to_non_nullable
                    as String,
        driverId:
            freezed == driverId
                ? _value.driverId
                : driverId // ignore: cast_nullable_to_non_nullable
                    as String?,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as OrderStatus,
        deliveryMethod:
            null == deliveryMethod
                ? _value.deliveryMethod
                : deliveryMethod // ignore: cast_nullable_to_non_nullable
                    as DeliveryMethod,
        paymentMethod:
            null == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                    as OrderPaymentMethod,
        addressLabel:
            freezed == addressLabel
                ? _value.addressLabel
                : addressLabel // ignore: cast_nullable_to_non_nullable
                    as String?,
        addressDetail:
            freezed == addressDetail
                ? _value.addressDetail
                : addressDetail // ignore: cast_nullable_to_non_nullable
                    as String?,
        latitude:
            freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        longitude:
            freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        subtotal:
            null == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                    as double,
        deliveryFee:
            null == deliveryFee
                ? _value.deliveryFee
                : deliveryFee // ignore: cast_nullable_to_non_nullable
                    as double,
        total:
            null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                    as double,
        notes:
            freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        paymentStatus:
            null == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                    as PaymentStatus,
        paymentReference:
            freezed == paymentReference
                ? _value.paymentReference
                : paymentReference // ignore: cast_nullable_to_non_nullable
                    as String?,
        paymentProofPath:
            freezed == paymentProofPath
                ? _value.paymentProofPath
                : paymentProofPath // ignore: cast_nullable_to_non_nullable
                    as String?,
        items:
            null == items
                ? _value._items
                : items // ignore: cast_nullable_to_non_nullable
                    as List<OrderItem>,
        storeName:
            freezed == storeName
                ? _value.storeName
                : storeName // ignore: cast_nullable_to_non_nullable
                    as String?,
        storeSinpeNumber:
            freezed == storeSinpeNumber
                ? _value.storeSinpeNumber
                : storeSinpeNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderImpl extends _Order {
  const _$OrderImpl({
    required this.id,
    @JsonKey(name: 'customer_id') required this.customerId,
    @JsonKey(name: 'store_id') required this.storeId,
    @JsonKey(name: 'driver_id') this.driverId,
    this.status = OrderStatus.pending,
    @JsonKey(name: 'delivery_method')
    this.deliveryMethod = DeliveryMethod.delivery,
    @JsonKey(name: 'payment_method')
    this.paymentMethod = OrderPaymentMethod.cash,
    @JsonKey(name: 'address_label') this.addressLabel,
    @JsonKey(name: 'address_detail') this.addressDetail,
    this.latitude,
    this.longitude,
    required this.subtotal,
    @JsonKey(name: 'delivery_fee') this.deliveryFee = 0,
    required this.total,
    this.notes,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    @JsonKey(name: 'payment_status')
    this.paymentStatus = PaymentStatus.notRequired,
    @JsonKey(name: 'payment_reference') this.paymentReference,
    @JsonKey(name: 'payment_proof_path') this.paymentProofPath,
    final List<OrderItem> items = const [],
    @JsonKey(name: 'store_name') this.storeName,
    @JsonKey(name: 'store_sinpe_number') this.storeSinpeNumber,
  }) : _items = items,
       super._();

  factory _$OrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'customer_id')
  final String customerId;
  @override
  @JsonKey(name: 'store_id')
  final String storeId;
  @override
  @JsonKey(name: 'driver_id')
  final String? driverId;
  @override
  @JsonKey()
  final OrderStatus status;
  @override
  @JsonKey(name: 'delivery_method')
  final DeliveryMethod deliveryMethod;
  @override
  @JsonKey(name: 'payment_method')
  final OrderPaymentMethod paymentMethod;
  @override
  @JsonKey(name: 'address_label')
  final String? addressLabel;
  @override
  @JsonKey(name: 'address_detail')
  final String? addressDetail;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final double subtotal;
  @override
  @JsonKey(name: 'delivery_fee')
  final double deliveryFee;
  @override
  final double total;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'payment_status')
  final PaymentStatus paymentStatus;
  @override
  @JsonKey(name: 'payment_reference')
  final String? paymentReference;
  @override
  @JsonKey(name: 'payment_proof_path')
  final String? paymentProofPath;

  /// Poblado por el repositorio desde el join `order_items(*)`.
  final List<OrderItem> _items;

  /// Poblado por el repositorio desde el join `order_items(*)`.
  @override
  @JsonKey()
  List<OrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// Poblado por el repositorio desde el join `stores(...)`.
  @override
  @JsonKey(name: 'store_name')
  final String? storeName;
  @override
  @JsonKey(name: 'store_sinpe_number')
  final String? storeSinpeNumber;

  @override
  String toString() {
    return 'Order(id: $id, customerId: $customerId, storeId: $storeId, driverId: $driverId, status: $status, deliveryMethod: $deliveryMethod, paymentMethod: $paymentMethod, addressLabel: $addressLabel, addressDetail: $addressDetail, latitude: $latitude, longitude: $longitude, subtotal: $subtotal, deliveryFee: $deliveryFee, total: $total, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, paymentStatus: $paymentStatus, paymentReference: $paymentReference, paymentProofPath: $paymentProofPath, items: $items, storeName: $storeName, storeSinpeNumber: $storeSinpeNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.deliveryMethod, deliveryMethod) ||
                other.deliveryMethod == deliveryMethod) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.addressLabel, addressLabel) ||
                other.addressLabel == addressLabel) &&
            (identical(other.addressDetail, addressDetail) ||
                other.addressDetail == addressDetail) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentReference, paymentReference) ||
                other.paymentReference == paymentReference) &&
            (identical(other.paymentProofPath, paymentProofPath) ||
                other.paymentProofPath == paymentProofPath) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.storeSinpeNumber, storeSinpeNumber) ||
                other.storeSinpeNumber == storeSinpeNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    customerId,
    storeId,
    driverId,
    status,
    deliveryMethod,
    paymentMethod,
    addressLabel,
    addressDetail,
    latitude,
    longitude,
    subtotal,
    deliveryFee,
    total,
    notes,
    createdAt,
    updatedAt,
    paymentStatus,
    paymentReference,
    paymentProofPath,
    const DeepCollectionEquality().hash(_items),
    storeName,
    storeSinpeNumber,
  ]);

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

abstract class _Order extends Order {
  const factory _Order({
    required final String id,
    @JsonKey(name: 'customer_id') required final String customerId,
    @JsonKey(name: 'store_id') required final String storeId,
    @JsonKey(name: 'driver_id') final String? driverId,
    final OrderStatus status,
    @JsonKey(name: 'delivery_method') final DeliveryMethod deliveryMethod,
    @JsonKey(name: 'payment_method') final OrderPaymentMethod paymentMethod,
    @JsonKey(name: 'address_label') final String? addressLabel,
    @JsonKey(name: 'address_detail') final String? addressDetail,
    final double? latitude,
    final double? longitude,
    required final double subtotal,
    @JsonKey(name: 'delivery_fee') final double deliveryFee,
    required final double total,
    final String? notes,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
    @JsonKey(name: 'payment_status') final PaymentStatus paymentStatus,
    @JsonKey(name: 'payment_reference') final String? paymentReference,
    @JsonKey(name: 'payment_proof_path') final String? paymentProofPath,
    final List<OrderItem> items,
    @JsonKey(name: 'store_name') final String? storeName,
    @JsonKey(name: 'store_sinpe_number') final String? storeSinpeNumber,
  }) = _$OrderImpl;
  const _Order._() : super._();

  factory _Order.fromJson(Map<String, dynamic> json) = _$OrderImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'customer_id')
  String get customerId;
  @override
  @JsonKey(name: 'store_id')
  String get storeId;
  @override
  @JsonKey(name: 'driver_id')
  String? get driverId;
  @override
  OrderStatus get status;
  @override
  @JsonKey(name: 'delivery_method')
  DeliveryMethod get deliveryMethod;
  @override
  @JsonKey(name: 'payment_method')
  OrderPaymentMethod get paymentMethod;
  @override
  @JsonKey(name: 'address_label')
  String? get addressLabel;
  @override
  @JsonKey(name: 'address_detail')
  String? get addressDetail;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  double get subtotal;
  @override
  @JsonKey(name: 'delivery_fee')
  double get deliveryFee;
  @override
  double get total;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'payment_status')
  PaymentStatus get paymentStatus;
  @override
  @JsonKey(name: 'payment_reference')
  String? get paymentReference;
  @override
  @JsonKey(name: 'payment_proof_path')
  String? get paymentProofPath;

  /// Poblado por el repositorio desde el join `order_items(*)`.
  @override
  List<OrderItem> get items;

  /// Poblado por el repositorio desde el join `stores(...)`.
  @override
  @JsonKey(name: 'store_name')
  String? get storeName;
  @override
  @JsonKey(name: 'store_sinpe_number')
  String? get storeSinpeNumber;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
