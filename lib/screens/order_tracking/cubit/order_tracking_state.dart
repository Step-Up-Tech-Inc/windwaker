part of 'order_tracking_cubit.dart';

@freezed
class OrderTrackingState with _$OrderTrackingState {
  const factory OrderTrackingState.initial() = _Initial;
  const factory OrderTrackingState.loading() = _Loading;
  const factory OrderTrackingState.loaded({
    required String orderId,
    required List<OrderTrackingStatus> timeline,
    required String address,
    required String estimatedTime,
    required String deliveryPerson,
    required List<OrderProductSummary> products,
    required int subtotal,
  }) = _Loaded;
  const factory OrderTrackingState.error(String message) = _Error;
  const factory OrderTrackingState.noOrder() = _NoOrder;
  const factory OrderTrackingState.orderCancelled({
    required String orderId,
    required String reason,
  }) = _OrderCancelled;
  const factory OrderTrackingState.orderDelivered({
    required String orderId,
    required DateTime deliveryTime,
  }) = _OrderDelivered;
}

@freezed
class OrderProductSummary with _$OrderProductSummary {
  const factory OrderProductSummary({
    required String name,
    required int quantity,
    required int price,
    String? imageUrl,
  }) = _OrderProductSummary;
}
