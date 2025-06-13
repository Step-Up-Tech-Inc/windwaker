// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_tracking_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderTrackingStatusImpl _$$OrderTrackingStatusImplFromJson(
  Map<String, dynamic> json,
) => _$OrderTrackingStatusImpl(
  status: $enumDecode(_$OrderStatusTypeEnumMap, json['status']),
  time: json['time'] == null ? null : DateTime.parse(json['time'] as String),
  estimated: json['estimated'] as String?,
);

Map<String, dynamic> _$$OrderTrackingStatusImplToJson(
  _$OrderTrackingStatusImpl instance,
) => <String, dynamic>{
  'status': _$OrderStatusTypeEnumMap[instance.status]!,
  'time': instance.time?.toIso8601String(),
  'estimated': instance.estimated,
};

const _$OrderStatusTypeEnumMap = {
  OrderStatusType.processed: 'processed',
  OrderStatusType.preparing: 'preparing',
  OrderStatusType.onTheWay: 'on_the_way',
  OrderStatusType.delivered: 'delivered',
  OrderStatusType.cancelled: 'cancelled',
};
