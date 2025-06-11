import 'dart:math';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';

class OrderService {
  final OrderRepository _orderRepository;

  OrderService(this._orderRepository);

  // Crear un nuevo pedido
  Future<Order> createOrder({
    required String restaurantName,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double deliveryCost,
    required double discount,
    required double total,
  }) async {
    // Generar un ID único para el pedido
    final orderId =
        'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    // Calcular tiempo estimado de entrega (entre 15 y 40 minutos)
    final estimatedDeliveryTime = 15 + Random().nextInt(25);

    // Calcular hora estimada de llegada
    final now = DateTime.now();
    final estimatedArrival = now.add(Duration(minutes: estimatedDeliveryTime));

    // Crear el pedido
    final order = Order(
      id: orderId,
      restaurantName: restaurantName,
      items: items,
      subtotal: subtotal,
      tax: tax,
      deliveryCost: deliveryCost,
      discount: discount,
      total: total,
      estimatedDeliveryTime: estimatedDeliveryTime,
      createdAt: now,
      estimatedArrival: estimatedArrival,
      status: OrderStatus.confirmed,
    );

    // Guardar el pedido en el repositorio
    await _orderRepository.saveActiveOrder(order);

    // Simular cambio de estado después de un tiempo
    _simulateOrderProgress(order);

    return order;
  }

  // Obtener el pedido activo
  Future<Order?> getActiveOrder() {
    return _orderRepository.getActiveOrder();
  }

  // Actualizar el estado del pedido
  Future<void> updateOrderStatus(OrderStatus status) {
    return _orderRepository.updateOrderStatus(status);
  }

  // Verificar si hay un pedido activo
  Future<bool> hasActiveOrder() {
    return _orderRepository.hasActiveOrder();
  }

  // Cancelar el pedido activo
  Future<void> cancelOrder() {
    return _orderRepository.clearActiveOrder();
  }

  // Marcar el pedido como entregado
  Future<void> markOrderAsDelivered() {
    return _orderRepository.updateOrderStatus(OrderStatus.delivered);
  }

  // Simular el progreso del pedido
  void _simulateOrderProgress(Order order) {
    // Cambiar a "en preparación" después de 1-2 minutos
    Future.delayed(Duration(minutes: 1), () {
      _orderRepository.updateOrderStatus(OrderStatus.inProgress);

      // Cambiar a "en camino" después de 2-3 minutos más
      Future.delayed(Duration(minutes: 2), () {
        _orderRepository.updateOrderStatus(OrderStatus.onTheWay);

        // Cambiar a "entregado" después del tiempo estimado
        final remainingTime = order.estimatedDeliveryTime - 3;
        if (remainingTime > 0) {
          Future.delayed(Duration(minutes: remainingTime), () {
            _orderRepository.updateOrderStatus(OrderStatus.delivered);
          });
        }
      });
    });
  }
}
