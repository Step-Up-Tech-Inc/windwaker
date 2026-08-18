import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwaker/core/repositories/user_repository.dart';
import 'package:logger/logger.dart';

/// Servicio para validar perfiles de usuario usando la BD como fuente de verdad
class ProfileValidationService {
  final UserRepository _userRepository;
  final _logger = Logger();

  ProfileValidationService(this._userRepository);

  /// Verificar si un usuario tiene perfil completo en la BD
  Future<bool> isProfileComplete(String userId) async {
    try {
      _logger.i('🔍 Validando perfil completo para usuario: $userId');

      final profile = await _userRepository.getUserProfile(userId);

      if (profile == null) {
        _logger.w('⚠️ No se encontró perfil para usuario: $userId');
        return false;
      }

      final hasRequiredFields =
          profile['email'] != null &&
          profile['email'].toString().isNotEmpty &&
          profile['phone'] != null &&
          profile['phone'].toString().isNotEmpty;

      _logger.i('✅ Perfil validado: $hasRequiredFields');
      _logger.i('📧 Email: ${profile['email']}');
      _logger.i('📱 Phone: ${profile['phone']}');

      return hasRequiredFields;
    } catch (e) {
      _logger.e('❌ Error validando perfil: $e');
      return false;
    }
  }

  /// Verificar si un usuario existe en la BD
  Future<bool> userExists(String userId) async {
    try {
      final profile = await _userRepository.getUserProfile(userId);
      return profile != null;
    } catch (e) {
      _logger.e('❌ Error verificando existencia de usuario: $e');
      return false;
    }
  }

  /// Obtener perfil completo del usuario
  Future<Map<String, dynamic>?> getUserProfileData(String userId) async {
    try {
      final profile = await _userRepository.getUserProfile(userId);
      if (profile != null) {
        return {
          'id': profile['id'],
          'email': profile['email'],
          'phone': profile['phone'],
          'full_name': profile['full_name'],
          'avatar_url': profile['avatar_url'],
          'role': profile['role'],
          'created_at': profile['created_at'],
          'updated_at': profile['updated_at'],
        };
      }
      return null;
    } catch (e) {
      _logger.e('❌ Error obteniendo datos del perfil: $e');
      return null;
    }
  }

  /// Verificar si la sesión actual es válida comparando con la BD
  Future<bool> isCurrentSessionValid() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        _logger.w('⚠️ No hay usuario autenticado en Supabase Auth');
        return false;
      }

      // Verificar que el usuario existe en la BD
      final existsInDB = await userExists(currentUser.id);
      if (!existsInDB) {
        _logger.w('⚠️ Usuario no existe en la BD: ${currentUser.id}');
        return false;
      }

      // Verificar que el perfil esté completo
      final isComplete = await isProfileComplete(currentUser.id);

      _logger.i('✅ Sesión válida: $isComplete');
      return isComplete;
    } catch (e) {
      _logger.e('❌ Error validando sesión actual: $e');
      return false;
    }
  }
}
