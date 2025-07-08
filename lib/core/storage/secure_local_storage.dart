import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

/// Implementación de almacenamiento local seguro para Supabase
class SecureLocalStorage implements LocalStorage {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final _logger = Logger();

  // Clave para almacenar el token de acceso
  static const String _accessTokenKey = 'supabase_access_token';

  // Clave para almacenar el token de refresco
  static const String _refreshTokenKey = 'supabase_refresh_token';

  // Métodos personalizados para almacenamiento general
  Future<String?> getStorageItem({required String key}) async {
    try {
      final value = await _secureStorage.read(key: key);
      _logger.d('SecureLocalStorage: Obtenido valor para clave: $key');
      return value;
    } catch (e) {
      _logger.e(
        'SecureLocalStorage: Error al obtener valor para clave: $key - $e',
      );
      return null;
    }
  }

  Future<void> setStorageItem({
    required String key,
    required String value,
  }) async {
    try {
      await _secureStorage.write(key: key, value: value);
      _logger.d('SecureLocalStorage: Valor guardado para clave: $key');
    } catch (e) {
      _logger.e(
        'SecureLocalStorage: Error al guardar valor para clave: $key - $e',
      );
    }
  }

  Future<void> removeStorageItem({required String key}) async {
    try {
      await _secureStorage.delete(key: key);
      _logger.d('SecureLocalStorage: Valor eliminado para clave: $key');
    } catch (e) {
      _logger.e(
        'SecureLocalStorage: Error al eliminar valor para clave: $key - $e',
      );
    }
  }

  // Implementación de los métodos requeridos por la interfaz LocalStorage

  @override
  Future<String?> accessToken() async {
    try {
      _logger.d('SecureLocalStorage: Obteniendo token de acceso');
      return await _secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      _logger.e('SecureLocalStorage: Error al obtener token de acceso - $e');
      return null;
    }
  }

  @override
  Future<bool> hasAccessToken() async {
    try {
      _logger.d('SecureLocalStorage: Verificando si existe token de acceso');
      return await _secureStorage.containsKey(key: _accessTokenKey);
    } catch (e) {
      _logger.e('SecureLocalStorage: Error al verificar token de acceso - $e');
      return false;
    }
  }

  @override
  Future<void> initialize() async {
    _logger.i('SecureLocalStorage: Inicializando almacenamiento seguro');
    // No se requiere inicialización especial para FlutterSecureStorage
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    try {
      // Extraer tokens de la cadena de sesión
      final sessionData = persistSessionString.split('.');
      if (sessionData.length >= 2) {
        final accessToken = sessionData[0];
        final refreshToken = sessionData[1];

        // Guardar tokens por separado
        await _secureStorage.write(key: _accessTokenKey, value: accessToken);
        await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);

        _logger.i('SecureLocalStorage: Sesión persistida con éxito');
      } else {
        _logger.e('SecureLocalStorage: Formato de sesión inválido');
      }
    } catch (e) {
      _logger.e('SecureLocalStorage: Error al persistir sesión - $e');
    }
  }

  @override
  Future<bool> removePersistedSession() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      _logger.i('SecureLocalStorage: Sesión eliminada con éxito');
      return true;
    } catch (e) {
      _logger.e('SecureLocalStorage: Error al eliminar sesión - $e');
      return false;
    }
  }

  // Métodos adicionales para compatibilidad
  Future<String?> getItem({required String key}) async {
    return getStorageItem(key: key);
  }

  Future<void> removeItem({required String key}) async {
    return removeStorageItem(key: key);
  }

  Future<void> setItem({required String key, required String value}) async {
    return setStorageItem(key: key, value: value);
  }
}
