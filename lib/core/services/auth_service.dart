import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:windwaker/core/repositories/user_repository.dart';

class AuthService {
  final SharedPreferences _prefs;
  final SupabaseClient _supabaseClient;
  final _logger = Logger();
  final UserRepository? _userRepository;

  AuthService({
    required SharedPreferences prefs,
    SupabaseClient? supabaseClient,
    UserRepository? userRepository,
  }) : _prefs = prefs,
       _supabaseClient = supabaseClient ?? Supabase.instance.client,
       _userRepository = userRepository;

  /// Verifica si el usuario está autenticado y tiene un perfil completo
  bool isAuthenticated() {
    // Verificar si hay un usuario en Supabase Auth
    final user = _supabaseClient.auth.currentUser;
    if (user != null) {
      _logger.i('Usuario autenticado en Supabase: ${user.id}');
      return true;
    }

    // Verificar si hay información guardada en SharedPreferences
    final phone = _prefs.getString('user_phone');
    if (phone != null && phone.isNotEmpty) {
      _logger.i('Usuario autenticado en SharedPreferences');
      return true;
    }

    _logger.w('No hay usuario autenticado');
    return false;
  }

  /// Verifica si el perfil del usuario está completo (tiene email)
  bool isProfileComplete() {
    // Verificar si hay email guardado en SharedPreferences
    final email = _prefs.getString('user_email');
    if (email != null && email.isNotEmpty) {
      return true;
    }

    // Si no hay en SharedPreferences, verificar en Supabase Auth
    final user = _supabaseClient.auth.currentUser;
    return user?.email != null && user!.email!.isNotEmpty;
  }

  /// Obtiene el email del usuario
  String? getUserEmail() {
    // Primero intentar obtener de SharedPreferences
    final email = _prefs.getString('user_email');
    if (email != null && email.isNotEmpty) {
      return email;
    }

    // Si no hay en SharedPreferences, obtener de Supabase Auth
    final user = _supabaseClient.auth.currentUser;
    return user?.email;
  }

  /// Obtiene el teléfono del usuario
  String? getUserPhone() {
    // Primero intentar obtener de SharedPreferences
    final phone = _prefs.getString('user_phone');
    if (phone != null && phone.isNotEmpty) {
      return phone;
    }

    // Si no hay en SharedPreferences, obtener de Supabase Auth
    final user = _supabaseClient.auth.currentUser;
    return user?.phone;
  }

  /// Verifica y refresca la sesión si es necesario
  Future<bool> verifyAndRefreshSession() async {
    try {
      _logger.i('Verificando sesión de Supabase...');

      // Obtener la sesión actual
      final session = _supabaseClient.auth.currentSession;

      // Si no hay sesión, intentar recuperarla
      if (session == null) {
        _logger.w('No hay sesión activa, intentando recuperar...');

        // Intentar recuperar la sesión
        try {
          final authResponse = await _supabaseClient.auth.recoverSession('');
          if (authResponse.session != null) {
            _logger.i('Sesión recuperada con éxito');
            await _updateUserData(authResponse.user, authResponse.session);
            return true;
          } else {
            _logger.w('No se pudo recuperar la sesión');
            return false;
          }
        } catch (e) {
          _logger.e('Error al recuperar sesión: $e');
          return false;
        }
      }

      // Verificar si la sesión está por expirar (menos de 1 hora)
      final expiresAt = session.expiresAt;
      if (expiresAt != null) {
        final now = DateTime.now().millisecondsSinceEpoch / 1000;
        final expiresInSeconds = expiresAt - now;

        _logger.i('La sesión expira en $expiresInSeconds segundos');

        // Si expira en menos de 1 hora, refrescar
        if (expiresInSeconds < 3600) {
          _logger.i('La sesión expira pronto, refrescando...');

          try {
            final response = await _supabaseClient.auth.refreshSession();

            if (response.session != null) {
              _logger.i('Sesión refrescada con éxito');
              await _updateUserData(response.user, response.session);
              return true;
            } else {
              _logger.w('No se pudo refrescar la sesión');
              return false;
            }
          } catch (e) {
            _logger.e('Error al refrescar la sesión: $e');

            // Intentar reconectar si hay un error
            try {
              _logger.i('Intentando reconectar...');
              await _supabaseClient.auth.refreshSession();
              _logger.i('Reconexión exitosa');
              return true;
            } catch (reconnectError) {
              _logger.e('Error al reconectar: $reconnectError');
              return false;
            }
          }
        }
      }

      _logger.i('La sesión está activa y válida');
      return true;
    } catch (e) {
      _logger.e('Error general al verificar/refrescar la sesión: $e');
      return false;
    }
  }

  /// Actualiza los datos del usuario en SharedPreferences y en la base de datos
  Future<void> _updateUserData(User? user, Session? session) async {
    if (user == null) return;

    // Actualizar datos en SharedPreferences
    if (user.email != null) {
      await _prefs.setString('user_email', user.email!);
    }
    if (user.phone != null) {
      await _prefs.setString('user_phone', user.phone!);
    }

    // Guardar información de la sesión
    if (session != null) {
      await _prefs.setString(
        'session_expires_at',
        (session.expiresAt ?? 0).toString(),
      );
      await _prefs.setString(
        'session_refresh_token',
        session.refreshToken ?? '',
      );
    }

    // Actualizar perfil en la base de datos
    if (_userRepository != null) {
      try {
        await _userRepository.createOrUpdateUserProfile(
          userId: user.id,
          email: user.email,
          phone: user.phone,
        );
        _logger.i('Perfil actualizado durante verificación de sesión');
      } catch (e) {
        _logger.e(
          'Error al actualizar perfil durante verificación de sesión: $e',
        );
      }
    }
  }

  /// Cierra la sesión del usuario
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      // Limpiar datos guardados
      await _prefs.remove('user_email');
      await _prefs.remove('user_phone');
      await _prefs.remove('session_expires_at');
      await _prefs.remove('session_refresh_token');
      _logger.i('Sesión cerrada correctamente');
    } catch (e) {
      _logger.e('Error al cerrar sesión: $e');
    }
  }
}
