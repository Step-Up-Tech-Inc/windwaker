import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthService {
  final SharedPreferences _prefs;
  final SupabaseClient _supabaseClient;

  AuthService({
    required SharedPreferences prefs,
    SupabaseClient? supabaseClient,
  }) : _prefs = prefs,
       _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Verifica si el usuario está autenticado y tiene un perfil completo
  bool isAuthenticated() {
    // Verificar si hay información guardada en SharedPreferences
    final phone = _prefs.getString('user_phone');
    if (phone != null && phone.isNotEmpty) {
      return true;
    }

    // Si no hay en SharedPreferences, verificar en Supabase Auth
    final user = _supabaseClient.auth.currentUser;
    return user != null;
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

  /// Cierra la sesión del usuario
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      // Limpiar datos guardados
      await _prefs.remove('user_email');
      await _prefs.remove('user_phone');
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
    }
  }
}
