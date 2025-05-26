import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

enum ProductStatus {
  @JsonValue(0)
  available,
  @JsonValue(1)
  lowStock,
  @JsonValue(2)
  outOfStock,
}

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String description,
    required String imageUrl,
    required String category,
    required double price,
    required String unit,
    required double quantity,
    required String storeId,
    @Default(ProductStatus.available) ProductStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
