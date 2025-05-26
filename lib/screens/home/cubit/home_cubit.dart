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
      final List<Negocio> negociosDestacados;
      try {
        negociosDestacados = await _negociosRepository.getNegociosDestacados();
      } catch (e) {
        emit(
          HomeState.error(
            message: 'Error al cargar tiendas destacadas: ${e.toString()}',
          ),
        );
        return;
      }

      // Si no hay negocios destacados, intentamos cargar todos los negocios
      List<Negocio> negociosParaMostrar = negociosDestacados;

      if (negociosDestacados.isEmpty) {
        try {
          negociosParaMostrar = await _negociosRepository.getNegocios();
        } catch (e) {
          emit(
            HomeState.error(
              message: 'Error al cargar tiendas: ${e.toString()}',
            ),
          );
          return;
        }
      }

      if (negociosParaMostrar.isEmpty) {
        emit(
          HomeState.error(
            message:
                'No hay tiendas disponibles en este momento. Por favor, inténtelo más tarde.',
          ),
        );
        return;
      }

      emit(HomeState.loaded(ciudad: ciudad, negocios: negociosParaMostrar));
    } catch (error) {
      emit(HomeState.error(message: 'Error: ${error.toString()}'));
    }
  }
}
