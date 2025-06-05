import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/models/cart_item.dart';

part 'cart_screen_state.freezed.dart';

enum DeliveryMethod { delivery, pickup }

@freezed
class CartScreenState with _$CartScreenState {
  const factory CartScreenState({
    @Default(false) bool isLoading,
    @Default(null) String? error,
    @Default([]) List<CartItem> cartItems,
    @Default(0.0) double cartTotal,
    @Default(DeliveryMethod.delivery) DeliveryMethod deliveryMethod,
    @Default(null) String? discountCode,
    @Default(0.0) double deliveryCost,
    @Default(0.0) double subtotal,
    @Default(0.0) double tax,
    @Default(0.0) double discount,
    @Default('') String storeName,
    @Default('') String storeCategory,
    @Default(4.5) double storeRating,
    @Default('20-30 min') String deliveryTime,
  }) = _CartScreenState;
}
