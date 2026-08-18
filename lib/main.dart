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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:windwaker/core/config/locale_controller.dart';
import 'package:windwaker/core/network/supabase_service.dart';
import 'package:windwaker/core/services/notification_service.dart';
import 'package:windwaker/core/storage/secure_local_storage.dart';
import 'package:windwaker/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windwaker/core/router.dart';
import 'package:logger/logger.dart';
import 'dart:developer' as dev;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = Logger();

  // Mostrar información del modo actual
  if (AppConfig.enableDetailedLogging) {
    dev.log('=== INICIANDO APLICACIÓN ===');
    dev.log('Modo: ${AppConfig.modeDescription}');
    dev.log('Configuración válida: ${AppConfig.isConfigValid}');
    dev.log('Usa Supabase Auth: ${AppConfig.useSupabaseAuth}');
    dev.log('Permite códigos bypass: ${AppConfig.allowBypassCodes}');
  }

  // Orientación de la aplicación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // Inicializar Firebase (solo si no estamos en modo bypass puro)
    if (AppConfig.currentMode != AppMode.bypass || AppConfig.isConfigValid) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Configurar Crashlytics (solo para plataformas móviles y producción)
      if (!kIsWeb &&
          AppConfig.currentMode == AppMode.production &&
          !kDebugMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          true,
        );
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }

      // Inicializar Remote Config (solo si no estamos en web)
      if (!kIsWeb && AppConfig.currentMode != AppMode.bypass) {
        await RemoteConfigService().initialize();
      }
    }
  } catch (e) {
    logger.e('Error al inicializar Firebase: $e');
    if (AppConfig.enableDetailedLogging) {
      dev.log('Error Firebase: $e');
    }
    // Continuar con la ejecución de la app aunque Firebase falle
  }

  try {
    // Usar URLs de configuración según el modo
    String supabaseUrl;
    String supabaseAnonKey;

    if (AppConfig.currentMode == AppMode.bypass) {
      // Para bypass, usar configuración mínima (puede ser fake)
      supabaseUrl = AppConfig.supabaseUrl;
      supabaseAnonKey = AppConfig.supabaseAnonKey;
    } else {
      // Para testing y production, usar configuración real
      supabaseUrl = AppConfig.supabaseUrl;
      supabaseAnonKey = AppConfig.supabaseAnonKey;
    }

    // Inicializar almacenamiento seguro para Supabase
    final secureStorage = SecureLocalStorage();
    await secureStorage.initialize();

    // Inicializar Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: AppConfig.enableDetailedLogging,
      authOptions: FlutterAuthClientOptions(
        localStorage: secureStorage,
        autoRefreshToken: AppConfig.useSupabaseAuth,
      ),
    );

    if (AppConfig.logAuthFlow) {
      dev.log('Supabase inicializado correctamente - URL: $supabaseUrl');
    }

    // Inicializar el servicio de Supabase
    await SupabaseService().initialize();
  } catch (e) {
    logger.e('Error al inicializar Supabase: $e');
    if (AppConfig.enableDetailedLogging) {
      dev.log('Error Supabase: $e');
    }
    // Continuar con la ejecución de la app aunque Supabase falle
  }

  // Configurar inyección de dependencias
  await setupDependencies();

  // Sincronizar el token de notificaciones cuando haya sesión
  getIt<NotificationService>().bindToAuthChanges();

  // Verificar la sesión actual (solo para debugging)
  if (AppConfig.logAuthFlow) {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;
      dev.log('Sesión actual: ${session != null ? 'Activa' : 'Inactiva'}');
      dev.log('Usuario actual: ${user != null ? user.id : 'No hay usuario'}');

      if (user != null) {
        dev.log('Email del usuario: ${user.email}');
        dev.log('Teléfono del usuario: ${user.phone}');
      }
    } catch (e) {
      dev.log('Error al verificar la sesión: $e');
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final localeController = getIt<LocaleController>();

    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        return MaterialApp.router(
          title: 'Tilarán en Línea',
          debugShowCheckedModeBanner: AppConfig.enableDetailedLogging,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          locale: locale,
          supportedLocales: LocaleController.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        );
      },
    );
  }
}
