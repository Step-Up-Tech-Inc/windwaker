import 'package:windwaker/core/models/order.dart';

/// Resumen de ventas del negocio. Se calcula sobre pedidos ya cargados
/// (función pura, testeable).
class BusinessSummary {
  final int ordersToday;
  final double revenueToday;
  final double revenueWeek;

  /// Nombre de producto → unidades vendidas (solo entregados), top 5.
  final List<({String name, int quantity})> topProducts;

  const BusinessSummary({
    required this.ordersToday,
    required this.revenueToday,
    required this.revenueWeek,
    required this.topProducts,
  });
}

BusinessSummary summarizeBusinessOrders(List<Order> orders, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final weekAgo = today.subtract(const Duration(days: 6));

  var ordersToday = 0;
  var revenueToday = 0.0;
  var revenueWeek = 0.0;
  final unitsByProduct = <String, int>{};

  for (final order in orders) {
    final created = order.createdAt.toLocal();
    final day = DateTime(created.year, created.month, created.day);

    final isCancelled =
        order.status == OrderStatus.rejected ||
        order.status == OrderStatus.cancelled;
    if (!isCancelled && !day.isBefore(today)) {
      ordersToday++;
    }

    if (order.status == OrderStatus.delivered) {
      if (!day.isBefore(today)) revenueToday += order.total;
      if (!day.isBefore(weekAgo)) revenueWeek += order.total;
      for (final item in order.items) {
        unitsByProduct.update(
          item.productName,
          (v) => v + item.quantity,
          ifAbsent: () => item.quantity,
        );
      }
    }
  }

  final top =
      unitsByProduct.entries
          .map((e) => (name: e.key, quantity: e.value))
          .toList()
        ..sort((a, b) => b.quantity.compareTo(a.quantity));

  return BusinessSummary(
    ordersToday: ordersToday,
    revenueToday: revenueToday,
    revenueWeek: revenueWeek,
    topProducts: top.take(5).toList(),
  );
}
