import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';

/// Operaciones del repartidor. El RLS deja ver pedidos `ready` sin asignar
/// y los propios; `claim_order` garantiza asignación atómica.
class DriverRepository {
  final SupabaseClient _supabase;

  DriverRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  static const String _select = '*, order_items(*), stores(name)';

  Order _mapRow(Map<String, dynamic> row) {
    final json = Map<String, dynamic>.from(row);
    json['items'] = json.remove('order_items') ?? const [];
    final store = json.remove('stores');
    if (store is Map && store['name'] != null) {
      json['store_name'] = store['name'];
    }
    return Order.fromJson(json);
  }

  /// Pedidos listos para recoger, sin repartidor asignado.
  Future<List<Order>> getAvailableOrders() async {
    final rows = await _supabase
        .from('orders')
        .select(_select)
        .eq('status', 'ready')
        .isFilter('driver_id', null)
        .eq('delivery_method', 'delivery')
        .order('created_at', ascending: true);
    return rows.map(_mapRow).toList();
  }

  /// Entrega activa del repartidor (ready ya asignada o picked_up).
  Future<Order?> getActiveDelivery() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return null;
    final rows = await _supabase
        .from('orders')
        .select(_select)
        .eq('driver_id', uid)
        .inFilter('status', ['ready', 'picked_up'])
        .limit(1);
    return rows.isEmpty ? null : _mapRow(rows.first);
  }

  /// Entregas completadas por el repartidor.
  Future<List<Order>> getDeliveryHistory({int limit = 30}) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return const [];
    final rows = await _supabase
        .from('orders')
        .select(_select)
        .eq('driver_id', uid)
        .eq('status', 'delivered')
        .order('updated_at', ascending: false)
        .limit(limit);
    return rows.map(_mapRow).toList();
  }

  /// Asignación atómica: devuelve false si otro repartidor lo tomó primero.
  Future<bool> claimOrder(String orderId) async {
    final result = await _supabase.rpc(
      'claim_order',
      params: {'p_order_id': orderId},
    );
    return result as bool;
  }

  /// Señal de cambios en pedidos visibles para el repartidor (Realtime).
  Stream<void> watchOrderChanges() {
    return _supabase.from('orders').stream(primaryKey: ['id']).map((_) {});
  }
}
