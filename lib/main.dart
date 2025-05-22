import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:windwaker/core/config/app_config.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/config/firebase_options.dart';
import 'package:windwaker/core/config/remote_config_service.dart';
import 'package:windwaker/core/network/supabase_service.dart';
import 'package:windwaker/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windwaker/screens/home/cubit/home_cubit.dart';
import 'package:windwaker/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    debugPrint('Error al inicializar Firebase: $e');
    // Continuar con la ejecución de la app aunque Firebase falle
  }

  try {
    // Inicializar Supabase
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );

    // Inicializar el servicio de Supabase
    await SupabaseService().initialize();
  } catch (e) {
    debugPrint('Error al inicializar Supabase: $e');
    // Continuar con la ejecución de la app aunque Supabase falle
  }

  // Configurar inyección de dependencias
  await setupDependencies();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Para desarrollo, usamos directamente la pantalla de inicio
    // En producción, se usaría el router
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: BlocProvider(
        create: (_) => getIt<HomeCubit>(),
        child: const HomeScreen(),
      ),
    );
  }
}
