// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item.freezed.dart';
part 'order_item.g.dart';

/// Línea de un pedido (tabla `order_items`). Guarda snapshot de nombre y
/// precio: el historial no cambia aunque el negocio edite su menú.
@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'product_name') required String productName,
    @JsonKey(name: 'unit_price') required double unitPrice,
    required int quantity,
    String? notes,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}
