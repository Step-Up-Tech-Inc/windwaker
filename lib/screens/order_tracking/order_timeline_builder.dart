import 'package:windwaker/core/models/order.dart';
import 'package:windwaker/core/models/order_tracking_status.dart';

/// Construye la línea de tiempo visible del pedido a partir del historial
/// real (`order_status_history`). Función pura para poder testearla.
///
/// Mapeo de estados de BD → pasos de la UI:
///   pending            → processed (pedido recibido)
///   preparing          → preparing
///   ready / picked_up  → onTheWay
///   delivered          → delivered
///   rejected/cancelled → cancelled
List<OrderTrackingStatus> buildOrderTimeline(List<OrderStatusChange> history) {
  final steps = <OrderTrackingStatus>[];

  DateTime? firstTime(OrderStatus status) {
    for (final change in history) {
      if (change.status == status) return change.createdAt;
    }
    return null;
  }

  void addStep(OrderStatusType type, DateTime? time) {
    if (time != null) {
      steps.add(OrderTrackingStatus(status: type, time: time));
    }
  }

  addStep(OrderStatusType.processed, firstTime(OrderStatus.pending));
  addStep(OrderStatusType.preparing, firstTime(OrderStatus.preparing));
  addStep(
    OrderStatusType.onTheWay,
    firstTime(OrderStatus.pickedUp) ?? firstTime(OrderStatus.ready),
  );
  addStep(OrderStatusType.delivered, firstTime(OrderStatus.delivered));
  addStep(
    OrderStatusType.cancelled,
    firstTime(OrderStatus.cancelled) ?? firstTime(OrderStatus.rejected),
  );

  return steps;
}
