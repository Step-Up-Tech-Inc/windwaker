// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AddressImpl _$$AddressImplFromJson(Map<String, dynamic> json) =>
    _$AddressImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      label: json['label'] as String,
      detail: json['detail'] as String,
      district: json['district'] as String?,
      reference: json['reference'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$AddressImplToJson(_$AddressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'label': instance.label,
      'detail': instance.detail,
      'district': instance.district,
      'reference': instance.reference,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'is_default': instance.isDefault,
      'created_at': instance.createdAt?.toIso8601String(),
    };
