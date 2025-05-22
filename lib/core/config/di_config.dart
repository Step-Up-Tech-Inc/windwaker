import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/negocios_repository.dart';
import '../services/location_service.dart';
import '../../screens/home/cubit/home_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Servicios
  getIt.registerLazySingleton<LocationService>(() => LocationService());

  // Clientes
  final supabaseClient = Supabase.instance.client;
  getIt.registerLazySingleton<SupabaseClient>(() => supabaseClient);

  // Repositorios
  getIt.registerLazySingleton<NegociosRepository>(
    () => NegociosRepository(supabaseClient: getIt<SupabaseClient>()),
  );

  // Cubits
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      negociosRepository: getIt<NegociosRepository>(),
      locationService: getIt<LocationService>(),
    ),
  );
}
