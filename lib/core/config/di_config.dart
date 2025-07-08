import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/negocios_repository.dart';
import '../repositories/product_repository_interface.dart';
import '../repositories/product_repository_factory.dart';
import '../repositories/cart_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/user_repository.dart';
import '../services/location_service.dart';
import '../services/app_intro_service.dart';
import '../services/order_service.dart';
import '../services/migration_service.dart';
import '../services/auth_service.dart';
import '../../screens/home/cubit/home_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Servicios
  getIt.registerLazySingleton<LocationService>(() => LocationService());

  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Servicio de introducción de la app
  getIt.registerLazySingleton<AppIntroService>(
    () => AppIntroService(getIt<SharedPreferences>()),
  );

  // Clientes
  final supabaseClient = Supabase.instance.client;
  getIt.registerLazySingleton<SupabaseClient>(() => supabaseClient);

  // Repositorio de usuarios
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(supabaseClient: getIt<SupabaseClient>()),
  );

  // Servicio de migraciones
  getIt.registerLazySingleton<MigrationService>(
    () => MigrationService(supabaseClient: getIt<SupabaseClient>()),
  );

  // Ejecutar migraciones
  await getIt<MigrationService>().runMigrations();

  // Servicio de autenticación
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
      prefs: getIt<SharedPreferences>(),
      supabaseClient: getIt<SupabaseClient>(),
      userRepository: getIt<UserRepository>(),
    ),
  );

  // Repositorios
  getIt.registerLazySingleton<NegociosRepository>(
    () => NegociosRepository(supabaseClient: getIt<SupabaseClient>()),
  );

  // Inicializar el factory de ProductRepository que elige entre local y remoto
  final productRepositoryFactory = ProductRepositoryFactory();
  await productRepositoryFactory.initialize(
    sharedPreferences: getIt<SharedPreferences>(),
    supabaseClient: getIt<SupabaseClient>(),
  );

  getIt.registerLazySingleton<ProductRepositoryInterface>(
    () => productRepositoryFactory.repository,
  );

  getIt.registerLazySingleton<CartRepository>(
    () => CartRepository(getIt<SharedPreferences>()),
  );

  // Repositorio y servicio de pedidos
  getIt.registerLazySingleton<OrderRepository>(() => OrderRepository());

  getIt.registerLazySingleton<OrderService>(
    () => OrderService(getIt<OrderRepository>()),
  );

  // Cubits
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      negociosRepository: getIt<NegociosRepository>(),
      locationService: getIt<LocationService>(),
      cartRepository: getIt<CartRepository>(),
    ),
  );
}
