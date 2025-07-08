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
      _logger.i('🔄 === INICIO createOrUpdateUserProfile ===');
      _logger.i('   userId: "$userId"');
      _logger.i('   email: "$email"');
      _logger.i('   phone: "$phone"');

      // Preparar datos para upsert
      final now = DateTime.now().toIso8601String();
      _logger.i('   timestamp: $now');

      // Verificar si algún campo es null y obtener valores existentes si es necesario
      Map<String, dynamic>? existingProfile;
      try {
        _logger.i('🔍 Obteniendo perfil existente...');
        existingProfile = await getUserProfile(userId);
        _logger.i('📋 Perfil existente encontrado: $existingProfile');
      } catch (e) {
        _logger.w('⚠️ No se pudo obtener el perfil existente: $e');
      }

      // Determinar valores finales a usar
      String? finalEmail = email;
      String? finalPhone = phone;

      // Si el email es null pero hay uno existente, mantenerlo
      if (email == null &&
          existingProfile != null &&
          existingProfile['email'] != null) {
        finalEmail = existingProfile['email'] as String?;
        _logger.i('📧 Usando email existente: "$finalEmail"');
      }

      // Si el teléfono es null pero hay uno existente, mantenerlo
      if (phone == null &&
          existingProfile != null &&
          existingProfile['phone'] != null) {
        finalPhone = existingProfile['phone'] as String?;
        _logger.i('📱 Usando teléfono existente: "$finalPhone"');
      }

      _logger.i('🎯 Valores finales a guardar:');
      _logger.i('   Email final: "$finalEmail"');
      _logger.i('   Phone final: "$finalPhone"');

      // Crear objeto con datos no nulos
      final Map<String, dynamic> data = {'id': userId, 'updated_at': now};

      // Agregar email y teléfono solo si no son nulos
      if (finalEmail != null && finalEmail.isNotEmpty) {
        data['email'] = finalEmail;
        _logger.i('✅ Email agregado a data: "${data['email']}"');
      } else {
        _logger.w('⚠️ Email no agregado (null o vacío)');
      }

      if (finalPhone != null && finalPhone.isNotEmpty) {
        data['phone'] = finalPhone;
        _logger.i('✅ Phone agregado a data: "${data['phone']}"');
      } else {
        _logger.w('⚠️ Phone no agregado (null o vacío)');
      }

      _logger.i('📦 Datos completos para upsert: $data');

      try {
        _logger.i('🚀 Intentando upsert directo...');
        // Intentar upsert directo
        final response =
            await _supabaseClient.from('profiles').upsert(data).select();

        _logger.i('✅ Upsert exitoso. Respuesta completa: $response');

        // Verificar que la respuesta contiene los datos esperados
        if (response.isNotEmpty) {
          final savedData = response.first;
          _logger.i('📋 Datos guardados en respuesta:');
          _logger.i('   ID: "${savedData['id']}"');
          _logger.i('   Email: "${savedData['email']}"');
          _logger.i('   Phone: "${savedData['phone']}"');
          _logger.i('   Updated: "${savedData['updated_at']}"');

          // Verificar específicamente el email
          if (finalEmail != null && savedData['email'] != finalEmail) {
            _logger.e('❌ PROBLEMA: Email no coincide en respuesta');
            _logger.e('   Esperado: "$finalEmail"');
            _logger.e('   Guardado: "${savedData['email']}"');
          } else if (finalEmail != null) {
            _logger.i(
              '✅ Email verificado en respuesta: "${savedData['email']}"',
            );
          }
        } else {
          _logger.w('⚠️ Respuesta de upsert vacía');
        }
      } catch (upsertError) {
        _logger.e('❌ Error en upsert: $upsertError');
        _logger.e('   Tipo de error: ${upsertError.runtimeType}');

        // Verificar si el registro existe
        try {
          _logger.i('🔍 Verificando si el registro existe...');
          final exists =
              await _supabaseClient
                  .from('profiles')
                  .select('id, email, phone')
                  .eq('id', userId)
                  .maybeSingle();

          _logger.i('📋 Registro existente: $exists');

          if (exists != null) {
            // Si existe, actualizar
            _logger.i('🔄 Perfil existe, actualizando...');
            final updateData = {'updated_at': now};
            if (finalEmail != null && finalEmail.isNotEmpty) {
              updateData['email'] = finalEmail;
              _logger.i('📧 Email agregado al update: "$finalEmail"');
            }
            if (finalPhone != null && finalPhone.isNotEmpty) {
              updateData['phone'] = finalPhone;
              _logger.i('📱 Phone agregado al update: "$finalPhone"');
            }

            _logger.i('📦 Datos para update: $updateData');

            final updateResponse =
                await _supabaseClient
                    .from('profiles')
                    .update(updateData)
                    .eq('id', userId)
                    .select();

            _logger.i('✅ Actualización exitosa. Respuesta: $updateResponse');
          } else {
            // Si no existe, insertar
            _logger.i('➕ Perfil no existe, insertando...');
            final insertData = {
              'id': userId,
              'created_at': now,
              'updated_at': now,
            };
            if (finalEmail != null && finalEmail.isNotEmpty) {
              insertData['email'] = finalEmail;
              _logger.i('📧 Email agregado al insert: "$finalEmail"');
            }
            if (finalPhone != null && finalPhone.isNotEmpty) {
              insertData['phone'] = finalPhone;
              _logger.i('📱 Phone agregado al insert: "$finalPhone"');
            }

            _logger.i('📦 Datos para insert: $insertData');

            final insertResponse =
                await _supabaseClient
                    .from('profiles')
                    .insert(insertData)
                    .select();

            _logger.i('✅ Inserción exitosa. Respuesta: $insertResponse');
          }
        } catch (e) {
          _logger.e('❌ Error en operación alternativa: $e');
          _logger.e('   Tipo de error: ${e.runtimeType}');
          throw Exception('No se pudo crear/actualizar el perfil: $e');
        }
      }

      // Verificar que el perfil se guardó correctamente
      _logger.i('🔍 Verificación final del perfil guardado...');
      final updatedProfile = await getUserProfile(userId);
      _logger.i('📋 Perfil final verificado: $updatedProfile');

      if (updatedProfile != null) {
        _logger.i('✅ Verificación de campos guardados:');
        _logger.i('   Email guardado: "${updatedProfile['email']}"');
        _logger.i('   Phone guardado: "${updatedProfile['phone']}"');
        _logger.i('   Updated at: "${updatedProfile['updated_at']}"');

        // Verificación específica del email
        if (finalEmail != null) {
          final savedEmail = updatedProfile['email']?.toString();
          if (savedEmail == finalEmail) {
            _logger.i('✅ Email verificado correctamente');
          } else {
            _logger.e('❌ CRÍTICO: Email no se guardó correctamente');
            _logger.e('   Esperado: "$finalEmail"');
            _logger.e('   Guardado: "$savedEmail"');
          }
        }
      } else {
        _logger.e('❌ CRÍTICO: No se pudo verificar el perfil guardado');
      }

      _logger.i('🎉 === FIN createOrUpdateUserProfile ===');
    } catch (e) {
      _logger.e('❌ Error al crear/actualizar perfil de usuario: $e');
      _logger.e('   Tipo de error: ${e.runtimeType}');
      _logger.e('   Stack trace: ${StackTrace.current}');
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
