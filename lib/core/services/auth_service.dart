import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:windwaker/core/repositories/user_repository.dart';

class AuthService {
  final SharedPreferences _prefs;
  final SupabaseClient _supabaseClient;
  final _logger = Logger();
  final UserRepository _userRepository;

  AuthService({
    required SharedPreferences prefs,
    SupabaseClient? supabaseClient,
    required UserRepository userRepository,
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

  /// Verifica y refresca la sesión de Supabase
  Future<bool> verifyAndRefreshSession() async {
    try {
      _logger.i('Verificando sesión de Supabase...');

      // Verificar si hay una sesión activa
      final session = _supabaseClient.auth.currentSession;
      if (session == null) {
        _logger.w('No hay sesión activa, intentando recuperar...');

        // Intentar recuperar la sesión usando datos de SharedPreferences
        final phone = _prefs.getString('user_phone');
        if (phone != null) {
          _logger.i('Encontrado teléfono en SharedPreferences: $phone');

          // Intentar buscar el perfil por teléfono
          try {
            final data =
                await _supabaseClient
                    .from('profiles')
                    .select('id, email, phone')
                    .eq('phone', phone)
                    .maybeSingle();

            if (data != null) {
              _logger.i('Encontrado perfil por teléfono: $data');

              // Guardar el email en SharedPreferences si existe
              if (data['email'] != null) {
                await _prefs.setString('user_email', data['email'] as String);
                _logger.i(
                  'Email guardado en SharedPreferences: ${data['email']}',
                );
              }

              // Intentar iniciar sesión nuevamente
              _logger.i('Intentando iniciar sesión con teléfono encontrado...');
              return false; // No pudimos recuperar la sesión automáticamente
            } else {
              _logger.w('No se encontró perfil para el teléfono: $phone');
            }
          } catch (e) {
            _logger.e('Error al buscar perfil por teléfono: $e');
          }
        }

        return false;
      }

      // Refrescar la sesión
      _logger.i('Refrescando sesión...');
      final response = await _supabaseClient.auth.refreshSession();
      if (response.session != null) {
        _logger.i('Sesión refrescada con éxito');

        // Actualizar datos del usuario si es necesario
        final user = _supabaseClient.auth.currentUser;
        if (user != null) {
          // Verificar si el perfil existe en la tabla profiles
          try {
            final profile = await _userRepository.getUserProfile(user.id);

            // Obtener datos de SharedPreferences
            final phone = _prefs.getString('user_phone');
            final email = _prefs.getString('user_email') ?? user.email;

            if (profile == null) {
              _logger.w(
                'No se encontró perfil para el usuario, creando uno nuevo',
              );

              // Crear perfil usando SQL directo para garantizar que se guarde correctamente
              try {
                final createSql = '''
                INSERT INTO profiles (id, email, phone, created_at, updated_at)
                VALUES ('${user.id}', ${email != null ? "'$email'" : 'NULL'}, ${phone != null ? "'$phone'" : 'NULL'}, NOW(), NOW())
                ON CONFLICT (id) 
                DO UPDATE SET 
                  email = COALESCE(EXCLUDED.email, profiles.email),
                  phone = COALESCE(EXCLUDED.phone, profiles.phone),
                  updated_at = NOW();
                ''';

                await _supabaseClient.rpc(
                  'exec_sql',
                  params: {'sql': createSql},
                );
                _logger.i('Perfil creado con SQL directo');

                // Verificar que el perfil se creó correctamente
                final createdProfile = await _userRepository.getUserProfile(
                  user.id,
                );
                _logger.i('Perfil creado: $createdProfile');

                // Si el email no se guardó correctamente, intentar nuevamente
                if (email != null &&
                    email.isNotEmpty &&
                    (createdProfile == null ||
                        createdProfile['email'] != email)) {
                  _logger.w(
                    'El email no se guardó correctamente, intentando nuevamente',
                  );

                  final emailUpdateSql = '''
                  UPDATE profiles SET email = '$email', updated_at = NOW()
                  WHERE id = '${user.id}';
                  ''';

                  await _supabaseClient.rpc(
                    'exec_sql',
                    params: {'sql': emailUpdateSql},
                  );
                  _logger.i(
                    'Email actualizado con SQL directo (segundo intento)',
                  );
                }
              } catch (sqlError) {
                _logger.e('Error al crear perfil con SQL directo: $sqlError');

                // Usar el método normal como respaldo
                await _userRepository.createOrUpdateUserProfile(
                  userId: user.id,
                  email: email,
                  phone: phone,
                );
                _logger.i('Perfil creado usando el método normal');
              }
            } else {
              _logger.i('Perfil encontrado: $profile');

              // Verificar si el email y teléfono están actualizados
              bool needsUpdate = false;

              if (email != null &&
                  email.isNotEmpty &&
                  profile['email'] != email) {
                _logger.w('Email desactualizado en el perfil');
                needsUpdate = true;
              }

              if (phone != null &&
                  phone.isNotEmpty &&
                  profile['phone'] != phone) {
                _logger.w('Teléfono desactualizado en el perfil');
                needsUpdate = true;
              }

              if (needsUpdate) {
                _logger.i('Actualizando perfil...');

                try {
                  // Construir la parte SET del SQL
                  String setSql = "";
                  if (email != null && email.isNotEmpty)
                    setSql += "email = '$email', ";
                  if (phone != null && phone.isNotEmpty)
                    setSql += "phone = '$phone', ";
                  setSql += "updated_at = NOW()";

                  final updateSql = '''
                  UPDATE profiles SET $setSql
                  WHERE id = '${user.id}';
                  ''';

                  await _supabaseClient.rpc(
                    'exec_sql',
                    params: {'sql': updateSql},
                  );
                  _logger.i('Perfil actualizado con SQL directo');

                  // Verificar actualización
                  final updatedProfile = await _userRepository.getUserProfile(
                    user.id,
                  );
                  _logger.i('Perfil actualizado: $updatedProfile');

                  // Si el email en auth.users es diferente al de SharedPreferences, actualizarlo
                  if (email != null &&
                      email.isNotEmpty &&
                      (user.email == null || user.email != email)) {
                    try {
                      await _supabaseClient.auth.updateUser(
                        UserAttributes(email: email),
                      );
                      _logger.i('Email actualizado en auth.users: $email');
                    } catch (e) {
                      _logger.e('Error al actualizar email en auth.users: $e');
                    }
                  }
                } catch (e) {
                  _logger.e('Error al actualizar perfil: $e');

                  // Usar el método normal como respaldo
                  await _userRepository.createOrUpdateUserProfile(
                    userId: user.id,
                    email: email,
                    phone: phone,
                  );
                  _logger.i('Perfil actualizado usando el método normal');
                }
              } else {
                _logger.i('Perfil ya está actualizado');
              }
            }
          } catch (e) {
            _logger.e('Error al verificar/actualizar perfil: $e');
          }
        }

        return true;
      } else {
        _logger.w('No se pudo refrescar la sesión');
        return false;
      }
    } catch (e) {
      _logger.e('Error al verificar/refrescar sesión: $e');
      return false;
    }
  }

  /// Actualiza los datos del usuario en SharedPreferences y en la tabla profiles
  Future<void> _updateUserData(User? user, Session? session) async {
    if (user == null) return;

    try {
      _logger.i('Actualizando datos de usuario: ${user.id}');

      // Guardar email si existe
      if (user.email != null && user.email!.isNotEmpty) {
        await _prefs.setString('user_email', user.email!);
        _logger.i('Email guardado en SharedPreferences: ${user.email}');
      }

      // Guardar teléfono si existe
      if (user.phone != null && user.phone!.isNotEmpty) {
        await _prefs.setString('user_phone', user.phone!);
        _logger.i('Teléfono guardado en SharedPreferences: ${user.phone}');
      }

      // Actualizar perfil en la tabla profiles
      await _userRepository.createOrUpdateUserProfile(
        userId: user.id,
        email: user.email,
        phone: user.phone,
      );
      _logger.i('Perfil actualizado en la tabla profiles');
    } catch (e) {
      _logger.e('Error al actualizar datos de usuario: $e');
    }
  }

  /// Actualiza el email del usuario
  Future<bool> updateUserEmail(String email) async {
    try {
      _logger.i('Actualizando email del usuario a: $email');

      // Actualizar en Supabase Auth
      final response = await _supabaseClient.auth.updateUser(
        UserAttributes(email: email),
      );

      if (response.user == null) {
        _logger.e('Error al actualizar email en Auth: usuario nulo');
        return false;
      }

      // Actualizar en SharedPreferences
      await _prefs.setString('user_email', email);
      _logger.i('Email actualizado en SharedPreferences');

      // Actualizar en la tabla profiles
      await _userRepository.createOrUpdateUserProfile(
        userId: response.user!.id,
        email: email,
        phone: response.user!.phone,
      );
      _logger.i('Email actualizado en la tabla profiles');

      return true;
    } catch (e) {
      _logger.e('Error al actualizar email del usuario: $e');
      return false;
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
