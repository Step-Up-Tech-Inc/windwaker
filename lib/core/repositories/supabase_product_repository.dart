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
    try {
      // Verificar si ya existen productos
      final existingProducts = await _supabaseClient
          .from('products')
          .select('id')
          .limit(1);

      if (existingProducts.isNotEmpty) {
        // Ya hay productos, no es necesario crear datos de muestra
        _logger.i('Ya existen productos, no se crearán datos de muestra');
        return;
      }

      _logger.i(
        'No se encontraron productos existentes. Creando datos de muestra...',
      );
      final allProducts = <Map<String, dynamic>>[];

      // Productos para supermercado
      final supermercadoId = '00000000-0000-0000-0000-000000000003';
      final supermercadoProducts = [
        {
          'id': _uuid.v4(),
          'name': 'Manzanas Rojas',
          'description': 'Manzanas rojas frescas',
          'image_url':
              'https://cdn.pixabay.com/photo/2016/12/06/18/27/apples-1887337_1280.jpg',
          'category': 'Frutas',
          'price': 2500,
          'unit': 'kg',
          'quantity': 1,
          'store_id': supermercadoId,
          'status': ProductStatus.available.index,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_deleted': false,
        },
        {
          'id': _uuid.v4(),
          'name': 'Tomates',
          'description': 'Tomates frescos',
          'image_url':
              'https://cdn.pixabay.com/photo/2011/03/16/16/01/tomatoes-5356_1280.jpg',
          'category': 'Verduras',
          'price': 1800,
          'unit': 'kg',
          'quantity': 1,
          'store_id': supermercadoId,
          'status': ProductStatus.available.index,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_deleted': false,
        },
      ];
      allProducts.addAll(supermercadoProducts);

      // Productos para restaurante
      final restauranteId = '00000000-0000-0000-0000-000000000001';
      final restauranteProducts = [
        {
          'id': _uuid.v4(),
          'name': 'Hamburguesa Clásica',
          'description': 'Hamburguesa con queso, lechuga y tomate',
          'image_url':
              'https://cdn.pixabay.com/photo/2016/03/05/19/02/hamburger-1238246_1280.jpg',
          'category': 'Hamburguesas',
          'price': 5500,
          'unit': 'unidad',
          'quantity': 1,
          'store_id': restauranteId,
          'status': ProductStatus.available.index,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_deleted': false,
        },
        {
          'id': _uuid.v4(),
          'name': 'Pizza Margarita',
          'description': 'Pizza con salsa de tomate, mozzarella y albahaca',
          'image_url':
              'https://cdn.pixabay.com/photo/2017/12/09/08/18/pizza-3007395_1280.jpg',
          'category': 'Pizzas',
          'price': 8000,
          'unit': 'unidad',
          'quantity': 1,
          'store_id': restauranteId,
          'status': ProductStatus.available.index,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_deleted': false,
        },
      ];
      allProducts.addAll(restauranteProducts);

      // Productos para farmacia
      final farmaciaId = '00000000-0000-0000-0000-000000000002';
      final farmaciaProducts = [
        {
          'id': _uuid.v4(),
          'name': 'Paracetamol',
          'description': 'Analgésico y antipirético',
          'image_url':
              'https://cdn.pixabay.com/photo/2016/12/05/19/49/syringe-1884784_1280.jpg',
          'category': 'Medicamentos',
          'price': 2000,
          'unit': 'caja',
          'quantity': 1,
          'store_id': farmaciaId,
          'status': ProductStatus.available.index,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_deleted': false,
        },
        {
          'id': _uuid.v4(),
          'name': 'Vendas Elásticas',
          'description': 'Vendas para lesiones',
          'image_url':
              'https://cdn.pixabay.com/photo/2014/12/10/21/01/doctor-563429_1280.jpg',
          'category': 'Primeros Auxilios',
          'price': 3500,
          'unit': 'paquete',
          'quantity': 1,
          'store_id': farmaciaId,
          'status': ProductStatus.available.index,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_deleted': false,
        },
      ];
      allProducts.addAll(farmaciaProducts);

      // Intentar insertar los productos
      if (allProducts.isNotEmpty) {
        _logger.i(
          'Intentando insertar ${allProducts.length} productos de muestra',
        );
        try {
          await _supabaseClient
              .from('products')
              .upsert(allProducts, onConflict: 'id');
          _logger.i('¡Productos de muestra insertados correctamente!');
        } catch (innerError) {
          _logger.e('Error específico al insertar productos: $innerError');

          // Intentar insertar uno por uno para identificar qué producto causa problemas
          _logger.i('Intentando insertar productos uno por uno...');
          for (var product in allProducts) {
            try {
              await _supabaseClient.from('products').insert(product);
              _logger.i('Producto insertado: ${product['name']}');
            } catch (productError) {
              _logger.e(
                'Error al insertar producto ${product['name']}: $productError',
              );
            }
          }
        }
      }
    } catch (e) {
      _logger.e('Error al crear datos de muestra: $e');
      // Verificar si la tabla existe
      try {
        // Verificamos si existe la tabla products
        final tableExists =
            await _supabaseClient
                .rpc('check_table_exists', params: {'table_name': 'products'})
                .select();
        _logger.i('Resultado verificación tabla: $tableExists');

        // Intentar consultar la tabla directamente
        try {
          final test = await _supabaseClient
              .from('products')
              .select('id')
              .limit(1);
          _logger.i(
            'Consulta directa a productos exitosa: ${test.length} resultados',
          );
        } catch (directError) {
          _logger.e(
            'Error al consultar directamente la tabla products: $directError',
          );
        }
      } catch (tableError) {
        _logger.e('Error al verificar si la tabla existe: $tableError');
      }
    }
  }
}
