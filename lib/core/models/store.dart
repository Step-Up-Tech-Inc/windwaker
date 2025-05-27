import 'package:freezed_annotation/freezed_annotation.dart';

part 'store.freezed.dart';
part 'store.g.dart';

@freezed
class Store with _$Store {
  factory Store({
    required String id,
    required String name,
    required String description,
    @JsonKey(name: 'image_url') required String imageUrl,
    required String category,
    required double rating,
    @JsonKey(name: 'delivery_time_minutes') required int deliveryTimeMinutes,
    @JsonKey(name: 'delivery_fee') required double deliveryFee,
    @JsonKey(name: 'is_open') required bool isOpen,
    @Default(false) bool isFavorite,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
}
