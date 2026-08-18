import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/address_repository.dart';
import '../repositories/negocios_repository.dart';
import '../repositories/product_repository_interface.dart';
import '../repositories/product_repository_factory.dart';
import '../repositories/cart_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/user_repository.dart';
import '../services/location_service.dart';
import '../services/app_intro_service.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/preferences_service.dart';
import 'locale_controller.dart';
import '../services/profile_validation_service.dart';
import '../config/remote_config_service.dart';
import '../repositories/business_repository.dart';
import '../repositories/driver_repository.dart';
import '../../screens/business/cubit/business_orders_cubit.dart';
import '../../screens/driver/cubit/driver_cubit.dart';
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

  // Servicio de validación de perfiles
  getIt.registerLazySingleton<ProfileValidationService>(
    () => ProfileValidationService(getIt<UserRepository>()),
  );

  // Servicio de autenticación (con soporte para modos)
  getIt.registerLazySingleton<AuthService>(() {
    final authService = AuthService();
    authService.initialize(getIt<UserRepository>());
    return authService;
  });

  // Preferencias locales (notificaciones, pago preferido, idioma)
  getIt.registerLazySingleton<PreferencesService>(
    () => PreferencesService(getIt<SharedPreferences>()),
  );

  // Controlador de idioma (es/en)
  getIt.registerLazySingleton<LocaleController>(
    () => LocaleController(getIt<PreferencesService>()),
  );

  // Servicio de notificaciones push (token FCM)
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(
      supabaseClient: getIt<SupabaseClient>(),
      preferences: getIt<PreferencesService>(),
    ),
  );

  // Remote Config Service
  getIt.registerLazySingleton<RemoteConfigService>(() => RemoteConfigService());

  // Inicializar Remote Config
  await getIt<RemoteConfigService>().initialize();

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

  // Repositorio de direcciones de entrega
  getIt.registerLazySingleton<AddressRepository>(
    () => AddressRepository(supabaseClient: getIt<SupabaseClient>()),
  );

  // Repositorio y servicio de pedidos
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepository(supabaseClient: getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<OrderService>(
    () => OrderService(getIt<OrderRepository>()),
  );

  // Repositorio del negocio (dueño de tienda)
  getIt.registerLazySingleton<BusinessRepository>(
    () => BusinessRepository(supabaseClient: getIt<SupabaseClient>()),
  );

  // Repositorio del repartidor
  getIt.registerLazySingleton<DriverRepository>(
    () => DriverRepository(supabaseClient: getIt<SupabaseClient>()),
  );

  // Cubits
  getIt.registerFactory<DriverCubit>(
    () => DriverCubit(
      driverRepository: getIt<DriverRepository>(),
      orderRepository: getIt<OrderRepository>(),
    ),
  );
  getIt.registerFactory<BusinessOrdersCubit>(
    () => BusinessOrdersCubit(
      businessRepository: getIt<BusinessRepository>(),
      orderRepository: getIt<OrderRepository>(),
    ),
  );
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      negociosRepository: getIt<NegociosRepository>(),
      locationService: getIt<LocationService>(),
      cartRepository: getIt<CartRepository>(),
    ),
  );
}
