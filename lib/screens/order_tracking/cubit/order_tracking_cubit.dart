import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:windwaker/core/models/order.dart';
import 'package:windwaker/core/models/order_tracking_status.dart';
import 'package:windwaker/core/services/order_service.dart';
import 'package:windwaker/screens/order_tracking/order_timeline_builder.dart';

part 'order_tracking_state.dart';
part 'order_tracking_cubit.freezed.dart';

/// Seguimiento de pedido en vivo: se suscribe al stream de Supabase Realtime
/// y reconstruye la línea de tiempo con el historial real de estados.
class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  final OrderService _orderService;
  StreamSubscription<Order?>? _subscription;

  OrderTrackingCubit({OrderService? orderService})
    : _orderService = orderService ?? GetIt.I<OrderService>(),
      super(const OrderTrackingState.initial());

  Future<void> loadOrderTracking(String orderId) async {
    emit(const OrderTrackingState.loading());

    await _subscription?.cancel();
    _subscription = _orderService
        .watchOrder(orderId)
        .listen(
          _onOrderChanged,
          onError: (Object e) {
            emit(
              OrderTrackingState.error('Error al cargar el pedido: $e'),
            );
          },
        );
  }

  Future<void> _onOrderChanged(Order? order) async {
    if (order == null) {
      emit(const OrderTrackingState.noOrder());
      return;
    }

    if (order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.rejected) {
      emit(
        OrderTrackingState.orderCancelled(
          orderId: order.id,
          reason:
              order.status == OrderStatus.rejected
                  ? 'El negocio rechazó el pedido'
                  : 'El pedido fue cancelado',
        ),
      );
      return;
    }

    if (order.status == OrderStatus.delivered) {
      emit(
        OrderTrackingState.orderDelivered(
          orderId: order.id,
          deliveryTime: order.updatedAt ?? DateTime.now(),
        ),
      );
      return;
    }

    try {
      final history = await _orderService.getStatusHistory(order.id);
      if (isClosed) return;

      emit(
        OrderTrackingState.loaded(
          orderId: order.id,
          timeline: buildOrderTimeline(history),
          address: order.addressDetail ?? 'Recoger en la tienda',
          estimatedTime: order.status.label,
          deliveryPerson:
              order.driverId == null
                  ? 'Aún sin repartidor asignado'
                  : 'Repartidor asignado',
          products: [
            for (final item in order.items)
              OrderProductSummary(
                name: item.productName,
                quantity: item.quantity,
                price: item.unitPrice.toInt(),
              ),
          ],
          subtotal: order.subtotal.toInt(),
          order: order,
        ),
      );
    } catch (e) {
      if (!isClosed) {
        emit(OrderTrackingState.error('Error al cargar el pedido: $e'));
      }
    }
  }

  /// Cancela el pedido (solo válido mientras está pendiente; lo valida el
  /// servidor). El stream emitirá el estado cancelado.
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _orderService.cancelOrder(orderId);
    } catch (e) {
      emit(OrderTrackingState.error('No se pudo cancelar el pedido: $e'));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
