import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/store.dart';

class StoreRepository {
  final SupabaseClient _supabaseClient;

  StoreRepository({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<List<Store>> getStores() async {
    try {
      final response = await _supabaseClient
          .from('stores')
          .select()
          .order('name');

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Store.fromJson(json)).toList();
    } catch (e) {
      // Fallback a datos mock en caso de error
      return _getMockStores();
    }
  }

  Future<List<Store>> searchStores(String query) async {
    try {
      final response = await _supabaseClient.rpc(
        'search_stores',
        params: {'search_query': query},
      );

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Store.fromJson(json)).toList();
    } catch (e) {
      // Fallback a búsqueda local en datos mock
      final allStores = await getStores();
      return allStores
          .where(
            (store) =>
                store.name.toLowerCase().contains(query.toLowerCase()) ||
                store.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  Future<List<Store>> getStoresByCategory(String category) async {
    try {
      final response = await _supabaseClient
          .from('stores')
          .select()
          .eq('category', category)
          .order('name');

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Store.fromJson(json)).toList();
    } catch (e) {
      // Fallback a filtrado local en datos mock
      final allStores = _getMockStores();
      return allStores
          .where(
            (store) => store.category.toLowerCase() == category.toLowerCase(),
          )
          .toList();
    }
  }

  // Datos mock para fallback
  List<Store> _getMockStores() {
    return [
      const Store(
        id: '1',
        name: 'Restaurante El Sabor',
        description: 'Comida tradicional con el mejor sabor',
        imageUrl:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
        category: 'Restaurante',
        rating: 4.7,
        deliveryTimeMinutes: 30,
        deliveryFee: 2.5,
        isOpen: true,
      ),
      const Store(
        id: '2',
        name: 'Farmacia Salud',
        description: 'Tu salud es nuestra prioridad',
        imageUrl:
            'https://images.unsplash.com/photo-1471864190281-a93a3070b6de',
        category: 'Farmacia',
        rating: 4.5,
        deliveryTimeMinutes: 20,
        deliveryFee: 1.5,
        isOpen: true,
      ),
      const Store(
        id: '3',
        name: 'Supermercado Express',
        description: 'Todo lo que necesitas en un solo lugar',
        imageUrl:
            'https://images.unsplash.com/photo-1601598851547-4302969d0614',
        category: 'Supermercado',
        rating: 4.3,
        deliveryTimeMinutes: 40,
        deliveryFee: 3.0,
        isOpen: true,
      ),
      const Store(
        id: '4',
        name: 'Café Aroma',
        description: 'El mejor café de la ciudad',
        imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24',
        category: 'Café',
        rating: 4.8,
        deliveryTimeMinutes: 25,
        deliveryFee: 2.0,
        isOpen: true,
      ),
      const Store(
        id: '5',
        name: 'Tienda de Mascotas Patitas',
        description: 'Todo para tu mascota',
        imageUrl:
            'https://images.unsplash.com/photo-1583337130417-3346a1be7dee',
        category: 'Mascotas',
        rating: 4.6,
        deliveryTimeMinutes: 35,
        deliveryFee: 2.8,
        isOpen: false,
      ),
    ];
  }
}
