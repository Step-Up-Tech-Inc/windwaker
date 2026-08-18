import 'app_config.dart';

/// Configuración específica de entorno para facilitar cambios
class Environment {
  // CAMBIAR ESTE VALOR PARA ALTERNAR ENTRE MODOS
  static const AppMode _currentMode = AppMode.testing; // ← CAMBIADO A TESTING

  /// Obtener el modo actual (sobrescribe la detección automática si es necesario)
  static AppMode get mode => _currentMode;

  /// Configuraciones específicas por modo
  static const Map<AppMode, EnvironmentConfig> _configs = {
    AppMode.bypass: EnvironmentConfig(
      name: 'Desarrollo (Bypass)',
      description: 'Modo de desarrollo sin autenticación real',
      color: 'orange',
      useRealAuth: false,
      enableLogging: true,
      enableCrashlytics: false,
      allowDebugInfo: true,
    ),
    AppMode.testing: EnvironmentConfig(
      name: 'Testing',
      description: 'Modo de testing con usuarios reales de Supabase',
      color: 'blue',
      useRealAuth: true,
      enableLogging: true,
      enableCrashlytics: false,
      allowDebugInfo: true,
    ),
    AppMode.production: EnvironmentConfig(
      name: 'Producción',
      description: 'Modo de producción con autenticación completa',
      color: 'green',
      useRealAuth: true,
      enableLogging: false,
      enableCrashlytics: true,
      allowDebugInfo: false,
    ),
  };

  /// Obtener configuración del modo actual
  static EnvironmentConfig get config => _configs[mode]!;

  /// Obtener todas las configuraciones disponibles
  static Map<AppMode, EnvironmentConfig> get allConfigs => _configs;

  /// Verificar si estamos en modo de desarrollo
  static bool get isDevelopment => mode == AppMode.bypass;

  /// Verificar si estamos en modo de testing
  static bool get isTesting => mode == AppMode.testing;

  /// Verificar si estamos en modo de producción
  static bool get isProduction => mode == AppMode.production;

  /// Obtener información para debugging
  static String get debugInfo => '''
=== CONFIGURACIÓN DE ENTORNO ===
Modo: ${config.name}
Descripción: ${config.description}
Autenticación real: ${config.useRealAuth}
Logging habilitado: ${config.enableLogging}
Crashlytics: ${config.enableCrashlytics}
Info de debug: ${config.allowDebugInfo}
''';
}

/// Configuración específica de un entorno
class EnvironmentConfig {
  final String name;
  final String description;
  final String color;
  final bool useRealAuth;
  final bool enableLogging;
  final bool enableCrashlytics;
  final bool allowDebugInfo;

  const EnvironmentConfig({
    required this.name,
    required this.description,
    required this.color,
    required this.useRealAuth,
    required this.enableLogging,
    required this.enableCrashlytics,
    required this.allowDebugInfo,
  });
}
