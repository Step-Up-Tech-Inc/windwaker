import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/negocios_repository.dart';
import '../repositories/product_repository_interface.dart';
import '../repositories/product_repository_factory.dart';
import '../repositories/cart_repository.dart';
import '../services/location_service.dart';
import '../../screens/home/cubit/home_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Servicios
  getIt.registerLazySingleton<LocationService>(() => LocationService());

  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Clientes
  final supabaseClient = Supabase.instance.client;
  getIt.registerLazySingleton<SupabaseClient>(() => supabaseClient);

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

  // Cubits
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      negociosRepository: getIt<NegociosRepository>(),
      locationService: getIt<LocationService>(),
    ),
  );
}
