import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class OrderRepository {
  static const String _activeOrderKey = 'active_order';

  // Guardar el pedido activo
  Future<void> saveActiveOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final orderJson = jsonEncode(order.toJson());
    await prefs.setString(_activeOrderKey, orderJson);
  }

  // Obtener el pedido activo
  Future<Order?> getActiveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final orderJson = prefs.getString(_activeOrderKey);

    if (orderJson == null) {
      return null;
    }

    try {
      final orderMap = jsonDecode(orderJson) as Map<String, dynamic>;
      return Order.fromJson(orderMap);
    } catch (e) {
      // Si hay un error al decodificar, eliminar el pedido
      await clearActiveOrder();
      return null;
    }
  }

  // Actualizar el estado del pedido
  Future<void> updateOrderStatus(OrderStatus status) async {
    final activeOrder = await getActiveOrder();

    if (activeOrder != null) {
      final updatedOrder = activeOrder.copyWith(status: status);
      await saveActiveOrder(updatedOrder);
    }
  }

  // Eliminar el pedido activo
  Future<void> clearActiveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeOrderKey);
  }

  // Verificar si hay un pedido activo
  Future<bool> hasActiveOrder() async {
    final order = await getActiveOrder();
    return order != null && order.status != OrderStatus.delivered;
  }
}
