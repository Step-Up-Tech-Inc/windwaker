import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Almacenamiento seguro de la sesión de Supabase (Keychain/Keystore).
///
/// En supabase_flutter 2.x, `persistSession` recibe la sesión COMPLETA como
/// string JSON y `accessToken()` debe devolver ese mismo string intacto
/// (el nombre es engañoso). Guardarlo troceado corrompe la sesión y obliga
/// a iniciar sesión en cada arranque.
class SecureLocalStorage implements LocalStorage {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final _logger = Logger();

  static const String _sessionKey = 'supabase_session';

  // Claves del formato antiguo (corrupto) que hay que limpiar
  static const String _legacyAccessKey = 'supabase_access_token';
  static const String _legacyRefreshKey = 'supabase_refresh_token';

  @override
  Future<void> initialize() async {
    // Limpiar restos del formato antiguo si existen
    try {
      await _secureStorage.delete(key: _legacyAccessKey);
      await _secureStorage.delete(key: _legacyRefreshKey);
    } catch (_) {
      // Best-effort: no bloquear el arranque por esto
    }
  }

  @override
  Future<String?> accessToken() async {
    try {
      return await _secureStorage.read(key: _sessionKey);
    } catch (e) {
      _logger.e('SecureLocalStorage: error leyendo la sesión - $e');
      return null;
    }
  }

  @override
  Future<bool> hasAccessToken() async {
    try {
      return await _secureStorage.containsKey(key: _sessionKey);
    } catch (e) {
      _logger.e('SecureLocalStorage: error verificando la sesión - $e');
      return false;
    }
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    try {
      await _secureStorage.write(key: _sessionKey, value: persistSessionString);
    } catch (e) {
      _logger.e('SecureLocalStorage: error persistiendo la sesión - $e');
    }
  }

  @override
  Future<void> removePersistedSession() async {
    try {
      await _secureStorage.delete(key: _sessionKey);
    } catch (e) {
      _logger.e('SecureLocalStorage: error eliminando la sesión - $e');
    }
  }
}
