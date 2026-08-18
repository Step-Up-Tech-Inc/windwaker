import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

/// Repositorio de pedidos sobre Supabase.
///
/// Las escrituras pasan por RPCs SECURITY DEFINER (`create_order`,
/// `advance_order_status`) que validan precios y máquina de estados en el
/// servidor; este repositorio nunca muta la tabla directamente.
class OrderRepository {
  final SupabaseClient _supabase;
  final _logger = Logger();

  OrderRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  static const List<String> _activeStatuses = [
    'pending',
    'accepted',
    'preparing',
    'ready',
    'picked_up',
  ];

  static const String _selectWithDetails =
      '*, order_items(*), stores(name, sinpe_number)';

  /// Crea el pedido vía RPC. El servidor calcula precios y totales a partir
  /// de los productos; aquí solo se mandan ids y cantidades.
  Future<String> createOrder({
    required String storeId,
    required DeliveryMethod deliveryMethod,
    required OrderPaymentMethod paymentMethod,
    required List<CartItem> items,
    String? addressLabel,
    String? addressDetail,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final orderId = await _supabase.rpc(
      'create_order',
      params: {
        'p_store_id': storeId,
        'p_delivery_method': deliveryMethod.wire,
        'p_payment_method': paymentMethod.wire,
        'p_address_label': addressLabel,
        'p_address_detail': addressDetail,
        'p_latitude': latitude,
        'p_longitude': longitude,
        'p_notes': notes,
        'p_items': [
          for (final item in items)
            {'product_id': item.productId, 'quantity': item.quantity.round()},
        ],
      },
    );
    _logger.i('✅ Pedido creado: $orderId');
    return orderId as String;
  }

  Future<Order?> getOrderById(String id) async {
    final row =
        await _supabase
            .from('orders')
            .select(_selectWithDetails)
            .eq('id', id)
            .maybeSingle();
    return row == null ? null : _mapRow(row);
  }

  /// Pedido activo más reciente del usuario autenticado (si existe).
  Future<Order?> getActiveOrderForCurrentUser() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return null;

    final rows = await _supabase
        .from('orders')
        .select(_selectWithDetails)
        .eq('customer_id', uid)
        .inFilter('status', _activeStatuses)
        .order('created_at', ascending: false)
        .limit(1);
    return rows.isEmpty ? null : _mapRow(rows.first);
  }

  /// Historial de pedidos del usuario autenticado.
  Future<List<Order>> getMyOrders({int limit = 20}) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return const [];

    final rows = await _supabase
        .from('orders')
        .select(_selectWithDetails)
        .eq('customer_id', uid)
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map(_mapRow).toList();
  }

  /// Stream del pedido vía Supabase Realtime. Los streams no soportan joins,
  /// así que items y nombre de tienda se cargan una vez y se conservan
  /// (no cambian durante la vida del pedido).
  Stream<Order?> watchOrder(String id) async* {
    final base = await getOrderById(id);
    yield base;
    if (base == null) return;

    yield* _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((rows) {
          if (rows.isEmpty) return base;
          final updated = Order.fromJson(Map<String, dynamic>.from(rows.first));
          return updated.copyWith(items: base.items, storeName: base.storeName);
        });
  }

  /// Solicita una transición de estado (el servidor decide si es válida).
  Future<void> advanceStatus(String orderId, OrderStatus newStatus) async {
    await _supabase.rpc(
      'advance_order_status',
      params: {'p_order_id': orderId, 'p_new_status': newStatus.wire},
    );
  }

  Future<void> cancelOrder(String orderId) =>
      advanceStatus(orderId, OrderStatus.cancelled);

  /// Línea de tiempo real del pedido (tabla `order_status_history`).
  Future<List<OrderStatusChange>> getStatusHistory(String orderId) async {
    final rows = await _supabase
        .from('order_status_history')
        .select('status, created_at')
        .eq('order_id', orderId)
        .order('created_at', ascending: true);
    return rows.map(OrderStatusChange.fromJson).toList();
  }

  /// Sube el comprobante SINPE al bucket privado y lo registra en el pedido
  /// vía RPC (queda `submitted`, pendiente de revisión del negocio).
  Future<void> submitPaymentProof({
    required String orderId,
    required List<int> imageBytes,
    required String fileName,
    required String reference,
  }) async {
    final path = '$orderId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _supabase.storage
        .from('payment-proofs')
        .uploadBinary(
          path,
          Uint8List.fromList(imageBytes),
          fileOptions: const FileOptions(upsert: true),
        );
    await _supabase.rpc(
      'submit_payment_proof',
      params: {
        'p_order_id': orderId,
        'p_proof_path': path,
        'p_reference': reference,
      },
    );
  }

  /// URL firmada (temporal) para ver un comprobante del bucket privado.
  /// El RLS del bucket limita quién puede generarla.
  Future<String> getPaymentProofUrl(String proofPath) {
    return _supabase.storage
        .from('payment-proofs')
        .createSignedUrl(proofPath, 300);
  }

  /// El negocio (o un admin) aprueba o rechaza el comprobante.
  Future<void> reviewSinpePayment({
    required String orderId,
    required bool approved,
  }) async {
    await _supabase.rpc(
      'review_sinpe_payment',
      params: {'p_order_id': orderId, 'p_approved': approved},
    );
  }

  /// Normaliza la fila con joins de PostgREST al formato del modelo.
  Order _mapRow(Map<String, dynamic> row) {
    final json = Map<String, dynamic>.from(row);
    json['items'] = json.remove('order_items') ?? const [];
    final store = json.remove('stores');
    if (store is Map) {
      if (store['name'] != null) json['store_name'] = store['name'];
      if (store['sinpe_number'] != null) {
        json['store_sinpe_number'] = store['sinpe_number'];
      }
    }
    return Order.fromJson(json);
  }
}
