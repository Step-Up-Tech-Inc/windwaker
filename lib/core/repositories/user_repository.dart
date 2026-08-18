import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:windwaker/core/config/app_config.dart';
import 'package:windwaker/core/models/profile.dart';

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
    if (AppConfig.logDatabaseOperations) {
      _logger.i(
        '🔄 Creando/actualizando perfil para userId=$userId, email=$email, phone=$phone',
      );
    }

    try {
      // Construir datos de actualización solo con campos no-nulos
      final updateData = <String, dynamic>{};
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;

      if (AppConfig.logDatabaseOperations) {
        _logger.i('📝 updateData: $updateData');
        _logger.i(
          '🔐 Auth User ID actual: ${_supabaseClient.auth.currentUser?.id}',
        );
      }

      // 1. Intentar UPDATE primero (perfil ya existe)
      final updated = await _supabaseClient
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select();

      if (AppConfig.logDatabaseOperations) {
        _logger.i('📝 UPDATE resultado (${updated.length} filas): $updated');
      }

      if (updated.isEmpty) {
        // 2. No existía → INSERT con todos los datos
        _logger.i('🆕 Perfil no existe, insertando...');
        final inserted = await _supabaseClient
            .from('profiles')
            .insert({'id': userId, 'email': email, 'phone': phone})
            .select();

        if (AppConfig.logDatabaseOperations) {
          _logger.i('✅ Perfil insertado: $inserted');
        }
      } else {
        if (AppConfig.logDatabaseOperations) {
          _logger.i('✅ Perfil actualizado con email=$email, phone=$phone');
        }
      }
    } catch (e) {
      _logger.e('⛔ Error al guardar perfil: $e');
      rethrow;
    }
  }

  /// Obtiene el perfil completo del usuario desde la tabla 'profiles'
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    if (AppConfig.logDatabaseOperations) {
      _logger.i('💡 Obteniendo perfil para usuario: $userId');
    }
    try {
      final response =
          await _supabaseClient
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

      if (AppConfig.logDatabaseOperations) {
        if (response != null) {
          _logger.i('💡 Perfil obtenido: $response');
        } else {
          _logger.i('💡 No se encontró perfil para el usuario: $userId');
        }
      }
      return response;
    } catch (error) {
      _logger.e('Error al obtener el perfil del usuario: $error');
      return null;
    }
  }

  /// Actualiza nombre y/o avatar del perfil.
  Future<void> updateProfileDetails({
    required String userId,
    String? fullName,
    String? avatarUrl,
  }) async {
    final data = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
    if (data.isEmpty) return;
    await _supabaseClient.from('profiles').update(data).eq('id', userId);

    // Reflejar el nombre en el display name de Supabase Auth (dashboard)
    if (fullName != null && fullName.isNotEmpty) {
      try {
        await _supabaseClient.auth.updateUser(
          UserAttributes(data: {'display_name': fullName}),
        );
      } catch (e) {
        _logger.w('No se pudo actualizar display_name en Auth: $e');
      }
    }
  }

  /// Sube la foto de perfil al bucket `store-images` (carpeta avatars)
  /// y devuelve su URL pública.
  Future<String> uploadAvatar({
    required String userId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final path =
        'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _supabaseClient.storage
        .from('store-images')
        .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
    return _supabaseClient.storage.from('store-images').getPublicUrl(path);
  }

  /// Obtiene el perfil tipado del usuario (o null si no existe)
  Future<Profile?> getProfile(String userId) async {
    final data = await getUserProfile(userId);
    if (data == null) return null;
    try {
      return Profile.fromJson(data);
    } catch (e) {
      _logger.e('Error deserializando perfil de $userId: $e');
      return null;
    }
  }

  /// Busca un usuario por número de teléfono en la tabla 'profiles'
  Future<Map<String, dynamic>?> findUserByPhone(String phoneNumber) async {
    if (AppConfig.logDatabaseOperations) {
      _logger.i('🔍 Buscando usuario por teléfono: $phoneNumber');
    }

    try {
      final response =
          await _supabaseClient
              .from('profiles')
              .select()
              .eq('phone', phoneNumber)
              .maybeSingle();

      if (AppConfig.logDatabaseOperations) {
        if (response != null) {
          _logger.i('✅ Usuario encontrado por teléfono: ${response['id']}');
        } else {
          _logger.i('❌ No se encontró usuario con teléfono: $phoneNumber');
        }
      }

      return response;
    } catch (error) {
      _logger.e('Error al buscar usuario por teléfono: $error');
      return null;
    }
  }

  /// Busca un usuario por email en la tabla 'profiles'
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    if (AppConfig.logDatabaseOperations) {
      _logger.i('🔍 Buscando usuario por email: $email');
    }

    try {
      final response =
          await _supabaseClient
              .from('profiles')
              .select()
              .eq('email', email)
              .maybeSingle();

      if (AppConfig.logDatabaseOperations) {
        if (response != null) {
          _logger.i('✅ Usuario encontrado por email: ${response['id']}');
        } else {
          _logger.i('❌ No se encontró usuario con email: $email');
        }
      }

      return response;
    } catch (error) {
      _logger.e('Error al buscar usuario por email: $error');
      return null;
    }
  }

  /// Verifica si ya existe una cuenta con [identifier] (teléfono o email).
  /// Llama a la Edge Function `check-account`, que usa la service_role key
  /// EN EL SERVIDOR (nunca en la app) y solo devuelve un booleano.
  Future<bool> checkUserExistsAdmin(
    String identifier, {
    bool isEmail = false,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'check-account',
        body: {'identifier': identifier, 'isEmail': isEmail},
      );
      final data = response.data;
      if (data is Map && data['exists'] is bool) {
        return data['exists'] as bool;
      }
      // Ante respuesta inesperada, es más seguro asumir que existe
      // (bloquea registros duplicados; el login mostrará credenciales inválidas)
      _logger.w('Respuesta inesperada de check-account: $data');
      return true;
    } catch (e) {
      _logger.e('❌ Error verificando la cuenta vía edge function: $e');
      // Fail-closed: no permitir avanzar si no se pudo verificar
      throw Exception('No se pudo verificar la cuenta. Revisa tu conexión.');
    }
  }

  /// Asigna el email al usuario autenticado vía Edge Function `set-user-email`
  /// (la service_role key vive en el servidor, no en la app). El usuario se
  /// identifica por su JWT dentro de la función.
  Future<void> updateAuthEmail({
    required String userId,
    required String email,
  }) async {
    try {
      await _supabaseClient.functions.invoke(
        'set-user-email',
        body: {'email': email},
      );
      _logger.i('✅ Email actualizado en Auth vía edge function');
    } on FunctionException catch (e) {
      // invoke() lanza en respuestas no-2xx; extraer el mensaje del servidor
      // (p. ej. el 409 "Ya existe una cuenta con este correo.").
      final details = e.details;
      final message =
          (details is Map && details['error'] is String)
              ? details['error'] as String
              : 'No se pudo actualizar el correo.';
      _logger.e('❌ set-user-email falló: $message');
      throw Exception(message);
    } catch (e) {
      _logger.e('❌ Error actualizando email vía edge function: $e');
      rethrow;
    }
  }
}
