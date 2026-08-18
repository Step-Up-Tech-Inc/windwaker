import 'package:flutter/widgets.dart';

import '../services/preferences_service.dart';

/// Controla el idioma activo de la app (es/en) y lo persiste.
/// MyApp escucha este notifier para reconstruir con el nuevo locale.
class LocaleController extends ValueNotifier<Locale> {
  final PreferencesService _preferences;

  LocaleController(this._preferences)
    : super(Locale(_preferences.languageCode));

  static const List<Locale> supportedLocales = [Locale('es'), Locale('en')];

  Future<void> setLanguage(String code) async {
    if (!supportedLocales.any((l) => l.languageCode == code)) return;
    await _preferences.setLanguageCode(code);
    value = Locale(code);
  }
}
