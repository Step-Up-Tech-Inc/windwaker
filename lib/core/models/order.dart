import 'package:freezed_annotation/freezed_annotation.dart';
import 'cart_item.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus {
  @JsonValue('CONFIRMED')
  confirmed,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('ON_THE_WAY')
  onTheWay,
  @JsonValue('DELIVERED')
  delivered,
}

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required String restaurantName,
    required List<CartItem> items,
    @Default(OrderStatus.confirmed) OrderStatus status,
    required double subtotal,
    required double tax,
    required double deliveryCost,
    required double discount,
    required double total,
    required int estimatedDeliveryTime,
    required DateTime createdAt,
    DateTime? estimatedArrival,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
