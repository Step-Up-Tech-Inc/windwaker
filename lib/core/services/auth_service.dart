import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/profile.dart';
import '../repositories/user_repository.dart';

// Clases de resultado
class AuthResult {
  final bool success;
  final String? userId;
  final String? error;
  final bool isNewUser;

  AuthResult._({
    required this.success,
    this.userId,
    this.error,
    this.isNewUser = false,
  });

  factory AuthResult.success(String userId, {bool isNewUser = false}) =>
      AuthResult._(success: true, userId: userId, isNewUser: isNewUser);
  factory AuthResult.failure(String error) =>
      AuthResult._(success: false, error: error);
}

class SmsResult {
  final bool success;
  final String message;

  SmsResult._({required this.success, required this.message});

  factory SmsResult.success(String message) =>
      SmsResult._(success: true, message: message);
  factory SmsResult.failure(String message) =>
      SmsResult._(success: false, message: message);
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  UserRepository? _userRepository;
  bool _isInitialized = false;

  /// Caché del perfil del usuario autenticado. Se invalida al cerrar sesión
  /// o cuando el perfil cambia (completar registro).
  Profile? _cachedProfile;

  void initialize(UserRepository userRepository) {
    if (_isInitialized) {
      if (AppConfig.logAuthFlow) {
        dev.log('AuthService ya está inicializado, omitiendo...');
      }
      return;
    }

    _userRepository = userRepository;
    _isInitialized = true;

    if (AppConfig.logAuthFlow) {
      dev.log('AuthService inicializado - Modo: ${AppConfig.modeDescription}');
    }
  }

  UserRepository get userRepository {
    if (_userRepository == null) {
      throw StateError(
        'AuthService no ha sido inicializado. Llama a initialize() primero.',
      );
    }
    return _userRepository!;
  }

  // Verificar si hay una sesión activa
  Future<bool> hasActiveSession() async {
    try {
      if (AppConfig.logAuthFlow) {
        dev.log('Verificando sesión activa - Modo: ${AppConfig.currentMode}');
      }

      switch (AppConfig.currentMode) {
        case AppMode.bypass:
          return await _hasActiveBypassSession();
        case AppMode.testing:
        case AppMode.production:
          return await _hasActiveSupabaseSession();
      }
    } catch (e) {
      if (AppConfig.enableDetailedLogging) {
        dev.log('Error verificando sesión activa: $e');
      }
      return false;
    }
  }

  /// Verifica el límite de intentos contra la BD (ventana deslizante).
  /// Devuelve true si la acción está permitida. Ante error de red, permite
  /// (no bloquear al usuario legítimo por un fallo transitorio).
  Future<bool> _withinRateLimit({
    required String action,
    required String identifier,
    required int maxAttempts,
    int windowSeconds = 900,
  }) async {
    try {
      final allowed = await _supabase.rpc(
        'check_rate_limit',
        params: {
          'p_action': action,
          'p_identifier': identifier.toLowerCase(),
          'p_max_attempts': maxAttempts,
          'p_window_seconds': windowSeconds,
        },
      );
      return allowed != false;
    } catch (e) {
      if (AppConfig.enableDetailedLogging) {
        dev.log('Rate limit no disponible ($action): $e');
      }
      return true;
    }
  }

  // Autenticar con código SMS
  Future<AuthResult> authenticateWithSmsCode({
    required String phoneNumber,
    required String smsCode,
  }) async {
    try {
      if (AppConfig.logAuthFlow) {
        dev.log('=== INICIANDO AUTENTICACIÓN ===');
        dev.log('Modo actual: ${AppConfig.currentMode}');
        dev.log('Modo descripción: ${AppConfig.modeDescription}');
        dev.log('Teléfono: $phoneNumber');
        dev.log('Código: $smsCode');
        dev.log('Código testing esperado: ${AppConfig.testingCode}');
        dev.log('Código bypass esperado: ${AppConfig.bypassCode}');
      }

      AuthResult result;

      switch (AppConfig.currentMode) {
        case AppMode.bypass:
          dev.log('🔄 Usando modo BYPASS');
          result = await _authenticateBypass(phoneNumber, smsCode);
          break;
        case AppMode.testing:
          dev.log('🔄 Usando modo TESTING');
          result = await _authenticateTesting(phoneNumber, smsCode);
          break;
        case AppMode.production:
          dev.log('🔄 Usando modo PRODUCCIÓN');
          result = await _authenticateProduction(phoneNumber, smsCode);
          break;
      }

      if (AppConfig.logAuthFlow) {
        dev.log('📤 RESULTADO FINAL:');
        dev.log('📤 - success: ${result.success}');
        dev.log('📤 - userId: ${result.userId}');
        dev.log('📤 - error: ${result.error}');
      }

      return result;
    } catch (e) {
      if (AppConfig.enableDetailedLogging) {
        dev.log('❌ Error en autenticación: $e');
      }
      return AuthResult.failure('Error de autenticación: $e');
    }
  }

  // Enviar código SMS para REGISTRO (el número no debe existir todavía)
  Future<SmsResult> sendRegistrationSms(String phoneNumber) async {
    try {
      if (AppConfig.logAuthFlow) {
        dev.log('Enviando SMS de registro - Teléfono: $phoneNumber');
        dev.log('Modo: ${AppConfig.currentMode}');
      }

      // Rate limit: 5 solicitudes de registro por número cada 15 minutos
      final allowed = await _withinRateLimit(
        action: 'register_sms',
        identifier: phoneNumber,
        maxAttempts: 5,
      );
      if (!allowed) {
        return SmsResult.failure(
          'Demasiados intentos. Espera 15 minutos e inténtalo de nuevo.',
        );
      }

      // Validar si el usuario existe de forma SEGURA usando la Admin API
      // Esto evita problemas con RLS que antes hacían creer a la app que
      // no existían cuentas cuando en realidad sí estaban creadas.
      try {
        final userExists = await userRepository.checkUserExistsAdmin(phoneNumber);

        if (userExists) {
          if (AppConfig.logAuthFlow) {
            dev.log('⚠️ Usuario ya existe - Bloqueando nuevo registro');
          }
          return SmsResult.failure(
            'Este número ya está registrado. Por favor inicia sesión.',
          );
        }
      } catch (e) {
        if (AppConfig.logAuthFlow) {
          dev.log('❌ ERROR verificando usuario (Admin API): $e');
        }
        // Si hay error en la validación, es más seguro bloquear
        return SmsResult.failure(
          'Error verificando cuenta. Por favor comprueba tu conexión y la configuración.',
        );
      }

      switch (AppConfig.currentMode) {
        case AppMode.bypass:
          return _sendSmsCodeBypass(phoneNumber);
        case AppMode.testing:
          return await _sendSmsCodeTesting(phoneNumber);
        case AppMode.production:
          return await _sendSmsCodeProduction(phoneNumber);
      }
    } catch (e) {
      if (AppConfig.enableDetailedLogging) {
        dev.log('Error enviando SMS: $e');
      }
      return SmsResult.failure('Error enviando SMS: $e');
    }
  }

  // Iniciar sesión con correo o teléfono + contraseña
  Future<AuthResult> signInWithPassword({
    required String identifier,
    required String password,
  }) async {
    try {
      if (AppConfig.logAuthFlow) {
        dev.log('=== LOGIN CON CONTRASEÑA ===');
        dev.log('Identificador: $identifier');
      }

      // Rate limit: 5 intentos por identificador cada 15 minutos
      final allowed = await _withinRateLimit(
        action: 'login',
        identifier: identifier,
        maxAttempts: 5,
      );
      if (!allowed) {
        return AuthResult.failure(
          'Demasiados intentos de inicio de sesión. '
          'Espera 15 minutos e inténtalo de nuevo.',
        );
      }

      final bool isEmail = identifier.contains('@');
      final AuthResponse response;

      if (isEmail) {
        response = await _supabase.auth.signInWithPassword(
          email: identifier,
          password: password,
        );
      } else {
        response = await _supabase.auth.signInWithPassword(
          phone: identifier,
          password: password,
        );
      }

      if (response.user == null) {
        return AuthResult.failure('Correo/teléfono o contraseña incorrectos.');
      }

      if (AppConfig.logAuthFlow) {
        dev.log('✅ Login exitoso - UserID: ${response.user!.id}');
      }

      return AuthResult.success(response.user!.id);
    } on AuthException catch (e) {
      if (AppConfig.logAuthFlow) {
        dev.log('❌ AuthException en login: ${e.message}');
      }
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        return AuthResult.failure('Correo/teléfono o contraseña incorrectos.');
      }
      return AuthResult.failure(e.message);
    } catch (e) {
      if (AppConfig.enableDetailedLogging) {
        dev.log('❌ Error inesperado en login: $e');
      }
      return AuthResult.failure('Error iniciando sesión: $e');
    }
  }

  // Completar el registro: asigna email + contraseña al usuario ya verificado
  // por teléfono y guarda el perfil en la tabla profiles.
  Future<AuthResult> completeRegistration({
    required String email,
    required String password,
    String? phone,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return AuthResult.failure(
        'Tu sesión expiró. Por favor verifica tu número nuevamente.',
      );
    }

    try {
      if (AppConfig.logAuthFlow) {
        dev.log('=== COMPLETANDO REGISTRO ===');
        dev.log('UserID: ${user.id} | email: $email');
      }

      // El correo no debe pertenecer a otra cuenta
      final emailTaken = await userRepository.checkUserExistsAdmin(
        email,
        isEmail: true,
      );
      if (emailTaken) {
        return AuthResult.failure('Ya existe una cuenta con este correo.');
      }

      // 1. Asignar la contraseña al usuario autenticado
      await _supabase.auth.updateUser(UserAttributes(password: password));

      // 2. Asignar el email vía Admin API (queda confirmado sin correo de verificación)
      await userRepository.updateAuthEmail(userId: user.id, email: email);

      // 3. Guardar el perfil completo. Se prefiere el teléfono normalizado (+506...)
      //    del flujo de registro sobre user.phone, que Supabase guarda sin '+'.
      final String? profilePhone =
          (phone != null && phone.isNotEmpty) ? phone : user.phone;
      await userRepository.createOrUpdateUserProfile(
        userId: user.id,
        email: email,
        phone: profilePhone,
      );

      // El perfil cambió: invalidar caché para que se recargue con rol actual
      _cachedProfile = null;

      if (AppConfig.logAuthFlow) {
        dev.log('✅ Registro completado para ${user.id}');
      }

      return AuthResult.success(user.id, isNewUser: true);
    } on AuthException catch (e) {
      if (AppConfig.logAuthFlow) {
        dev.log('❌ AuthException completando registro: ${e.message}');
      }
      return AuthResult.failure(e.message);
    } catch (e) {
      if (AppConfig.enableDetailedLogging) {
        dev.log('❌ Error completando registro: $e');
      }
      return AuthResult.failure('No se pudo completar el registro: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      if (AppConfig.logAuthFlow) {
        dev.log('Cerrando sesión');
      }
      _cachedProfile = null;
      await _supabase.auth.signOut();
    } catch (e) {
      if (AppConfig.enableDetailedLogging) {
        dev.log('Error cerrando sesión: $e');
      }
      rethrow;
    }
  }

  // Métodos de compatibilidad con AuthService original
  bool isAuthenticated() {
    final user = _supabase.auth.currentUser;
    final session = _supabase.auth.currentSession;

    if (AppConfig.logAuthFlow) {
      dev.log('🔍 === isAuthenticated() LLAMADO ===');
      dev.log('🔍 currentUser: ${user?.id ?? 'NULL'}');
      dev.log('🔍 currentSession: ${session != null ? 'ACTIVA' : 'INACTIVA'}');
      dev.log('🔍 Retornando: ${user != null}');
    }

    return user != null;
  }

  // CRÍTICO: Forzar verificación de sesión inmediata
  Future<bool> forceSessionVerification() async {
    try {
      if (AppConfig.logAuthFlow) {
        dev.log('🔍 === FORZANDO VERIFICACIÓN DE SESIÓN ===');
      }

      // Verificar si ya hay una sesión activa
      final currentUser = _supabase.auth.currentUser;
      final currentSession = _supabase.auth.currentSession;

      if (AppConfig.logAuthFlow) {
        dev.log(
          '🔍 Usuario actual antes de verificación: ${currentUser?.id ?? 'NULL'}',
        );
        dev.log(
          '🔍 Sesión actual antes de verificación: ${currentSession != null ? 'ACTIVA' : 'INACTIVA'}',
        );
      }

      // Si ya hay sesión activa, solo esperar un poco y verificar
      if (currentUser != null && currentSession != null) {
        if (AppConfig.logAuthFlow) {
          dev.log('🔍 Sesión ya activa, esperando estabilización...');
        }

        // Esperar un poco para que Supabase estabilice la sesión
        await Future.delayed(const Duration(milliseconds: 1000));

        // Verificar que la sesión siga activa
        final finalUser = _supabase.auth.currentUser;
        final finalSession = _supabase.auth.currentSession;

        if (AppConfig.logAuthFlow) {
          dev.log(
            '🔍 Usuario después de estabilización: ${finalUser?.id ?? 'NULL'}',
          );
          dev.log(
            '🔍 Sesión después de estabilización: ${finalSession != null ? 'ACTIVA' : 'INACTIVA'}',
          );
          dev.log('🔍 isAuthenticated(): ${finalUser != null}');
        }

        return finalUser != null;
      } else {
        if (AppConfig.logAuthFlow) {
          dev.log('❌ No hay sesión activa para verificar');
        }
        return false;
      }
    } catch (e) {
      if (AppConfig.logAuthFlow) {
        dev.log('❌ Error forzando verificación de sesión: $e');
      }
      return false;
    }
  }

  bool isProfileComplete() {
    // Método síncronos simple - solo verificar si hay usuario
    // La verificación real del perfil se hace en hasActiveSession
    return isAuthenticated();
  }

  /// Perfil tipado del usuario autenticado (con caché por sesión).
  Future<Profile?> getCurrentProfileTyped({bool forceRefresh = false}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _cachedProfile = null;
        return null;
      }

      if (!forceRefresh && _cachedProfile?.id == user.id) {
        return _cachedProfile;
      }

      _cachedProfile = await userRepository.getProfile(user.id);

      if (AppConfig.logAuthFlow) {
        dev.log(
          'Perfil cargado: ${_cachedProfile?.id} '
          '(rol: ${_cachedProfile?.role}, completo: ${_cachedProfile?.isComplete})',
        );
      }

      return _cachedProfile;
    } catch (e) {
      if (AppConfig.enableDetailedLogging) {
        dev.log('Error obteniendo perfil tipado: $e');
      }
      return null;
    }
  }

  /// Rol del usuario autenticado. Por defecto cliente.
  Future<UserRole> getCurrentRole() async {
    final profile = await getCurrentProfileTyped();
    return profile?.role ?? UserRole.customer;
  }

  // Verificar perfil completo (email + teléfono en la tabla profiles)
  Future<bool> isProfileCompleteAsync() async {
    final profile = await getCurrentProfileTyped(forceRefresh: true);
    return profile?.isComplete ?? false;
  }

  String? getUserEmail() {
    return _supabase.auth.currentUser?.email;
  }

  String? getUserPhone() {
    return _supabase.auth.currentUser?.phone;
  }

  Future<bool> verifyAndRefreshSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return false;

      // Intentar refrescar la sesión si está cerca de expirar
      await _supabase.auth.refreshSession();
      return true;
    } catch (e) {
      if (AppConfig.enableDetailedLogging) {
        dev.log('Error verificando sesión: $e');
      }
      return false;
    }
  }

  // Obtener perfil actual
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    try {
      if (AppConfig.logAuthFlow) {
        dev.log('=== OBTENIENDO PERFIL ACTUAL ===');
      }

      final user = _supabase.auth.currentUser;

      if (AppConfig.logAuthFlow) {
        dev.log('Usuario actual: ${user?.id ?? 'null'}');
        if (user != null) {
          dev.log('Email en auth: ${user.email ?? 'null'}');
          dev.log('Phone en auth: ${user.phone ?? 'null'}');
        }
      }

      if (user == null) {
        if (AppConfig.logAuthFlow) {
          dev.log('No hay usuario autenticado, retornando null');
        }
        return null;
      }

      if (AppConfig.logAuthFlow) {
        dev.log('Consultando perfil en BD para user: ${user.id}');
      }

      final profile = await userRepository.getUserProfile(user.id);

      if (AppConfig.logAuthFlow) {
        dev.log(
          'Perfil obtenido de BD: ${profile != null ? 'EXISTE' : 'NULL'}',
        );
        if (profile != null) {
          dev.log('Perfil email: ${profile['email'] ?? 'null'}');
          dev.log('Perfil phone: ${profile['phone'] ?? 'null'}');
          dev.log('Perfil completo: $profile');
        }
      }

      return profile;
    } catch (e) {
      if (AppConfig.enableDetailedLogging) {
        dev.log('Error obteniendo perfil actual: $e');
      }
      return null;
    }
  }

  // MÉTODOS PRIVADOS PARA CADA MODO

  Future<bool> _hasActiveBypassSession() async {
    // En bypass, verificar si hay usuario y perfil en DB
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final profile = await userRepository.getUserProfile(user.id);
    return profile != null;
  }

  Future<bool> _hasActiveSupabaseSession() async {
    final user = _supabase.auth.currentUser;

    if (AppConfig.logAuthFlow) {
      dev.log('Usuario Supabase: ${user?.id ?? 'null'}');
    }

    return user != null;
  }

  Future<AuthResult> _authenticateBypass(
    String phoneNumber,
    String smsCode,
  ) async {
    if (smsCode == AppConfig.bypassCode) {
      try {
        // Verificar si ya hay un usuario autenticado
        User? user = _supabase.auth.currentUser;

        if (user == null) {
          // Solo crear nuevo usuario si no hay ninguno
          final authResponse = await _supabase.auth.signUp(
            phone: phoneNumber,
            password: AppConfig.defaultPassword,
          );

          if (authResponse.user == null) {
            return AuthResult.failure('Error creando sesión bypass');
          }

          user = authResponse.user!;

          if (AppConfig.logAuthFlow) {
            dev.log('Usuario bypass creado con phone: $phoneNumber');
          }
        } else {
          if (AppConfig.logAuthFlow) {
            dev.log('Usuario bypass existente encontrado - UserID: ${user.id}');
          }
        }

        if (AppConfig.logAuthFlow) {
          dev.log('Autenticación bypass exitosa - UserID: ${user.id}');
          dev.log('Phone en auth: ${user.phone}');
        }

        return AuthResult.success(user.id);
      } catch (e) {
        return AuthResult.failure('Error en bypass: $e');
      }
    }

    return AuthResult.failure('Código de bypass inválido');
  }

  Future<AuthResult> _authenticateTesting(
    String phoneNumber,
    String smsCode,
  ) async {
    if (AppConfig.logAuthFlow) {
      dev.log('=== INICIANDO _authenticateTesting ===');
      dev.log('phoneNumber: $phoneNumber');
      dev.log('smsCode: $smsCode');
      dev.log('testingCode esperado: ${AppConfig.testingCode}');
    }

    if (smsCode == AppConfig.testingCode) {
      try {
        // En modo testing, verificar si ya hay un usuario autenticado
        User? user = _supabase.auth.currentUser;

        if (AppConfig.logAuthFlow) {
          dev.log('Usuario actual en testing: ${user?.id ?? 'null'}');
        }

        if (user != null) {
          // Si ya hay usuario, usarlo directamente (viene del OTP verification)
          if (AppConfig.logAuthFlow) {
            dev.log(
              '✅ Usuario testing existente encontrado - UserID: ${user.id}',
            );
            dev.log('✅ Phone en auth: ${user.phone}');
          }

          return AuthResult.success(user.id);
        } else {
          if (AppConfig.logAuthFlow) {
            dev.log(
              '🔄 No hay usuario autenticado, iniciando flujo de testing...',
            );
          }

          // NUEVO ENFOQUE: Usar signInWithOtp + verifyOtp para confirmar el usuario
          try {
            // 1. Enviar OTP (esto crea o encuentra el usuario)
            await _supabase.auth.signInWithOtp(phone: phoneNumber);

            if (AppConfig.logAuthFlow) {
              dev.log(
                '📝 OTP enviado para testing (será verificado con código fijo)',
              );
            }

            // 2. Verificar con el código de testing
            final verifyResponse = await _supabase.auth.verifyOTP(
              phone: phoneNumber,
              token: AppConfig.testingCode,
              type: OtpType.sms,
            );

            if (AppConfig.logAuthFlow) {
              dev.log(
                '📝 Respuesta de verifyOTP: user=${verifyResponse.user?.id}',
              );
              dev.log(
                '📝 Session: ${verifyResponse.session != null ? 'EXISTE' : 'NULL'}',
              );
            }

            if (verifyResponse.user == null) {
              return AuthResult.failure('Error verificando código de testing');
            }

            user = verifyResponse.user!;

            if (AppConfig.logAuthFlow) {
              dev.log(
                '✅ Usuario testing verificado exitosamente: UserID=${user.id}',
              );
              dev.log('✅ Phone en auth: ${user.phone}');
              dev.log(
                '✅ Sesión activa: ${_supabase.auth.currentSession != null}',
              );
            }

            return AuthResult.success(user.id);
          } catch (e) {
            if (AppConfig.logAuthFlow) {
              dev.log('❌ ERROR en flujo de testing con verifyOtp: $e');
            }

            // Fallback al método anterior si verifyOtp falla
            return AuthResult.failure('Error en modo testing: $e');
          }
        }
      } catch (e) {
        if (AppConfig.logAuthFlow) {
          dev.log('❌ ERROR en _authenticateTesting: $e');
          dev.log('❌ Tipo de error: ${e.runtimeType}');
        }
        return AuthResult.failure('Error en modo testing: $e');
      }
    }

    if (AppConfig.logAuthFlow) {
      dev.log(
        '❌ Código de testing inválido - recibido: $smsCode, esperado: ${AppConfig.testingCode}',
      );
    }
    return AuthResult.failure('Código de testing inválido');
  }

  Future<AuthResult> _authenticateProduction(
    String phoneNumber,
    String smsCode,
  ) async {
    try {
      if (AppConfig.logAuthFlow) {
        dev.log('=== INICIANDO _authenticateProduction ===');
        dev.log('phoneNumber: $phoneNumber');
        dev.log('smsCode: $smsCode');
      }

      // Verificar el OTP con Supabase
      final authResponse = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: smsCode,
        phone: phoneNumber,
      );

      if (authResponse.user == null) {
        if (AppConfig.logAuthFlow) {
          dev.log('❌ Verificación OTP fallida - no hay usuario');
        }
        return AuthResult.failure('Código SMS inválido');
      }

      final user = authResponse.user!;

      if (AppConfig.logAuthFlow) {
        dev.log('✅ Verificación OTP exitosa - UserID: ${user.id}');
        dev.log('Phone en auth: ${user.phone}');
        dev.log('Email en auth: ${user.email}');
      }

      return AuthResult.success(user.id);
    } catch (e) {
      if (AppConfig.logAuthFlow) {
        dev.log('❌ Error en _authenticateProduction: $e');
      }
      return AuthResult.failure('Error de autenticación: $e');
    }
  }

  SmsResult _sendSmsCodeBypass(String phoneNumber) {
    if (AppConfig.logAuthFlow) {
      dev.log('Código bypass simulado: ${AppConfig.bypassCode}');
    }
    return SmsResult.success('Código bypass: ${AppConfig.bypassCode}');
  }

  Future<SmsResult> _sendSmsCodeTesting(String phoneNumber) async {
    if (AppConfig.logAuthFlow) {
      dev.log('Código testing simulado: ${AppConfig.testingCode}');
    }
    return SmsResult.success('Código testing: ${AppConfig.testingCode}');
  }

  Future<SmsResult> _sendSmsCodeProduction(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phoneNumber);
      return SmsResult.success('Código SMS enviado');
    } catch (e) {
      return SmsResult.failure('Error enviando SMS: $e');
    }
  }
}
