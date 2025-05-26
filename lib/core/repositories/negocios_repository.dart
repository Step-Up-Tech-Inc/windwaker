import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/negocio.dart';

class NegociosRepository {
  final SupabaseClient _supabaseClient;

  NegociosRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  Future<List<Negocio>> getNegocios() async {
    try {
      final response = await _supabaseClient
          .from('stores')
          .select()
          .eq('is_deleted', false)
          .order('name');

      return (response as List<dynamic>).map((json) {
        return Negocio(
          id: json['id'],
          nombre: json['name'],
          imagenUrl: json['image_url'],
          calificacion: (json['rating'] as num).toDouble(),
          tiempoEntregaMin: (json['delivery_time_minutes'] as num).toInt() - 5,
          tiempoEntregaMax: (json['delivery_time_minutes'] as num).toInt() + 5,
          costoEnvio: (json['delivery_fee'] as num).toDouble(),
          categoria: json['category'],
          ciudad: 'Tilarán',
          esDestacado: json['is_featured'] ?? false,
          activo: json['is_open'] ?? true,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener negocios: ${e.toString()}');
    }
  }

  Future<List<Negocio>> getNegociosDestacados() async {
    try {
      final response = await _supabaseClient
          .from('stores')
          .select()
          .eq('is_deleted', false)
          .eq('is_featured', true)
          .order('name');

      return (response as List<dynamic>).map((json) {
        return Negocio(
          id: json['id'],
          nombre: json['name'],
          imagenUrl: json['image_url'],
          calificacion: (json['rating'] as num).toDouble(),
          tiempoEntregaMin: (json['delivery_time_minutes'] as num).toInt() - 5,
          tiempoEntregaMax: (json['delivery_time_minutes'] as num).toInt() + 5,
          costoEnvio: (json['delivery_fee'] as num).toDouble(),
          categoria: json['category'],
          ciudad: 'Tilarán',
          esDestacado: json['is_featured'] ?? false,
          activo: json['is_open'] ?? true,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener negocios destacados: ${e.toString()}');
    }
  }
}
