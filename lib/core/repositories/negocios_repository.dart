import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/negocio.dart';

class NegociosRepository {
  final SupabaseClient _supabaseClient;

  NegociosRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  Future<List<Negocio>> getNegocios() async {
    try {
      final response = await _supabaseClient
          .from('negocios')
          .select()
          .eq('activo', true)
          .order('nombre');

      return (response as List<dynamic>)
          .map((json) => Negocio.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // En caso de error, devolvemos datos de ejemplo
      return [
        Negocio(
          id: '1',
          nombre: 'Restaurante El Buen Sabor',
          imagenUrl: 'https://picsum.photos/200/300',
          calificacion: 4.5,
          tiempoEntregaMin: 25,
          tiempoEntregaMax: 35,
          costoEnvio: 1500,
          categoria: 'Restaurante',
          ciudad: 'Tilarán',
          activo: true,
        ),
        Negocio(
          id: '2',
          nombre: 'Supermercado La Esquina',
          imagenUrl: 'https://picsum.photos/200/300',
          calificacion: 4.2,
          tiempoEntregaMin: 15,
          tiempoEntregaMax: 25,
          costoEnvio: 1200,
          categoria: 'Supermercado',
          ciudad: 'Tilarán',
          activo: true,
        ),
      ];
    }
  }
}
