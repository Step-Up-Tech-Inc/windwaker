import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:windwaker/core/models/order.dart';
import 'package:windwaker/core/repositories/business_repository.dart';
import 'package:windwaker/core/repositories/order_repository.dart';

part 'business_orders_state.dart';
part 'business_orders_cubit.freezed.dart';

/// Panel de pedidos del negocio: carga la tienda del dueño, escucha los
/// pedidos por Realtime y solicita transiciones de estado (validadas por
/// el RPC `advance_order_status` en el servidor).
class BusinessOrdersCubit extends Cubit<BusinessOrdersState> {
  final BusinessRepository _businessRepository;
  final OrderRepository _orderRepository;
  StreamSubscription<void>? _subscription;

  BusinessOrdersCubit({
    required BusinessRepository businessRepository,
    required OrderRepository orderRepository,
  }) : _businessRepository = businessRepository,
       _orderRepository = orderRepository,
       super(const BusinessOrdersState.loading());

  Future<void> load() async {
    emit(const BusinessOrdersState.loading());
    try {
      final store = await _businessRepository.getMyStore();
      if (isClosed) return;

      if (store == null) {
        emit(const BusinessOrdersState.noStore());
        return;
      }

      final orders = await _businessRepository.getStoreOrders(store.id);
      if (isClosed) return;
      emit(BusinessOrdersState.loaded(store: store, orders: orders));

      // Realtime: cualquier cambio en los pedidos de la tienda dispara
      // una recarga (los streams no traen los joins de items).
      await _subscription?.cancel();
      _subscription = _businessRepository
          .watchStoreOrderChanges(store.id)
          .listen((_) => _refreshOrders());
    } catch (e) {
      if (!isClosed) {
        emit(BusinessOrdersState.error('Error cargando el panel: $e'));
      }
    }
  }

  Future<void> _refreshOrders() async {
    final current = state;
    if (current is! _Loaded) return;
    try {
      final orders = await _businessRepository.getStoreOrders(
        current.store.id,
      );
      if (!isClosed && state is _Loaded) {
        emit(BusinessOrdersState.loaded(store: current.store, orders: orders));
      }
    } catch (_) {
      // La recarga por realtime es best-effort; la UI conserva lo último.
    }
  }

  /// Solicita una transición (aceptar, rechazar, preparando, listo…).
  Future<void> advanceOrder(String orderId, OrderStatus newStatus) async {
    try {
      await _orderRepository.advanceStatus(orderId, newStatus);
      await _refreshOrders();
    } catch (e) {
      final current = state;
      emit(BusinessOrdersState.error('No se pudo actualizar el pedido: $e'));
      // Restaurar la lista para no dejar la pantalla en error permanente
      if (current is _Loaded) emit(current);
    }
  }

  /// Abre o cierra la tienda.
  Future<void> toggleOpen() async {
    final current = state;
    if (current is! _Loaded) return;
    final newValue = !current.store.isOpen;
    try {
      await _businessRepository.setStoreOpen(current.store.id, newValue);
      if (!isClosed) {
        emit(
          BusinessOrdersState.loaded(
            store: current.store.copyWith(isOpen: newValue),
            orders: current.orders,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(BusinessOrdersState.error('No se pudo cambiar el estado: $e'));
        emit(current);
      }
    }
  }

  /// Onboarding: crea la tienda del negocio (con logo opcional) y recarga.
  Future<void> createStore({
    required String name,
    required String description,
    required String category,
    required double deliveryFee,
    required int deliveryTimeMinutes,
    Uint8List? logoBytes,
    String? logoName,
  }) async {
    emit(const BusinessOrdersState.loading());
    try {
      var imageUrl = '';
      if (logoBytes != null) {
        imageUrl = await _businessRepository.uploadStoreImage(
          fileName: logoName ?? 'logo.jpg',
          bytes: logoBytes,
        );
      }
      await _businessRepository.createStore(
        name: name,
        description: description,
        category: category,
        deliveryFee: deliveryFee,
        deliveryTimeMinutes: deliveryTimeMinutes,
        imageUrl: imageUrl,
      );
      await load();
    } catch (e) {
      if (!isClosed) {
        emit(BusinessOrdersState.error('No se pudo crear la tienda: $e'));
        emit(const BusinessOrdersState.noStore());
      }
    }
  }

  /// Configura el número SINPE Móvil de la tienda.
  Future<void> setSinpeNumber(String number) async {
    final current = state;
    if (current is! _Loaded) return;
    try {
      final value = number.trim();
      await _businessRepository.setSinpeNumber(
        current.store.id,
        value.isEmpty ? null : value,
      );
      if (!isClosed) {
        emit(
          BusinessOrdersState.loaded(
            store: current.store.copyWith(sinpeNumber: value),
            orders: current.orders,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(BusinessOrdersState.error('No se pudo guardar el SINPE: $e'));
        emit(current);
      }
    }
  }

  /// Aprueba o rechaza el comprobante SINPE de un pedido.
  Future<void> reviewPayment(String orderId, bool approved) async {
    try {
      await _orderRepository.reviewSinpePayment(
        orderId: orderId,
        approved: approved,
      );
      await _refreshOrders();
    } catch (e) {
      final current = state;
      emit(BusinessOrdersState.error('No se pudo revisar el pago: $e'));
      if (current is _Loaded) emit(current);
    }
  }

  /// URL firmada temporal para ver un comprobante.
  Future<String> paymentProofUrl(String proofPath) =>
      _orderRepository.getPaymentProofUrl(proofPath);

  /// Cambia el logo de la tienda ya creada.
  Future<void> changeStoreLogo({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final current = state;
    if (current is! _Loaded) return;
    try {
      final url = await _businessRepository.uploadStoreImage(
        fileName: fileName,
        bytes: bytes,
      );
      await _businessRepository.setStoreImage(current.store.id, url);
    } catch (e) {
      if (!isClosed) {
        emit(BusinessOrdersState.error('No se pudo actualizar el logo: $e'));
        emit(current);
      }
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
