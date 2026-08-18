import 'package:windwaker/core/models/order.dart';

/// Pedidos del negocio agrupados para las pestañas del panel.
typedef GroupedBusinessOrders = ({
  List<Order> nuevos,
  List<Order> enCurso,
  List<Order> historial,
});

/// Agrupa los pedidos: nuevos (pending), en curso (accepted/preparing/ready/
/// picked_up) e historial (delivered/rejected/cancelled). Función pura.
GroupedBusinessOrders groupOrdersForBusiness(List<Order> orders) {
  final nuevos = <Order>[];
  final enCurso = <Order>[];
  final historial = <Order>[];

  for (final order in orders) {
    switch (order.status) {
      case OrderStatus.pending:
        nuevos.add(order);
      case OrderStatus.accepted:
      case OrderStatus.preparing:
      case OrderStatus.ready:
      case OrderStatus.pickedUp:
        enCurso.add(order);
      case OrderStatus.delivered:
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        historial.add(order);
    }
  }

  return (nuevos: nuevos, enCurso: enCurso, historial: historial);
}
