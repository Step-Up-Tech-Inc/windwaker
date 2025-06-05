import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';

import '../../../core/models/negocio.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/repositories/negocios_repository.dart';
import '../../../core/repositories/cart_repository.dart';
import '../../../core/services/location_service.dart';

part 'home_state.dart';
part 'home_cubit.freezed.dart';

class HomeCubit extends Cubit<HomeState> {
  final NegociosRepository _negociosRepository;
  final LocationService _locationService;
  final CartRepository _cartRepository;
  final Logger _logger = Logger();

  HomeCubit({
    required NegociosRepository negociosRepository,
    required LocationService locationService,
    required CartRepository cartRepository,
  }) : _negociosRepository = negociosRepository,
       _locationService = locationService,
       _cartRepository = cartRepository,
       super(const HomeState.initial());

  Future<void> loadInitialData() async {
    emit(const HomeState.loading());

    try {
      final String ciudad = await _locationService.getCurrentCity();

      // Cargar los datos del carrito
      final List<CartItem> cartItems = await _cartRepository.getCartItems();
      final double cartTotal = await _cartRepository.getCartTotal();

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

      emit(
        HomeState.loaded(
          ciudad: ciudad,
          negocios: negociosParaMostrar,
          cartItems: cartItems,
          cartTotal: cartTotal,
        ),
      );
    } catch (error) {
      emit(HomeState.error(message: 'Error: ${error.toString()}'));
    }
  }

  // Método para actualizar el carrito
  Future<void> loadCartItems() async {
    try {
      if (state is! _Loaded) return;

      final _Loaded currentState = state as _Loaded;

      // Obtener datos actualizados del carrito
      final List<CartItem> cartItems = await _cartRepository.getCartItems();
      final double cartTotal = await _cartRepository.getCartTotal();

      // Actualizar el estado con los nuevos datos del carrito
      emit(
        _Loaded(
          ciudad: currentState.ciudad,
          negocios: currentState.negocios,
          cartItems: cartItems,
          cartTotal: cartTotal,
        ),
      );
    } catch (e) {
      // No emitimos error para evitar cambiar la pantalla, solo logueamos
      _logger.e('Error al cargar elementos del carrito: $e');
    }
  }
}
