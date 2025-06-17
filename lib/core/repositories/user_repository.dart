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

      // Verificar si la tabla profiles existe
      try {
        final tableCheck = await _supabaseClient.rpc(
          'check_table_exists',
          params: {'table_name': 'profiles'},
        );
        _logger.i('¿Existe tabla profiles?: $tableCheck');

        if (tableCheck == false) {
          _logger.w('La tabla profiles no existe. Intentando crearla...');
          await _supabaseClient.rpc(
            'exec_sql',
            params: {
              'sql': '''
            CREATE TABLE IF NOT EXISTS profiles (
              id UUID PRIMARY KEY,
              email TEXT,
              phone TEXT,
              created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
              updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );
            ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
            ''',
            },
          );
        }
      } catch (e) {
        _logger.e('Error al verificar tabla profiles: $e');
      }

      // Usar upsert directamente para simplificar
      final now = DateTime.now().toIso8601String();
      final data = {
        'id': userId,
        'email': email,
        'phone': phone,
        'updated_at': now,
      };

      _logger.i('Datos para upsert: $data');

      try {
        final response =
            await _supabaseClient.from('profiles').upsert(data).select();

        _logger.i('Respuesta de upsert: $response');
        _logger.i('Perfil de usuario creado/actualizado con éxito');
      } catch (e) {
        _logger.e('Error en upsert: $e');

        // Intentar con método alternativo de inserción directa
        try {
          _logger.i('Intentando inserción directa con SQL...');
          final sql = '''
          INSERT INTO profiles (id, email, phone, created_at, updated_at)
          VALUES ('$userId', ${email != null ? "'$email'" : 'NULL'}, ${phone != null ? "'$phone'" : 'NULL'}, '$now', '$now')
          ON CONFLICT (id) DO UPDATE SET 
            email = ${email != null ? "'$email'" : 'EXCLUDED.email'},
            phone = ${phone != null ? "'$phone'" : 'EXCLUDED.phone'},
            updated_at = '$now';
          ''';

          await _supabaseClient.rpc('exec_sql', params: {'sql': sql});
          _logger.i('Inserción directa con SQL exitosa');
        } catch (sqlError) {
          _logger.e('Error en inserción directa: $sqlError');
          throw Exception('No se pudo crear/actualizar el perfil: $sqlError');
        }
      }

      // Verificar que el perfil se guardó correctamente
      final updatedProfile = await getUserProfile(userId);
      _logger.i('Perfil actualizado: $updatedProfile');
    } catch (e) {
      _logger.e('Error al crear/actualizar perfil de usuario: $e');
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
