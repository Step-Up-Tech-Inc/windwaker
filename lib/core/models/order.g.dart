// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
  id: json['id'] as String,
  restaurantName: json['restaurant_name'] as String,
  items:
      (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
  status:
      $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
      OrderStatus.confirmed,
  subtotal: (json['subtotal'] as num).toDouble(),
  tax: (json['tax'] as num).toDouble(),
  deliveryCost: (json['delivery_cost'] as num).toDouble(),
  discount: (json['discount'] as num).toDouble(),
  total: (json['total'] as num).toDouble(),
  estimatedDeliveryTime: (json['estimated_delivery_time'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  estimatedArrival:
      json['estimated_arrival'] == null
          ? null
          : DateTime.parse(json['estimated_arrival'] as String),
);

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'restaurant_name': instance.restaurantName,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'status': _$OrderStatusEnumMap[instance.status]!,
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'delivery_cost': instance.deliveryCost,
      'discount': instance.discount,
      'total': instance.total,
      'estimated_delivery_time': instance.estimatedDeliveryTime,
      'created_at': instance.createdAt.toIso8601String(),
      'estimated_arrival': instance.estimatedArrival?.toIso8601String(),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.confirmed: 'CONFIRMED',
  OrderStatus.inProgress: 'IN_PROGRESS',
  OrderStatus.onTheWay: 'ON_THE_WAY',
  OrderStatus.delivered: 'DELIVERED',
};
