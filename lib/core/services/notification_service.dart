import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'preferences_service.dart';

/// Sincroniza el token FCM del dispositivo con `profiles.fcm_token` para que
/// la Edge Function `notify-order` pueda enviar push al usuario correcto.
/// Todos los métodos son best-effort: si Firebase no está disponible
/// (p. ej. modo bypass), la app sigue funcionando sin push.
class NotificationService {
  final SupabaseClient _supabase;
  final PreferencesService? _preferences;
  final _logger = Logger();
  StreamSubscription<AuthState>? _authSubscription;
  bool _listenersAttached = false;

  NotificationService({
    SupabaseClient? supabaseClient,
    PreferencesService? preferences,
  }) : _supabase = supabaseClient ?? Supabase.instance.client,
       _preferences = preferences;

  bool get enabled => _preferences?.notificationsEnabled ?? true;

  /// Activa o desactiva las notificaciones del usuario. Al desactivar se
  /// borra el token del perfil (el servidor deja de poder enviarle push).
  Future<void> setEnabled(bool value) async {
    await _preferences?.setNotificationsEnabled(value);
    if (value) {
      await syncToken();
      return;
    }
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase
            .from('profiles')
            .update({'fcm_token': null})
            .eq('id', user.id);
      }
      await FirebaseMessaging.instance.deleteToken();
      _logger.i('🔕 Notificaciones desactivadas y token eliminado');
    } catch (e) {
      _logger.w('No se pudo eliminar el token FCM: $e');
    }
  }

  /// Sincroniza el token cada vez que hay sesión (login o sesión restaurada).
  void bindToAuthChanges() {
    _authSubscription?.cancel();
    _authSubscription = _supabase.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedIn ||
          state.event == AuthChangeEvent.initialSession) {
        syncToken();
      }
    });
  }

  Future<void> syncToken() async {
    try {
      if (!enabled) {
        _logger.i('Notificaciones desactivadas por el usuario; no se sincroniza');
        return;
      }
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        _logger.i('Permiso de notificaciones denegado');
        return;
      }

      final token = await messaging.getToken();
      if (token == null) return;

      await _saveToken(token);

      if (!_listenersAttached) {
        _listenersAttached = true;
        messaging.onTokenRefresh.listen(_saveToken);
        FirebaseMessaging.onMessage.listen((message) {
          // En primer plano el usuario ya ve el estado en vivo (Realtime);
          // se registra para debug. Las push llegan en segundo plano.
          _logger.i(
            'Push en primer plano: ${message.notification?.title} — '
            '${message.notification?.body}',
          );
        });
      }

      _logger.i('✅ Token FCM sincronizado');
    } catch (e) {
      _logger.w('No se pudo sincronizar el token FCM: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    await _supabase
        .from('profiles')
        .update({'fcm_token': token})
        .eq('id', user.id);
  }
}
