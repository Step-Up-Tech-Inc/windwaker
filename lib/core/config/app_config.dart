import 'environment.dart';

enum AppMode { bypass, testing, production }

class AppConfig {
  // Configuración del modo actual
  static AppMode get currentMode => Environment.mode;

  // Configuración de autenticación
  static bool get useSupabaseAuth => currentMode != AppMode.bypass;
  static bool get allowBypassCodes => currentMode == AppMode.bypass;
  static bool get createRealUsers =>
      currentMode == AppMode.testing || currentMode == AppMode.production;

  // Códigos de bypass para desarrollo
  static const String bypassCode = '000000';
  static const String testingCode = '123456';

  // Configuración de logging
  static bool get enableDetailedLogging => currentMode != AppMode.production;
  static bool get logAuthFlow =>
      currentMode == AppMode.testing || currentMode == AppMode.bypass;
  static bool get logDatabaseOperations => currentMode != AppMode.production;

  // Configuración de base de datos
  static bool get useLocalCache => true; // Siempre habilitado
  static bool get syncWithSupabase => true; // Siempre habilitado

  // URLs y configuración de Supabase
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue:
        'https://carvqbtjhyyhpawponaq.supabase.co', // Reemplaza con tu URL
  );

  // Clave anónima (anon): diseñada por Supabase para vivir en el cliente.
  // No otorga acceso por sí sola — cada tabla está protegida por RLS. Aun así
  // se lee desde --dart-define en release para no fijarla en el binario.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNhcnZxYnRqaHl5aHBhd3BvbmFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4NDM5OTQsImV4cCI6MjA4NDQxOTk5NH0.XVwcvvmBaKfGjFpEGKfFWk9t7q6spfU6BKFw-SmLr9w',
  );

  // NOTA DE SEGURIDAD: la service_role key fue ELIMINADA del cliente.
  // Las operaciones que la necesitaban (verificar cuenta, asignar email) ahora
  // viven en Edge Functions (`check-account`, `set-user-email`) donde la key
  // se inyecta como secreto del servidor y nunca llega al dispositivo.

  // Configuración de desarrollo
  static String get defaultEmail => _getDefaultEmail();
  static String get defaultPhone => _getDefaultPhone();
  static String get defaultPassword => 'DevPass123!';

  // Métodos auxiliares
  static String _getDefaultEmail() {
    switch (currentMode) {
      case AppMode.bypass:
        return 'dev@bypass.com';
      case AppMode.testing:
        return 'test@testing.com';
      case AppMode.production:
        return '';
    }
  }

  static String _getDefaultPhone() {
    switch (currentMode) {
      case AppMode.bypass:
        return '+1234567890';
      case AppMode.testing:
        return '+1987654321';
      case AppMode.production:
        return '';
    }
  }

  // Información del modo actual para debugging
  static String get modeDescription {
    switch (currentMode) {
      case AppMode.bypass:
        return 'Desarrollo - Bypass sin Supabase Auth';
      case AppMode.testing:
        return 'Testing - Con usuarios reales de Supabase';
      case AppMode.production:
        return 'Producción - Solo autenticación real';
    }
  }

  // Validar configuración
  static bool get isConfigValid {
    if (currentMode == AppMode.production) {
      return supabaseUrl.contains('supabase.co') && supabaseAnonKey.length > 20;
    }
    return true;
  }
}
