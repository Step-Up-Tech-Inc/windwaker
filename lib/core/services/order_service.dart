import '../models/cart_item.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';

/// Fachada de pedidos para la UI. Delega en [OrderRepository]; el servidor
/// (RPCs de Supabase) es quien valida precios y transiciones de estado.
class OrderService {
  final OrderRepository _orderRepository;

  OrderService(this._orderRepository);

  /// Crea el pedido y lo devuelve ya cargado desde la base de datos
  /// (con totales calculados por el servidor).
  Future<Order> createOrder({
    required String storeId,
    required DeliveryMethod deliveryMethod,
    required OrderPaymentMethod paymentMethod,
    required List<CartItem> items,
    String? addressLabel,
    String? addressDetail,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final orderId = await _orderRepository.createOrder(
      storeId: storeId,
      deliveryMethod: deliveryMethod,
      paymentMethod: paymentMethod,
      items: items,
      addressLabel: addressLabel,
      addressDetail: addressDetail,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
    );

    final order = await _orderRepository.getOrderById(orderId);
    if (order == null) {
      throw StateError('El pedido $orderId no se pudo cargar tras crearse');
    }
    return order;
  }

  Future<Order?> getActiveOrder() =>
      _orderRepository.getActiveOrderForCurrentUser();

  Future<bool> hasActiveOrder() async => (await getActiveOrder()) != null;

  Future<List<Order>> getOrderHistory({int limit = 20}) =>
      _orderRepository.getMyOrders(limit: limit);

  Stream<Order?> watchOrder(String orderId) =>
      _orderRepository.watchOrder(orderId);

  Future<List<OrderStatusChange>> getStatusHistory(String orderId) =>
      _orderRepository.getStatusHistory(orderId);

  Future<void> cancelOrder(String orderId) =>
      _orderRepository.cancelOrder(orderId);

  /// Sube el comprobante SINPE del cliente (queda pendiente de revisión).
  Future<void> submitPaymentProof({
    required String orderId,
    required List<int> imageBytes,
    required String fileName,
    required String reference,
  }) => _orderRepository.submitPaymentProof(
    orderId: orderId,
    imageBytes: imageBytes,
    fileName: fileName,
    reference: reference,
  );

  /// URL firmada temporal del comprobante (bucket privado).
  Future<String> getPaymentProofUrl(String proofPath) =>
      _orderRepository.getPaymentProofUrl(proofPath);

  /// El negocio aprueba o rechaza el pago SINPE.
  Future<void> reviewSinpePayment({
    required String orderId,
    required bool approved,
  }) => _orderRepository.reviewSinpePayment(
    orderId: orderId,
    approved: approved,
  );
}
