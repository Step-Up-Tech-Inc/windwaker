import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/inventory.dart';
import 'product_repository_interface.dart';

class LocalProductRepository implements ProductRepositoryInterface {
  final SharedPreferences _sharedPreferences;
  final String _localProductsKey = 'local_products';
  final String _localInventoryKey = 'local_inventory';
  final _uuid = const Uuid();

  LocalProductRepository(this._sharedPreferences);

  // Obtener productos por tienda desde el almacenamiento local
  @override
  Future<List<Product>> getProductsByStore(String storeId) async {
    try {
      final productsJson =
          _sharedPreferences.getStringList(_localProductsKey) ?? [];
      final products =
          productsJson
              .map(
                (json) =>
                    Product.fromJson(jsonDecode(json) as Map<String, dynamic>),
              )
              .where(
                (product) => product.storeId == storeId && !product.isDeleted,
              )
              .toList();

      return products;
    } catch (e) {
      return [];
    }
  }

  // Obtener productos por categoría para una tienda específica
  @override
  Future<List<Product>> getProductsByCategory(
    String storeId,
    String category,
  ) async {
    final products = await getProductsByStore(storeId);
    return products.where((product) => product.category == category).toList();
  }

  // Obtener inventario de un producto
  @override
  Future<Inventory?> getProductInventory(String productId) async {
    try {
      final inventoryJson =
          _sharedPreferences.getStringList(_localInventoryKey) ?? [];
      final inventoryList =
          inventoryJson
              .map(
                (json) => Inventory.fromJson(
                  jsonDecode(json) as Map<String, dynamic>,
                ),
              )
              .where((inventory) => !inventory.isDeleted)
              .toList();

      return inventoryList.firstWhere(
        (inventory) => inventory.productId == productId,
        orElse: () => throw Exception('Inventory not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Añadir un producto al almacenamiento local
  @override
  Future<Product> addProduct(Product product) async {
    try {
      final newProduct = product.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final productsJson =
          _sharedPreferences.getStringList(_localProductsKey) ?? [];
      productsJson.add(jsonEncode(newProduct.toJson()));
      await _sharedPreferences.setStringList(_localProductsKey, productsJson);

      return newProduct;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Actualizar un producto en el almacenamiento local
  @override
  Future<Product> updateProduct(Product product) async {
    try {
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());

      final productsJson =
          _sharedPreferences.getStringList(_localProductsKey) ?? [];
      final products =
          productsJson
              .map(
                (json) =>
                    Product.fromJson(jsonDecode(json) as Map<String, dynamic>),
              )
              .toList();

      final index = products.indexWhere((p) => p.id == product.id);
      if (index == -1) {
        throw Exception('Product not found');
      }

      products[index] = updatedProduct;
      final updatedProductsJson =
          products.map((p) => jsonEncode(p.toJson())).toList();
      await _sharedPreferences.setStringList(
        _localProductsKey,
        updatedProductsJson,
      );

      return updatedProduct;
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Eliminar un producto de forma lógica
  @override
  Future<bool> deleteProduct(String productId) async {
    try {
      final productsJson =
          _sharedPreferences.getStringList(_localProductsKey) ?? [];
      final products =
          productsJson
              .map(
                (json) =>
                    Product.fromJson(jsonDecode(json) as Map<String, dynamic>),
              )
              .toList();

      final index = products.indexWhere((p) => p.id == productId);
      if (index == -1) {
        throw Exception('Product not found');
      }

      products[index] = products[index].copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );

      final updatedProductsJson =
          products.map((p) => jsonEncode(p.toJson())).toList();
      await _sharedPreferences.setStringList(
        _localProductsKey,
        updatedProductsJson,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // Crear datos de ejemplo de productos
  @override
  Future<void> seedSampleData() async {
    // Este método ya no crea datos de ejemplo, ya que estamos usando exclusivamente Supabase
    // Si hay una pérdida de conectividad, esperaremos a que vuelva para sincronizar con Supabase
    return;
  }
}
