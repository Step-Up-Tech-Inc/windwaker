import 'package:shared_preferences/shared_preferences.dart';

class AppIntroService {
  final SharedPreferences _sharedPreferences;
  final String _hasSeenIntroKey = 'has_seen_intro';

  AppIntroService(this._sharedPreferences);

  /// Verifica si el usuario ya ha visto la pantalla de introducción
  Future<bool> hasSeenIntro() async {
    return _sharedPreferences.getBool(_hasSeenIntroKey) ?? false;
  }

  /// Marca que el usuario ya ha visto la pantalla de introducción
  Future<bool> markIntroAsSeen() async {
    return _sharedPreferences.setBool(_hasSeenIntroKey, true);
  }

  /// Restablece el estado de la pantalla de introducción (para pruebas)
  Future<bool> resetIntroState() async {
    return _sharedPreferences.setBool(_hasSeenIntroKey, false);
  }
}
