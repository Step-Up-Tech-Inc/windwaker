import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  static const String _enableFacebookLoginKey = 'enable_facebook_login';

  FirebaseRemoteConfig? _remoteConfig;
  bool _isInitialized = false;

  final Map<String, dynamic> _defaults = <String, dynamic>{
    _enableFacebookLoginKey: false,
  };

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval:
              kDebugMode
                  ? const Duration(minutes: 0)
                  : const Duration(hours: 12),
        ),
      );

      await _remoteConfig!.setDefaults(_defaults);
      await _remoteConfig!.fetchAndActivate();

      _isInitialized = true;
      debugPrint('✅ Remote Config inicializado correctamente');
    } catch (e) {
      debugPrint('⚠️ Error al inicializar Remote Config: $e');
      // En caso de error, usar valores por defecto
      _isInitialized = false;
    }
  }

  bool get enableFacebookLogin {
    if (!_isInitialized || _remoteConfig == null) {
      debugPrint(
        '⚠️ Remote Config no inicializado, usando valor por defecto: false',
      );
      return _defaults[_enableFacebookLoginKey] ?? false;
    }

    try {
      return _remoteConfig!.getBool(_enableFacebookLoginKey);
    } catch (e) {
      debugPrint(
        '⚠️ Error obteniendo enableFacebookLogin, usando valor por defecto: $e',
      );
      return _defaults[_enableFacebookLoginKey] ?? false;
    }
  }

  bool get isInitialized => _isInitialized;
}
