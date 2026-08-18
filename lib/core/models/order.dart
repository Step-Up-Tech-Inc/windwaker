// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_item.dart';

part 'order.freezed.dart';
part 'order.g.dart';

/// Estados del pedido. Las transiciones se validan en el servidor
/// (RPC `advance_order_status`); el cliente solo las solicita.
enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('preparing')
  preparing,
  @JsonValue('ready')
  ready,
  @JsonValue('picked_up')
  pickedUp,
  @JsonValue('delivered')
  delivered,
  @JsonValue('rejected')
  rejected,
  @JsonValue('cancelled')
  cancelled,
}

enum DeliveryMethod {
  @JsonValue('delivery')
  delivery,
  @JsonValue('pickup')
  pickup,
}

enum OrderPaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('sinpe')
  sinpe,
}

/// Estado del pago SINPE. `notRequired` aplica a pedidos en efectivo.
enum PaymentStatus {
  @JsonValue('not_required')
  notRequired,
  @JsonValue('pending')
  pending,
  @JsonValue('submitted')
  submitted,
  @JsonValue('verified')
  verified,
  @JsonValue('rejected')
  rejected,
}

/// Pedido (tabla `orders` de Supabase).
@freezed
class Order with _$Order {
  const Order._();

  const factory Order({
    required String id,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'store_id') required String storeId,
    @JsonKey(name: 'driver_id') String? driverId,
    @Default(OrderStatus.pending) OrderStatus status,
    @JsonKey(name: 'delivery_method')
    @Default(DeliveryMethod.delivery)
    DeliveryMethod deliveryMethod,
    @JsonKey(name: 'payment_method')
    @Default(OrderPaymentMethod.cash)
    OrderPaymentMethod paymentMethod,
    @JsonKey(name: 'address_label') String? addressLabel,
    @JsonKey(name: 'address_detail') String? addressDetail,
    double? latitude,
    double? longitude,
    required double subtotal,
    @JsonKey(name: 'delivery_fee') @Default(0) double deliveryFee,
    required double total,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'payment_status')
    @Default(PaymentStatus.notRequired)
    PaymentStatus paymentStatus,
    @JsonKey(name: 'payment_reference') String? paymentReference,
    @JsonKey(name: 'payment_proof_path') String? paymentProofPath,
    /// Poblado por el repositorio desde el join `order_items(*)`.
    @Default([]) List<OrderItem> items,
    /// Poblado por el repositorio desde el join `stores(...)`.
    @JsonKey(name: 'store_name') String? storeName,
    @JsonKey(name: 'store_sinpe_number') String? storeSinpeNumber,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  /// Estados terminales: el pedido ya no cambia.
  bool get isFinal =>
      status == OrderStatus.delivered ||
      status == OrderStatus.rejected ||
      status == OrderStatus.cancelled;

  bool get isActive => !isFinal;
}

/// Cambio de estado registrado en `order_status_history`.
class OrderStatusChange {
  final OrderStatus status;
  final DateTime createdAt;

  const OrderStatusChange({required this.status, required this.createdAt});

  factory OrderStatusChange.fromJson(Map<String, dynamic> json) =>
      OrderStatusChange(
        status: orderStatusFromWire(json['status'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

const Map<OrderStatus, String> _statusWire = {
  OrderStatus.pending: 'pending',
  OrderStatus.accepted: 'accepted',
  OrderStatus.preparing: 'preparing',
  OrderStatus.ready: 'ready',
  OrderStatus.pickedUp: 'picked_up',
  OrderStatus.delivered: 'delivered',
  OrderStatus.rejected: 'rejected',
  OrderStatus.cancelled: 'cancelled',
};

OrderStatus orderStatusFromWire(String value) =>
    _statusWire.entries
        .firstWhere(
          (e) => e.value == value,
          orElse: () => throw ArgumentError('Estado desconocido: $value'),
        )
        .key;

extension OrderStatusX on OrderStatus {
  /// Valor tal como lo espera la base de datos.
  String get wire => _statusWire[this]!;

  /// Etiqueta para mostrar al usuario.
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Esperando confirmación';
      case OrderStatus.accepted:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'En preparación';
      case OrderStatus.ready:
        return 'Listo para recoger';
      case OrderStatus.pickedUp:
        return 'En camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.rejected:
        return 'Rechazado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
}

extension DeliveryMethodX on DeliveryMethod {
  String get wire => this == DeliveryMethod.delivery ? 'delivery' : 'pickup';
}

extension OrderPaymentMethodX on OrderPaymentMethod {
  String get wire => this == OrderPaymentMethod.cash ? 'cash' : 'sinpe';
}
