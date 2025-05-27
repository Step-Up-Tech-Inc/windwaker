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
          .eq('is_deleted', false)
          .order('name');

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Store.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener tiendas: ${e.toString()}');
    }
  }

  Future<List<Store>> getFeaturedStores() async {
    try {
      // Obtener las tiendas destacadas
      final response = await _supabaseClient
          .from('stores')
          .select()
          .eq('is_featured', true)
          .eq('is_deleted', false)
          .order('name');

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Store.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener tiendas destacadas: ${e.toString()}');
    }
  }

  Future<List<Store>> searchStores(String query) async {
    try {
      // Intentamos usar la función personalizada search_stores
      try {
        final response = await _supabaseClient.rpc(
          'search_stores',
          params: {'search_query': query},
        );

        final List<dynamic> data = response as List<dynamic>;
        return data.map((json) => Store.fromJson(json)).toList();
      } catch (rpcError) {
        // Si la función RPC falla, hacemos una búsqueda básica
        final response = await _supabaseClient
            .from('stores')
            .select()
            .ilike('name', '%$query%')
            .eq('is_deleted', false)
            .order('name');

        final List<dynamic> data = response as List<dynamic>;
        return data.map((json) => Store.fromJson(json)).toList();
      }
    } catch (e) {
      throw Exception('Error al buscar tiendas: ${e.toString()}');
    }
  }

  Future<List<Store>> getStoresByCategory(String category) async {
    try {
      final response = await _supabaseClient
          .from('stores')
          .select()
          .eq('category', category)
          .eq('is_deleted', false)
          .order('name');

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Store.fromJson(json)).toList();
    } catch (e) {
      throw Exception(
        'Error al filtrar tiendas por categoría: ${e.toString()}',
      );
    }
  }
}
