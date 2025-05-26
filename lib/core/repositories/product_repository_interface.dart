import '../models/product.dart';
import '../models/inventory.dart';

abstract class ProductRepositoryInterface {
  // Obtener productos por tienda
  Future<List<Product>> getProductsByStore(String storeId);

  // Obtener productos por categoría
  Future<List<Product>> getProductsByCategory(String storeId, String category);

  // Obtener inventario de un producto
  Future<Inventory?> getProductInventory(String productId);

  // Añadir un producto
  Future<Product> addProduct(Product product);

  // Actualizar un producto
  Future<Product> updateProduct(Product product);

  // Eliminar un producto (lógicamente)
  Future<bool> deleteProduct(String productId);

  // Cargar datos de muestra (opcional)
  Future<void> seedSampleData();
}
