import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/negocio.dart';
import '../../../core/repositories/negocios_repository.dart';
import '../../../core/services/location_service.dart';

part 'home_state.dart';
part 'home_cubit.freezed.dart';

class HomeCubit extends Cubit<HomeState> {
  final NegociosRepository _negociosRepository;
  final LocationService _locationService;

  HomeCubit({
    required NegociosRepository negociosRepository,
    required LocationService locationService,
  }) : _negociosRepository = negociosRepository,
       _locationService = locationService,
       super(const HomeState.initial());

  Future<void> loadInitialData() async {
    emit(const HomeState.loading());

    try {
      final String ciudad = await _locationService.getCurrentCity();

      // Cargar los negocios destacados específicamente para la sección "Tiendas populares"
      final List<Negocio> negociosDestacados =
          await _negociosRepository.getNegociosDestacados();

      // Si no hay destacados, cargamos todos para no mostrar una sección vacía
      final List<Negocio> negociosParaMostrar =
          negociosDestacados.isNotEmpty
              ? negociosDestacados
              : await _negociosRepository.getNegocios();

      emit(HomeState.loaded(ciudad: ciudad, negocios: negociosParaMostrar));
    } catch (error) {
      emit(HomeState.error(message: error.toString()));
    }
  }
}
