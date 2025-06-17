import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:windwaker/core/models/order_tracking_status.dart';
import 'package:windwaker/core/repositories/order_repository.dart';
import 'package:windwaker/core/models/order.dart';
import 'package:get_it/get_it.dart';

part 'order_tracking_state.dart';
part 'order_tracking_cubit.freezed.dart';

/// Cubit para manejar el estado de seguimiento de pedido.
class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  // ignore: unused_field
  final OrderRepository _orderRepository;

  OrderTrackingCubit({OrderRepository? orderRepository})
    : _orderRepository = orderRepository ?? GetIt.I<OrderRepository>(),
      super(const OrderTrackingState.initial());

  Future<void> loadOrderTracking(String orderId) async {
    emit(const OrderTrackingState.loading());

    try {
      // En el futuro, esto se conectará a la base de datos para obtener datos reales
      // Por ahora, simulamos los datos

      // Ejemplo de cómo se podría implementar con datos reales:
      // final Order? order = await _orderRepository.getOrderById(orderId);
      // if (order != null) {
      //   if (order.status == OrderStatus.delivered) {
      //     emit(OrderTrackingState.orderDelivered(
      //       orderId: order.id,
      //       deliveryTime: order.estimatedArrival ?? DateTime.now(),
      //     ));
      //     return;
      //   }
      //   emit(_buildOrderTrackingState(order));
      // } else {
      //   emit(const OrderTrackingState.noOrder());
      // }

      await Future.delayed(const Duration(seconds: 1));

      // Simulación de datos
      emit(
        OrderTrackingState.loaded(
          orderId: orderId,
          timeline: [
            OrderTrackingStatus(
              status: OrderStatusType.processed,
              time: DateTime.now().subtract(const Duration(minutes: 30)),
              estimated: null,
            ),
            OrderTrackingStatus(
              status: OrderStatusType.preparing,
              time: DateTime.now().subtract(const Duration(minutes: 15)),
              estimated: null,
            ),
            OrderTrackingStatus(
              status: OrderStatusType.onTheWay,
              time: null,
              estimated: '11:15 AM',
            ),
          ],
          address: 'Calle Principal, Tilarán Centro, 50801',
          estimatedTime: '30-35 minutos',
          deliveryPerson: 'Carlos Rodríguez',
          products: [
            OrderProductSummary(
              name: 'Casado Típico',
              quantity: 2,
              price: 9000,
              imageUrl: null,
            ),
            OrderProductSummary(
              name: 'Arroz Tío Pelón',
              quantity: 1,
              price: 2800,
              imageUrl: null,
            ),
          ],
          subtotal: 11800,
        ),
      );
    } catch (e) {
      emit(
        OrderTrackingState.error('Error al cargar el pedido: ${e.toString()}'),
      );
    }
  }

  // Método para marcar un pedido como entregado
  Future<void> markOrderAsDelivered(String orderId) async {
    emit(const OrderTrackingState.loading());

    try {
      // En un caso real, se actualizaría el estado en la base de datos
      // await _orderRepository.updateOrderStatus(orderId, OrderStatus.delivered);

      await Future.delayed(const Duration(seconds: 1));

      emit(
        OrderTrackingState.orderDelivered(
          orderId: orderId,
          deliveryTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(
        OrderTrackingState.error(
          'Error al marcar el pedido como entregado: ${e.toString()}',
        ),
      );
    }
  }

  // Método para cancelar un pedido
  Future<void> cancelOrder(String orderId, String reason) async {
    emit(const OrderTrackingState.loading());

    try {
      // En un caso real, se actualizaría el estado en la base de datos
      // await _orderRepository.cancelOrder(orderId, reason);

      await Future.delayed(const Duration(seconds: 1));

      emit(OrderTrackingState.orderCancelled(orderId: orderId, reason: reason));
    } catch (e) {
      emit(
        OrderTrackingState.error(
          'Error al cancelar el pedido: ${e.toString()}',
        ),
      );
    }
  }

  // Método para construir el estado a partir de un objeto Order
  // Este método se usaría cuando se implemente la conexión real a la base de datos
  // ignore: unused_element
  OrderTrackingState _buildOrderTrackingState(Order order) {
    // Convertir el estado de la orden a la lista de estados de seguimiento
    final List<OrderTrackingStatus> timeline = [];

    // Procesar los estados según el estado actual de la orden
    if (order.status == OrderStatus.confirmed ||
        order.status == OrderStatus.inProgress ||
        order.status == OrderStatus.onTheWay ||
        order.status == OrderStatus.delivered) {
      timeline.add(
        OrderTrackingStatus(
          status: OrderStatusType.processed,
          time: order.createdAt,
          estimated: null,
        ),
      );
    }

    if (order.status == OrderStatus.inProgress ||
        order.status == OrderStatus.onTheWay ||
        order.status == OrderStatus.delivered) {
      timeline.add(
        OrderTrackingStatus(
          status: OrderStatusType.preparing,
          time: order.createdAt.add(const Duration(minutes: 15)),
          estimated: null,
        ),
      );
    }

    if (order.status == OrderStatus.onTheWay ||
        order.status == OrderStatus.delivered) {
      timeline.add(
        OrderTrackingStatus(
          status: OrderStatusType.onTheWay,
          time:
              order.estimatedArrival != null
                  ? null
                  : order.createdAt.add(const Duration(minutes: 30)),
          estimated:
              order.estimatedArrival != null
                  ? '${order.estimatedArrival!.hour}:${order.estimatedArrival!.minute.toString().padLeft(2, '0')} AM'
                  : null,
        ),
      );
    }

    if (order.status == OrderStatus.delivered) {
      timeline.add(
        OrderTrackingStatus(
          status: OrderStatusType.delivered,
          time: order.estimatedArrival ?? DateTime.now(),
          estimated: null,
        ),
      );
    }

    // Convertir los items del carrito a productos para el resumen
    final products =
        order.items
            .map(
              (item) => OrderProductSummary(
                name: item.productName,
                quantity: item.quantity.toInt(),
                price: item.price.toInt(),
                imageUrl: item.imageUrl.isNotEmpty ? item.imageUrl : null,
              ),
            )
            .toList();

    return OrderTrackingState.loaded(
      orderId: order.id,
      timeline: timeline,
      address: 'Dirección de entrega', // Esto vendría de la orden real
      estimatedTime: '${order.estimatedDeliveryTime} minutos',
      deliveryPerson: 'Repartidor asignado', // Esto vendría de la orden real
      products: products,
      subtotal: order.subtotal.toInt(),
    );
  }
}
