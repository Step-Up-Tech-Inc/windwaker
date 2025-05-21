import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  static const String _enableFacebookLoginKey = 'enable_facebook_login';

  late final FirebaseRemoteConfig _remoteConfig;

  final Map<String, dynamic> _defaults = <String, dynamic>{
    _enableFacebookLoginKey: false,
  };

  Future<void> initialize() async {
    _remoteConfig = FirebaseRemoteConfig.instance;

    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval:
              kDebugMode
                  ? const Duration(minutes: 0)
                  : const Duration(hours: 12),
        ),
      );

      await _remoteConfig.setDefaults(_defaults);
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Error al inicializar Remote Config: $e');
    }
  }

  bool get enableFacebookLogin =>
      _remoteConfig.getBool(_enableFacebookLoginKey);
}
