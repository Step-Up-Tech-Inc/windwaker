// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
  id: json['id'] as String,
  customerId: json['customer_id'] as String,
  storeId: json['store_id'] as String,
  driverId: json['driver_id'] as String?,
  status:
      $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
      OrderStatus.pending,
  deliveryMethod:
      $enumDecodeNullable(_$DeliveryMethodEnumMap, json['delivery_method']) ??
      DeliveryMethod.delivery,
  paymentMethod:
      $enumDecodeNullable(
        _$OrderPaymentMethodEnumMap,
        json['payment_method'],
      ) ??
      OrderPaymentMethod.cash,
  addressLabel: json['address_label'] as String?,
  addressDetail: json['address_detail'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  subtotal: (json['subtotal'] as num).toDouble(),
  deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
  total: (json['total'] as num).toDouble(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
  paymentStatus:
      $enumDecodeNullable(_$PaymentStatusEnumMap, json['payment_status']) ??
      PaymentStatus.notRequired,
  paymentReference: json['payment_reference'] as String?,
  paymentProofPath: json['payment_proof_path'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  storeName: json['store_name'] as String?,
  storeSinpeNumber: json['store_sinpe_number'] as String?,
);

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'store_id': instance.storeId,
      'driver_id': instance.driverId,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'delivery_method': _$DeliveryMethodEnumMap[instance.deliveryMethod]!,
      'payment_method': _$OrderPaymentMethodEnumMap[instance.paymentMethod]!,
      'address_label': instance.addressLabel,
      'address_detail': instance.addressDetail,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'subtotal': instance.subtotal,
      'delivery_fee': instance.deliveryFee,
      'total': instance.total,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'payment_status': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'payment_reference': instance.paymentReference,
      'payment_proof_path': instance.paymentProofPath,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'store_name': instance.storeName,
      'store_sinpe_number': instance.storeSinpeNumber,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.accepted: 'accepted',
  OrderStatus.preparing: 'preparing',
  OrderStatus.ready: 'ready',
  OrderStatus.pickedUp: 'picked_up',
  OrderStatus.delivered: 'delivered',
  OrderStatus.rejected: 'rejected',
  OrderStatus.cancelled: 'cancelled',
};

const _$DeliveryMethodEnumMap = {
  DeliveryMethod.delivery: 'delivery',
  DeliveryMethod.pickup: 'pickup',
};

const _$OrderPaymentMethodEnumMap = {
  OrderPaymentMethod.cash: 'cash',
  OrderPaymentMethod.sinpe: 'sinpe',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.notRequired: 'not_required',
  PaymentStatus.pending: 'pending',
  PaymentStatus.submitted: 'submitted',
  PaymentStatus.verified: 'verified',
  PaymentStatus.rejected: 'rejected',
};
