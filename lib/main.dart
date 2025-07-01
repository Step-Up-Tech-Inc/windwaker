import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwaker/core/config/app_config.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/config/firebase_options.dart';
import 'package:windwaker/core/config/remote_config_service.dart';
import 'package:windwaker/core/network/supabase_service.dart';
import 'package:windwaker/core/services/migration_service.dart';
import 'package:windwaker/core/storage/secure_local_storage.dart';
import 'package:windwaker/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windwaker/core/router.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = Logger();

  // Orientación de la aplicación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configurar Crashlytics (solo para plataformas móviles)
    if (!kIsWeb && AppConfig.enableCrashlytics && !kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    // Inicializar Remote Config (solo si no estamos en web)
    if (!kIsWeb) {
      await RemoteConfigService().initialize();
    }
  } catch (e) {
    logger.e('Error al inicializar Firebase: $e');
    // Continuar con la ejecución de la app aunque Firebase falle
  }

  try {
    // Inicializar almacenamiento seguro para Supabase
    final secureStorage = SecureLocalStorage();
    await secureStorage.initialize();

    // Inicializar Supabase
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      debug: kDebugMode,
      authOptions: FlutterAuthClientOptions(
        localStorage: secureStorage,
        autoRefreshToken: true,
      ),
    );

    logger.i('Supabase inicializado correctamente');

    // Inicializar el servicio de Supabase
    await SupabaseService().initialize();
  } catch (e) {
    logger.e('Error al inicializar Supabase: $e');
    // Continuar con la ejecución de la app aunque Supabase falle
  }

  // Configurar inyección de dependencias
  await setupDependencies();

  // Ejecutar migraciones
  try {
    final migrationService = GetIt.I<MigrationService>();
    await migrationService.runMigrations();
    logger.i('Migraciones ejecutadas correctamente');
  } catch (e) {
    logger.e('Error al ejecutar migraciones: $e');
  }

  // Verificar la sesión actual
  try {
    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;
    logger.i('Sesión actual: ${session != null ? 'Activa' : 'Inactiva'}');
    logger.i('Usuario actual: ${user != null ? user.id : 'No hay usuario'}');

    if (user != null) {
      logger.i('Email del usuario: ${user.email}');
      logger.i('Teléfono del usuario: ${user.phone}');
    }
  } catch (e) {
    logger.e('Error al verificar la sesión: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
