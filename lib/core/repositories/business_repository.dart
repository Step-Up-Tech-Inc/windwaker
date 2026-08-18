import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';

/// Producto visto por el dueño del negocio (tabla `products`).
/// `status`: 0 = disponible, 1 = agotado.
class BusinessProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isAvailable;

  const BusinessProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.isAvailable,
  });

  factory BusinessProduct.fromJson(Map<String, dynamic> json) =>
      BusinessProduct(
        id: json['id'] as String,
        name: json['name'] as String,
        description: (json['description'] as String?) ?? '',
        price: ((json['price'] as num?) ?? 0).toDouble(),
        category: (json['category'] as String?) ?? 'General',
        imageUrl: (json['image_url'] as String?) ?? '',
        isAvailable: ((json['status'] as num?) ?? 0) == 0,
      );
}

/// Tienda vista por su dueño (subconjunto de la tabla `stores`).
class BusinessStore {
  final String id;
  final String name;
  final String description;
  final String category;
  final bool isOpen;
  final double deliveryFee;
  final int deliveryTimeMinutes;

  /// 'pending' | 'approved' | 'rejected' — un admin aprueba la tienda
  /// antes de que pueda vender.
  final String status;

  /// Número SINPE Móvil al que el negocio recibe los pagos.
  final String? sinpeNumber;

  const BusinessStore({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.isOpen,
    required this.deliveryFee,
    required this.deliveryTimeMinutes,
    this.status = 'pending',
    this.sinpeNumber,
  });

  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory BusinessStore.fromJson(Map<String, dynamic> json) => BusinessStore(
        id: json['id'] as String,
        name: json['name'] as String,
        description: (json['description'] as String?) ?? '',
        category: (json['category'] as String?) ?? 'Otro',
        isOpen: (json['is_open'] as bool?) ?? true,
        deliveryFee: ((json['delivery_fee'] as num?) ?? 0).toDouble(),
        deliveryTimeMinutes:
            ((json['delivery_time_minutes'] as num?) ?? 30).toInt(),
        status: (json['status'] as String?) ?? 'pending',
        sinpeNumber: json['sinpe_number'] as String?,
      );

  BusinessStore copyWith({bool? isOpen, String? sinpeNumber}) => BusinessStore(
        id: id,
        name: name,
        description: description,
        category: category,
        isOpen: isOpen ?? this.isOpen,
        deliveryFee: deliveryFee,
        deliveryTimeMinutes: deliveryTimeMinutes,
        status: status,
        sinpeNumber: sinpeNumber ?? this.sinpeNumber,
      );
}

/// Operaciones del dueño del negocio. El RLS de `stores` exige rol
/// `business` y `owner_id = auth.uid()` para escribir.
class BusinessRepository {
  final SupabaseClient _supabase;

  BusinessRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  /// Tienda del usuario autenticado (o null si aún no la creó).
  Future<BusinessStore?> getMyStore() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return null;

    final row =
        await _supabase
            .from('stores')
            .select()
            .eq('owner_id', uid)
            .eq('is_deleted', false)
            .maybeSingle();
    return row == null ? null : BusinessStore.fromJson(row);
  }

  /// Crea la tienda del negocio (onboarding).
  Future<BusinessStore> createStore({
    required String name,
    required String description,
    required String category,
    required double deliveryFee,
    required int deliveryTimeMinutes,
    String imageUrl = '',
  }) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('No hay usuario autenticado');
    }

    final row =
        await _supabase
            .from('stores')
            .insert({
              'owner_id': uid,
              'name': name,
              'description': description,
              'image_url': imageUrl,
              'category': category,
              'delivery_fee': deliveryFee,
              'delivery_time_minutes': deliveryTimeMinutes,
              'is_open': true,
            })
            .select()
            .single();
    return BusinessStore.fromJson(row);
  }

  /// Sube el logo de la tienda y devuelve su URL pública. Se guarda por
  /// dueño (aún puede no existir la tienda durante el onboarding).
  Future<String> uploadStoreImage({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('No hay usuario autenticado');
    }
    final path =
        'stores/$uid/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _supabase.storage
        .from('store-images')
        .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
    return _supabase.storage.from('store-images').getPublicUrl(path);
  }

  /// Actualiza el logo de una tienda existente.
  Future<void> setStoreImage(String storeId, String imageUrl) async {
    await _supabase
        .from('stores')
        .update({'image_url': imageUrl})
        .eq('id', storeId);
  }

  /// Abre o cierra la tienda.
  Future<void> setStoreOpen(String storeId, bool isOpen) async {
    await _supabase
        .from('stores')
        .update({'is_open': isOpen})
        .eq('id', storeId);
  }

  /// Configura el número SINPE Móvil donde el negocio recibe pagos.
  Future<void> setSinpeNumber(String storeId, String? sinpeNumber) async {
    await _supabase
        .from('stores')
        .update({'sinpe_number': sinpeNumber})
        .eq('id', storeId);
  }

  /// Pedidos de la tienda con sus líneas, más recientes primero.
  /// El RLS solo permite ver los de la tienda propia.
  Future<List<Order>> getStoreOrders(String storeId, {int limit = 50}) async {
    final rows = await _supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('store_id', storeId)
        .order('created_at', ascending: false)
        .limit(limit);

    return rows.map((row) {
      final json = Map<String, dynamic>.from(row);
      json['items'] = json.remove('order_items') ?? const [];
      return Order.fromJson(json);
    }).toList();
  }

  // ── Menú (productos de la tienda propia; RLS: solo el dueño escribe) ──────

  Future<List<BusinessProduct>> getMyProducts(String storeId) async {
    final rows = await _supabase
        .from('products')
        .select()
        .eq('store_id', storeId)
        .eq('is_deleted', false)
        .order('name');
    return rows.map(BusinessProduct.fromJson).toList();
  }

  Future<void> createProduct({
    required String storeId,
    required String name,
    required String description,
    required double price,
    required String category,
    String imageUrl = '',
  }) async {
    await _supabase.from('products').insert({
      'store_id': storeId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'unit': 'unidad',
      'status': 0,
    });
  }

  Future<void> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required String category,
    String? imageUrl,
  }) async {
    await _supabase
        .from('products')
        .update({
          'name': name,
          'description': description,
          'price': price,
          'category': category,
          if (imageUrl != null) 'image_url': imageUrl,
        })
        .eq('id', productId);
  }

  Future<void> setProductAvailable(String productId, bool available) async {
    await _supabase
        .from('products')
        .update({'status': available ? 0 : 1})
        .eq('id', productId);
  }

  Future<void> deleteProduct(String productId) async {
    await _supabase
        .from('products')
        .update({'is_deleted': true})
        .eq('id', productId);
  }

  /// Sube la foto de un producto al bucket `store-images` y devuelve su URL
  /// pública.
  Future<String> uploadProductImage({
    required String storeId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final path =
        'products/$storeId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _supabase.storage
        .from('store-images')
        .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
    return _supabase.storage.from('store-images').getPublicUrl(path);
  }

  /// Señal de cambios en los pedidos de la tienda (Supabase Realtime).
  /// Los streams no soportan joins: se usa solo como disparador para
  /// volver a consultar [getStoreOrders].
  Stream<void> watchStoreOrderChanges(String storeId) {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('store_id', storeId)
        .map((_) {});
  }
}
