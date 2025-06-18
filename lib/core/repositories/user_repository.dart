import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class UserRepository {
  final SupabaseClient _supabaseClient;
  final _logger = Logger();

  UserRepository({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Obtiene el usuario actual desde Supabase Auth
  User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }

  /// Verifica la estructura de la tabla profiles
  Future<Map<String, dynamic>> verifyProfilesTable() async {
    try {
      _logger.i('Verificando estructura de la tabla profiles...');

      // Verificar si la tabla existe
      try {
        final result = await _supabaseClient
            .from('profiles')
            .select('id')
            .limit(1);
        _logger.i('La tabla profiles existe. Resultado de prueba: $result');
      } catch (e) {
        _logger.e('Error al consultar tabla profiles: $e');
        return {'exists': false, 'error': e.toString()};
      }

      // Verificar los permisos de escritura
      try {
        final user = getCurrentUser();
        if (user != null) {
          _logger.i(
            'Intentando verificar permisos de escritura para usuario: ${user.id}',
          );

          final testData = {
            'id': user.id,
            'email': user.email,
            'phone': 'test_phone',
            'updated_at': DateTime.now().toIso8601String(),
          };

          final response =
              await _supabaseClient.from('profiles').upsert(testData).select();

          _logger.i('Prueba de escritura exitosa: $response');
          return {
            'exists': true,
            'writable': true,
            'sample': response,
            'user': user.id,
          };
        } else {
          _logger.w(
            'No hay usuario autenticado para probar permisos de escritura',
          );
          return {
            'exists': true,
            'writable': false,
            'reason': 'No user authenticated',
          };
        }
      } catch (e) {
        _logger.e('Error al verificar permisos de escritura: $e');
        return {'exists': true, 'writable': false, 'error': e.toString()};
      }
    } catch (e) {
      _logger.e('Error general al verificar tabla profiles: $e');
      return {'error': e.toString()};
    }
  }

  /// Crea o actualiza el perfil del usuario en la tabla 'profiles'
  Future<void> createOrUpdateUserProfile({
    required String userId,
    String? email,
    String? phone,
  }) async {
    try {
      _logger.i(
        'Iniciando createOrUpdateUserProfile - userId: $userId, email: $email, phone: $phone',
      );

      // Preparar datos para upsert
      final now = DateTime.now().toIso8601String();
      final data = {
        'id': userId,
        'email': email,
        'phone': phone,
        'updated_at': now,
      };

      _logger.i('Intentando upsert con datos: $data');

      try {
        // Intentar upsert directo
        final response =
            await _supabaseClient.from('profiles').upsert(data).select();

        _logger.i('Upsert exitoso. Respuesta: $response');
      } catch (upsertError) {
        _logger.e('Error en upsert: $upsertError');

        // Verificar si el registro existe
        try {
          final exists =
              await _supabaseClient
                  .from('profiles')
                  .select('id')
                  .eq('id', userId)
                  .maybeSingle();

          if (exists != null) {
            // Si existe, actualizar
            _logger.i('Perfil existe, actualizando...');
            await _supabaseClient
                .from('profiles')
                .update({'email': email, 'phone': phone, 'updated_at': now})
                .eq('id', userId);
            _logger.i('Actualización exitosa');
          } else {
            // Si no existe, insertar
            _logger.i('Perfil no existe, insertando...');
            await _supabaseClient.from('profiles').insert({
              'id': userId,
              'email': email,
              'phone': phone,
              'created_at': now,
              'updated_at': now,
            });
            _logger.i('Inserción exitosa');
          }
        } catch (e) {
          _logger.e('Error en operación alternativa: $e');
          throw Exception('No se pudo crear/actualizar el perfil: $e');
        }
      }

      // Verificar que el perfil se guardó correctamente
      final updatedProfile = await getUserProfile(userId);
      _logger.i('Perfil actualizado: $updatedProfile');
    } catch (e) {
      _logger.e('Error al crear/actualizar perfil de usuario: $e');
      throw Exception('Error al crear/actualizar perfil de usuario: $e');
    }
  }

  /// Obtiene el perfil completo del usuario desde la tabla 'profiles'
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      _logger.i('Obteniendo perfil para usuario: $userId');
      final response =
          await _supabaseClient
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

      _logger.i('Perfil obtenido: $response');
      return response;
    } catch (e) {
      _logger.e('Error al obtener perfil de usuario: $e');
      return null;
    }
  }
}
