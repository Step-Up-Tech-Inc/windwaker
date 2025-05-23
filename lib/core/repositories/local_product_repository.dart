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
    // Verificar si ya hay productos guardados
    final existingProducts = _sharedPreferences.getStringList(
      _localProductsKey,
    );
    if (existingProducts != null && existingProducts.isNotEmpty) {
      // Si hay productos existentes, no volvemos a crear datos de ejemplo
      return;
    }

    final allProducts = [];

    // Productos para supermercado (ID: 3)
    final supermercadoProducts = [
      Product(
        id: _uuid.v4(),
        name: 'Manzanas Rojas',
        description: 'Manzanas rojas frescas',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/12/06/18/27/apples-1887337_1280.jpg',
        category: 'Frutas',
        price: 2500,
        unit: 'kg',
        quantity: 1,
        storeId: '3', // ID del supermercado
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Tomates',
        description: 'Tomates frescos',
        imageUrl:
            'https://cdn.pixabay.com/photo/2011/03/16/16/01/tomatoes-5356_1280.jpg',
        category: 'Verduras',
        price: 1800,
        unit: 'kg',
        quantity: 1,
        storeId: '3', // ID del supermercado
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Yogurt Natural',
        description: 'Yogurt natural',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/06/07/17/15/yogurt-1442034_1280.jpg',
        category: 'Lácteos',
        price: 3200,
        unit: 'L',
        quantity: 1,
        storeId: '3', // ID del supermercado
        status: ProductStatus.lowStock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Pechuga de Pollo',
        description: 'Pechuga de pollo fresca',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/05/30/15/31/poultry-1424979_1280.jpg',
        category: 'Carnes',
        price: 4500,
        unit: 'g',
        quantity: 500,
        storeId: '3', // ID del supermercado
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Leche Entera',
        description: 'Leche entera',
        imageUrl:
            'https://cdn.pixabay.com/photo/2017/07/05/15/41/milk-2474993_1280.jpg',
        category: 'Lácteos',
        price: 1500,
        unit: 'L',
        quantity: 1,
        storeId: '3', // ID del supermercado
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Plátanos',
        description: 'Plátanos frescos',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/01/03/17/59/bananas-1119790_1280.jpg',
        category: 'Frutas',
        price: 1200,
        unit: 'kg',
        quantity: 1,
        storeId: '3', // ID del supermercado
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Arroz',
        description: 'Arroz blanco de primera calidad',
        imageUrl:
            'https://cdn.pixabay.com/photo/2014/10/22/16/38/ingrediant-498199_1280.jpg',
        category: 'Granos',
        price: 2200,
        unit: 'kg',
        quantity: 1,
        storeId: '3',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Frijoles Negros',
        description: 'Frijoles negros de alta calidad',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/09/15/19/24/black-bean-1672136_1280.jpg',
        category: 'Granos',
        price: 1800,
        unit: 'kg',
        quantity: 1,
        storeId: '3',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Aceite de Oliva',
        description: 'Aceite de oliva extra virgen',
        imageUrl:
            'https://cdn.pixabay.com/photo/2020/05/25/22/49/oil-5220801_1280.jpg',
        category: 'Aceites',
        price: 5500,
        unit: 'L',
        quantity: 1,
        storeId: '3',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Azúcar',
        description: 'Azúcar blanca refinada',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/07/28/19/03/sugar-1548749_1280.jpg',
        category: 'Repostería',
        price: 1200,
        unit: 'kg',
        quantity: 1,
        storeId: '3',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Pasta de Tornillos',
        description: 'Pasta de trigo de alta calidad',
        imageUrl:
            'https://cdn.pixabay.com/photo/2015/05/01/11/30/pasta-748895_1280.jpg',
        category: 'Pastas',
        price: 950,
        unit: 'paquete',
        quantity: 1,
        storeId: '3',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Pan Integral',
        description: 'Pan integral recién horneado',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/07/10/19/19/bread-1508166_1280.jpg',
        category: 'Panadería',
        price: 1500,
        unit: 'unidad',
        quantity: 1,
        storeId: '3',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Huevos',
        description: 'Huevos frescos de gallina',
        imageUrl:
            'https://cdn.pixabay.com/photo/2015/09/17/17/19/egg-944495_1280.jpg',
        category: 'Lácteos',
        price: 2800,
        unit: 'docena',
        quantity: 1,
        storeId: '3',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Cereal Integral',
        description: 'Cereal de granos integrales con miel',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/11/06/23/31/breakfast-1804457_1280.jpg',
        category: 'Desayuno',
        price: 3500,
        unit: 'caja',
        quantity: 1,
        storeId: '3',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Atún en Lata',
        description: 'Atún en aceite de oliva',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/05/31/13/01/sardines-1426708_1280.jpg',
        category: 'Enlatados',
        price: 1800,
        unit: 'lata',
        quantity: 1,
        storeId: '3',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    allProducts.addAll(supermercadoProducts);

    // Productos para restaurante (ID: 1)
    final restauranteProducts = [
      Product(
        id: _uuid.v4(),
        name: 'Hamburguesa Clásica',
        description: 'Hamburguesa con queso, lechuga y tomate',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/03/05/19/02/hamburger-1238246_1280.jpg',
        category: 'Hamburguesas',
        price: 5500,
        unit: 'unidad',
        quantity: 1,
        storeId: '1', // ID del restaurante
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Pizza Margarita',
        description: 'Pizza con salsa de tomate, mozzarella y albahaca',
        imageUrl:
            'https://cdn.pixabay.com/photo/2017/12/09/08/18/pizza-3007395_1280.jpg',
        category: 'Pizzas',
        price: 8000,
        unit: 'unidad',
        quantity: 1,
        storeId: '1', // ID del restaurante
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Papas Fritas',
        description: 'Papas fritas crujientes',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/11/20/09/06/bowl-1842294_1280.jpg',
        category: 'Acompañamientos',
        price: 2500,
        unit: 'porción',
        quantity: 1,
        storeId: '1', // ID del restaurante
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Refresco',
        description: 'Refresco cola',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/07/21/11/17/drink-1532300_1280.jpg',
        category: 'Bebidas',
        price: 1200,
        unit: 'ml',
        quantity: 500,
        storeId: '1', // ID del restaurante
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Ensalada César',
        description: 'Ensalada con lechuga, pollo, queso parmesano y croutones',
        imageUrl:
            'https://cdn.pixabay.com/photo/2017/08/13/10/58/caesar-salad-2636938_1280.jpg',
        category: 'Ensaladas',
        price: 4500,
        unit: 'porción',
        quantity: 1,
        storeId: '1',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Sopa de Tomate',
        description: 'Sopa casera de tomate con albahaca',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/06/01/21/40/soup-1429793_1280.jpg',
        category: 'Sopas',
        price: 3200,
        unit: 'porción',
        quantity: 1,
        storeId: '1',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Tacos de Carne',
        description: 'Tacos de carne asada con cilantro y cebolla',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/08/23/08/53/tacos-1613795_1280.jpg',
        category: 'Mexicana',
        price: 4800,
        unit: 'orden',
        quantity: 3,
        storeId: '1',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Pasta Carbonara',
        description: 'Pasta con salsa cremosa, tocino y queso parmesano',
        imageUrl:
            'https://cdn.pixabay.com/photo/2020/05/11/15/06/pasta-5158504_1280.jpg',
        category: 'Pastas',
        price: 6500,
        unit: 'porción',
        quantity: 1,
        storeId: '1',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    allProducts.addAll(restauranteProducts);

    // Productos para farmacia (ID: 2)
    final farmaciaProducts = [
      Product(
        id: _uuid.v4(),
        name: 'Paracetamol',
        description: 'Analgésico y antipirético',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/12/05/19/49/syringe-1884784_1280.jpg',
        category: 'Medicamentos',
        price: 2000,
        unit: 'caja',
        quantity: 1,
        storeId: '2', // ID de la farmacia
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Vendas Elásticas',
        description: 'Vendas para lesiones',
        imageUrl:
            'https://cdn.pixabay.com/photo/2014/12/10/21/01/doctor-563429_1280.jpg',
        category: 'Primeros Auxilios',
        price: 3500,
        unit: 'paquete',
        quantity: 1,
        storeId: '2', // ID de la farmacia
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Vitamina C',
        description: 'Suplemento vitamínico',
        imageUrl:
            'https://cdn.pixabay.com/photo/2015/09/21/22/52/vitamin-951503_1280.jpg',
        category: 'Suplementos',
        price: 5000,
        unit: 'frasco',
        quantity: 1,
        storeId: '2', // ID de la farmacia
        status: ProductStatus.lowStock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Termómetro Digital',
        description: 'Termómetro digital de precisión',
        imageUrl:
            'https://cdn.pixabay.com/photo/2020/04/19/13/33/virus-5064169_1280.jpg',
        category: 'Dispositivos Médicos',
        price: 7500,
        unit: 'unidad',
        quantity: 1,
        storeId: '2',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Alcohol en Gel',
        description: 'Alcohol en gel antibacterial',
        imageUrl:
            'https://cdn.pixabay.com/photo/2020/05/23/08/54/hand-sanitizer-5209663_1280.jpg',
        category: 'Higiene',
        price: 2500,
        unit: 'botella',
        quantity: 1,
        storeId: '2',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Mascarillas Desechables',
        description: 'Paquete de mascarillas quirúrgicas',
        imageUrl:
            'https://cdn.pixabay.com/photo/2020/04/25/20/34/mouth-guard-5092086_1280.jpg',
        category: 'Protección',
        price: 3000,
        unit: 'paquete',
        quantity: 10,
        storeId: '2',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Ibuprofeno',
        description: 'Antiinflamatorio no esteroideo',
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/12/09/08/53/medicines-1893982_1280.jpg',
        category: 'Medicamentos',
        price: 2200,
        unit: 'caja',
        quantity: 1,
        storeId: '2',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Protector Solar',
        description: 'Protector solar FPS 50',
        imageUrl:
            'https://cdn.pixabay.com/photo/2018/06/25/18/29/sun-3497588_1280.jpg',
        category: 'Dermatología',
        price: 8500,
        unit: 'botella',
        quantity: 1,
        storeId: '2',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Jabón Antibacterial',
        description: 'Jabón líquido antibacterial para manos',
        imageUrl:
            'https://cdn.pixabay.com/photo/2020/04/10/13/22/coronavirus-5025651_1280.jpg',
        category: 'Higiene',
        price: 2800,
        unit: 'botella',
        quantity: 1,
        storeId: '2',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Curitas',
        description: 'Bandas adhesivas para pequeñas heridas',
        imageUrl:
            'https://cdn.pixabay.com/photo/2015/08/24/13/22/adhesive-bandage-905457_1280.jpg',
        category: 'Primeros Auxilios',
        price: 1500,
        unit: 'caja',
        quantity: 1,
        storeId: '2',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Pastillas para la Tos',
        description: 'Pastillas para aliviar la tos',
        imageUrl:
            'https://cdn.pixabay.com/photo/2014/07/10/15/59/pills-389714_1280.jpg',
        category: 'Medicamentos',
        price: 1800,
        unit: 'caja',
        quantity: 1,
        storeId: '2',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    allProducts.addAll(farmaciaProducts);

    // Guardar todos los productos
    final productsJson =
        allProducts.map((p) => jsonEncode(p.toJson())).toList();
    await _sharedPreferences.setStringList(_localProductsKey, productsJson);

    // Crear inventario para los productos
    final sampleInventory =
        allProducts
            .map(
              (product) => Inventory(
                id: _uuid.v4(),
                storeId: product.storeId,
                productId: product.id,
                currentStock:
                    product.status == ProductStatus.available
                        ? 100
                        : product.status == ProductStatus.lowStock
                        ? 10
                        : 0,
                minStock: 10,
                maxStock: 200,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            )
            .toList();

    final inventoryJson =
        sampleInventory.map((i) => jsonEncode(i.toJson())).toList();
    await _sharedPreferences.setStringList(_localInventoryKey, inventoryJson);
  }
}
