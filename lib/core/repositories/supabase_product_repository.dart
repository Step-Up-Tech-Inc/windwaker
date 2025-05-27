import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import '../models/product.dart';
import '../models/inventory.dart';
import 'product_repository_interface.dart';

class SupabaseProductRepository implements ProductRepositoryInterface {
  final SupabaseClient _supabaseClient;
  final _uuid = const Uuid();
  final _logger = Logger();

  SupabaseProductRepository(this._supabaseClient);

  // Obtener productos por tienda desde Supabase
  @override
  Future<List<Product>> getProductsByStore(String storeId) async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select()
          .eq('store_id', storeId)
          .eq('is_deleted', false)
          .order('created_at');

      return (response as List)
          .map(
            (json) => Product.fromJson({
              ...json,
              'status': json['status'] as int, // Convertir a enum
            }),
          )
          .toList();
    } catch (e) {
      _logger.e('Error al obtener productos por tienda: $e');
      // En caso de error, devolvemos una lista vacía y nos aseguramos de manejar el error
      return [];
    }
  }

  // Obtener productos por categoría para una tienda específica
  @override
  Future<List<Product>> getProductsByCategory(
    String storeId,
    String category,
  ) async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select()
          .eq('store_id', storeId)
          .eq('category', category)
          .eq('is_deleted', false)
          .order('created_at');

      return (response as List)
          .map(
            (json) => Product.fromJson({
              ...json,
              'status': json['status'] as int, // Convertir a enum
            }),
          )
          .toList();
    } catch (e) {
      _logger.e('Error al obtener productos por categoría: $e');
      return [];
    }
  }

  // Obtener inventario de un producto
  @override
  Future<Inventory?> getProductInventory(String productId) async {
    try {
      final response =
          await _supabaseClient
              .from('inventory')
              .select()
              .eq('product_id', productId)
              .eq('is_deleted', false)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return Inventory.fromJson(response);
    } catch (e) {
      _logger.e('Error al obtener inventario: $e');
      return null;
    }
  }

  // Añadir un producto a Supabase
  @override
  Future<Product> addProduct(Product product) async {
    try {
      final now = DateTime.now();
      final newProduct = product.copyWith(
        id: _uuid.v4(),
        createdAt: now,
        updatedAt: now,
      );

      final response =
          await _supabaseClient
              .from('products')
              .insert({
                'id': newProduct.id,
                'name': newProduct.name,
                'description': newProduct.description,
                'image_url': newProduct.imageUrl,
                'category': newProduct.category,
                'price': newProduct.price,
                'unit': newProduct.unit,
                'quantity': newProduct.quantity,
                'store_id': newProduct.storeId,
                'status': newProduct.status.index,
                'created_at': newProduct.createdAt?.toIso8601String(),
                'updated_at': newProduct.updatedAt?.toIso8601String(),
                'is_deleted': newProduct.isDeleted,
              })
              .select()
              .single();

      return Product.fromJson({
        ...response,
        'status': response['status'] as int, // Convertir a enum
      });
    } catch (e) {
      _logger.e('Error al añadir producto: $e');
      throw Exception('No se pudo añadir el producto: $e');
    }
  }

  // Actualizar un producto en Supabase
  @override
  Future<Product> updateProduct(Product product) async {
    try {
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());

      final response =
          await _supabaseClient
              .from('products')
              .update({
                'name': updatedProduct.name,
                'description': updatedProduct.description,
                'image_url': updatedProduct.imageUrl,
                'category': updatedProduct.category,
                'price': updatedProduct.price,
                'unit': updatedProduct.unit,
                'quantity': updatedProduct.quantity,
                'status': updatedProduct.status.index,
                'updated_at': updatedProduct.updatedAt?.toIso8601String(),
              })
              .eq('id', product.id)
              .select()
              .single();

      return Product.fromJson({
        ...response,
        'status': response['status'] as int, // Convertir a enum
      });
    } catch (e) {
      _logger.e('Error al actualizar producto: $e');
      throw Exception('No se pudo actualizar el producto: $e');
    }
  }

  // Eliminar un producto de forma lógica en Supabase
  @override
  Future<bool> deleteProduct(String productId) async {
    try {
      await _supabaseClient
          .from('products')
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', productId);

      return true;
    } catch (e) {
      _logger.e('Error al eliminar producto: $e');
      return false;
    }
  }

  // Crear datos de ejemplo de productos en Supabase
  @override
  Future<void> seedSampleData() async {
    // Este método ya no crea datos de ejemplo, ya que debemos usar los datos reales de Supabase
    _logger.i(
      'Usando exclusivamente datos reales de Supabase, no se crearán datos de muestra',
    );
    return;
  }
}
