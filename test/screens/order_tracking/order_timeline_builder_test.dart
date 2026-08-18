import 'package:flutter_test/flutter_test.dart';
import 'package:windwaker/core/models/order.dart';
import 'package:windwaker/core/models/order_tracking_status.dart';
import 'package:windwaker/screens/order_tracking/order_timeline_builder.dart';

void main() {
  OrderStatusChange change(OrderStatus status, int minute) =>
      OrderStatusChange(
        status: status,
        createdAt: DateTime(2026, 7, 1, 12, minute),
      );

  test('pedido recién creado muestra solo el paso recibido', () {
    final timeline = buildOrderTimeline([change(OrderStatus.pending, 0)]);

    expect(timeline, hasLength(1));
    expect(timeline.first.status, OrderStatusType.processed);
    expect(timeline.first.time, DateTime(2026, 7, 1, 12, 0));
  });

  test('pedido en camino muestra recibido, preparando y en camino', () {
    final timeline = buildOrderTimeline([
      change(OrderStatus.pending, 0),
      change(OrderStatus.accepted, 2),
      change(OrderStatus.preparing, 5),
      change(OrderStatus.ready, 20),
      change(OrderStatus.pickedUp, 25),
    ]);

    expect(
      timeline.map((s) => s.status),
      [
        OrderStatusType.processed,
        OrderStatusType.preparing,
        OrderStatusType.onTheWay,
      ],
    );
    // "En camino" usa la hora de picked_up, no la de ready
    expect(timeline.last.time, DateTime(2026, 7, 1, 12, 25));
  });

  test('pedido listo (sin repartidor aún) ya cuenta como en camino', () {
    final timeline = buildOrderTimeline([
      change(OrderStatus.pending, 0),
      change(OrderStatus.preparing, 5),
      change(OrderStatus.ready, 20),
    ]);

    expect(timeline.last.status, OrderStatusType.onTheWay);
    expect(timeline.last.time, DateTime(2026, 7, 1, 12, 20));
  });

  test('pedido entregado incluye los cuatro pasos', () {
    final timeline = buildOrderTimeline([
      change(OrderStatus.pending, 0),
      change(OrderStatus.preparing, 5),
      change(OrderStatus.pickedUp, 25),
      change(OrderStatus.delivered, 40),
    ]);

    expect(
      timeline.map((s) => s.status),
      [
        OrderStatusType.processed,
        OrderStatusType.preparing,
        OrderStatusType.onTheWay,
        OrderStatusType.delivered,
      ],
    );
  });

  test('pedido rechazado termina en cancelado', () {
    final timeline = buildOrderTimeline([
      change(OrderStatus.pending, 0),
      change(OrderStatus.rejected, 3),
    ]);

    expect(timeline.last.status, OrderStatusType.cancelled);
    expect(timeline.last.time, DateTime(2026, 7, 1, 12, 3));
  });
}
