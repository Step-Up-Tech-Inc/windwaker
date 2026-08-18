import 'package:flutter_test/flutter_test.dart';
import 'package:windwaker/core/models/order.dart';
import 'package:windwaker/core/models/order_item.dart';
import 'package:windwaker/screens/business/business_summary.dart';

void main() {
  final now = DateTime(2026, 7, 2, 15);

  Order order({
    required OrderStatus status,
    required DateTime createdAt,
    double total = 1000,
    List<OrderItem> items = const [],
  }) => Order(
        id: 'o-${createdAt.millisecondsSinceEpoch}-$status',
        customerId: 'c',
        storeId: 's',
        status: status,
        subtotal: total,
        total: total,
        createdAt: createdAt,
        items: items,
      );

  OrderItem item(String name, int qty) => OrderItem(
        id: 'i-$name',
        orderId: 'o',
        productId: 'p-$name',
        productName: name,
        unitPrice: 100,
        quantity: qty,
      );

  test('cuenta pedidos de hoy excluyendo cancelados y rechazados', () {
    final summary = summarizeBusinessOrders([
      order(status: OrderStatus.pending, createdAt: now),
      order(status: OrderStatus.delivered, createdAt: now),
      order(status: OrderStatus.cancelled, createdAt: now),
      order(
        status: OrderStatus.delivered,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ], now: now);

    expect(summary.ordersToday, 2);
  });

  test('los ingresos solo cuentan pedidos entregados', () {
    final summary = summarizeBusinessOrders([
      order(status: OrderStatus.delivered, createdAt: now, total: 5000),
      order(status: OrderStatus.pending, createdAt: now, total: 9999),
      order(
        status: OrderStatus.delivered,
        createdAt: now.subtract(const Duration(days: 3)),
        total: 2000,
      ),
      order(
        status: OrderStatus.delivered,
        createdAt: now.subtract(const Duration(days: 10)),
        total: 7000,
      ),
    ], now: now);

    expect(summary.revenueToday, 5000);
    expect(summary.revenueWeek, 7000); // hoy + hace 3 días; el de hace 10 no
  });

  test('ordena los más vendidos por unidades', () {
    final summary = summarizeBusinessOrders([
      order(
        status: OrderStatus.delivered,
        createdAt: now,
        items: [item('Casado', 3), item('Refresco', 1)],
      ),
      order(
        status: OrderStatus.delivered,
        createdAt: now,
        items: [item('Refresco', 5)],
      ),
      order(
        status: OrderStatus.pending,
        createdAt: now,
        items: [item('Pizza', 99)], // no entregado: no cuenta
      ),
    ], now: now);

    expect(summary.topProducts.first.name, 'Refresco');
    expect(summary.topProducts.first.quantity, 6);
    expect(summary.topProducts.map((p) => p.name), isNot(contains('Pizza')));
  });
}
