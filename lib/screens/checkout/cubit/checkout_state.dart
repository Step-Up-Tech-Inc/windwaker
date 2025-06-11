import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/models/cart_item.dart';

part 'checkout_state.freezed.dart';

enum PaymentMethod { card, mobilePayment, cash }

@freezed
class CheckoutState with _$CheckoutState {
  const factory CheckoutState({
    @Default(false) bool isLoading,
    @Default(null) String? error,
    @Default([]) List<CartItem> cartItems,
    @Default('') String address,
    @Default('') String addressNickname,
    @Default('Casa') String addressType,
    @Default('') String deliveryInstructions,
    @Default(false) bool saveAddress,
    @Default(PaymentMethod.card) PaymentMethod paymentMethod,
    @Default(false) bool savePaymentMethod,
    @Default(0.0) double subtotal,
    @Default(0.0) double tax,
    @Default(0.0) double deliveryCost,
    @Default(0.0) double discount,
    @Default(0.0) double total,
    @Default(2) int currentStep,
    @Default(3) int totalSteps,
    @Default(false) bool orderPlaced,
    @Default('') String orderConfirmationId,
    @Default('') String estimatedDeliveryTime,
    @Default('') String storeName,
  }) = _CheckoutState;
}
