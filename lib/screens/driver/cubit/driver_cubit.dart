import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:windwaker/core/models/order.dart';
import 'package:windwaker/core/repositories/driver_repository.dart';
import 'package:windwaker/core/repositories/order_repository.dart';

part 'driver_state.dart';
part 'driver_cubit.freezed.dart';

/// Panel del repartidor: pedidos disponibles en tiempo real, entrega activa
/// e historial. Las transiciones las valida el servidor.
class DriverCubit extends Cubit<DriverState> {
  final DriverRepository _driverRepository;
  final OrderRepository _orderRepository;
  StreamSubscription<void>? _subscription;

  DriverCubit({
    required DriverRepository driverRepository,
    required OrderRepository orderRepository,
  }) : _driverRepository = driverRepository,
       _orderRepository = orderRepository,
       super(const DriverState.loading());

  Future<void> load() async {
    emit(const DriverState.loading());
    try {
      await _refresh();
      await _subscription?.cancel();
      _subscription = _driverRepository.watchOrderChanges().listen(
        (_) => _refresh(),
      );
    } catch (e) {
      if (!isClosed) emit(DriverState.error('Error cargando pedidos: $e'));
    }
  }

  Future<void> _refresh() async {
    final available = await _driverRepository.getAvailableOrders();
    final active = await _driverRepository.getActiveDelivery();
    final history = await _driverRepository.getDeliveryHistory();
    if (!isClosed) {
      emit(
        DriverState.loaded(
          available: available,
          active: active,
          history: history,
        ),
      );
    }
  }

  /// Tomar un pedido. Devuelve false si otro repartidor ganó la carrera.
  Future<bool> claim(String orderId) async {
    try {
      final claimed = await _driverRepository.claimOrder(orderId);
      await _refresh();
      return claimed;
    } catch (e) {
      if (!isClosed) {
        final current = state;
        emit(DriverState.error('No se pudo tomar el pedido: $e'));
        if (current is _Loaded) emit(current);
      }
      return false;
    }
  }

  Future<void> markPickedUp(String orderId) =>
      _advance(orderId, OrderStatus.pickedUp);

  Future<void> markDelivered(String orderId) =>
      _advance(orderId, OrderStatus.delivered);

  Future<void> _advance(String orderId, OrderStatus status) async {
    try {
      await _orderRepository.advanceStatus(orderId, status);
      await _refresh();
    } catch (e) {
      if (!isClosed) {
        final current = state;
        emit(DriverState.error('No se pudo actualizar la entrega: $e'));
        if (current is _Loaded) emit(current);
      }
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
