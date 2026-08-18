import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias locales del usuario (dispositivo): notificaciones,
/// método de pago preferido e idioma.
class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static const String _kNotificationsEnabled = 'pref_notifications_enabled';
  static const String _kPaymentMethod = 'pref_payment_method';
  static const String _kLanguageCode = 'pref_language_code';

  // ── Notificaciones ──
  bool get notificationsEnabled => _prefs.getBool(_kNotificationsEnabled) ?? true;

  Future<void> setNotificationsEnabled(bool enabled) =>
      _prefs.setBool(_kNotificationsEnabled, enabled);

  // ── Método de pago preferido ('cash' | 'sinpe') ──
  String get preferredPaymentMethod =>
      _prefs.getString(_kPaymentMethod) ?? 'cash';

  Future<void> setPreferredPaymentMethod(String method) =>
      _prefs.setString(_kPaymentMethod, method);

  // ── Idioma ('es' | 'en') ──
  String get languageCode => _prefs.getString(_kLanguageCode) ?? 'es';

  Future<void> setLanguageCode(String code) =>
      _prefs.setString(_kLanguageCode, code);
}
