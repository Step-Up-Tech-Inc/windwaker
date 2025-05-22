// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoreImpl _$$StoreImplFromJson(Map<String, dynamic> json) => _$StoreImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  imageUrl: json['image_url'] as String,
  category: json['category'] as String,
  rating: (json['rating'] as num).toDouble(),
  deliveryTimeMinutes: (json['delivery_time_minutes'] as num).toInt(),
  deliveryFee: (json['delivery_fee'] as num).toDouble(),
  isOpen: json['is_open'] as bool,
  isFavorite: json['is_favorite'] as bool? ?? false,
);

Map<String, dynamic> _$$StoreImplToJson(_$StoreImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'category': instance.category,
      'rating': instance.rating,
      'delivery_time_minutes': instance.deliveryTimeMinutes,
      'delivery_fee': instance.deliveryFee,
      'is_open': instance.isOpen,
      'is_favorite': instance.isFavorite,
    };
