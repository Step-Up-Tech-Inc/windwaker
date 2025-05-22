import 'package:freezed_annotation/freezed_annotation.dart';

part 'store.freezed.dart';
part 'store.g.dart';

@freezed
class Store with _$Store {
  const factory Store({
    required String id,
    required String name,
    required String description,
    required String imageUrl,
    required String category,
    required double rating,
    required int deliveryTimeMinutes,
    required double deliveryFee,
    required bool isOpen,
    @Default(false) bool isFavorite,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
}
