import 'package:bloc/bloc.dart';
import '../../../core/models/address.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/models/order.dart';
import '../../../core/repositories/address_repository.dart';
import '../../../core/repositories/cart_repository.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/preferences_service.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CartRepository cartRepository;
  final OrderService orderService;
  final AddressRepository addressRepository;
  final PreferencesService? preferences;

  CheckoutCubit({
    required this.cartRepository,
    required this.orderService,
    required this.addressRepository,
    this.preferences,
    required List<CartItem> cartItems,
    required double subtotal,
    required double tax,
    required double deliveryCost,
    required double discount,
    required double total,
    required String storeName,
  }) : super(
         CheckoutState(
           cartItems: cartItems,
           subtotal: subtotal,
           tax: tax,
           deliveryCost: deliveryCost,
           discount: discount,
           total: total,
           storeName: storeName,
         ),
       );

  /// Carga las direcciones guardadas y preselecciona la default.
  Future<void> initialize() async {
    // Preseleccionar el método de pago preferido del usuario
    final preferred = preferences?.preferredPaymentMethod;
    emit(
      state.copyWith(
        estimatedDeliveryTime: '30-45 min',
        paymentMethod:
            preferred == 'sinpe'
                ? PaymentMethod.mobilePayment
                : PaymentMethod.cash,
      ),
    );

    try {
      final addresses = await addressRepository.getMyAddresses();
      if (isClosed) return;

      emit(state.copyWith(savedAddresses: addresses));
      if (addresses.isNotEmpty && state.address.isEmpty) {
        selectAddress(addresses.first);
      }
    } catch (_) {
      // Sin direcciones guardadas no se bloquea el checkout:
      // el usuario puede escribir una nueva.
    }
  }

  void selectAddress(Address address) {
    emit(
      state.copyWith(
        address: address.fullDetail,
        addressType: address.label,
        latitude: address.latitude,
        longitude: address.longitude,
      ),
    );
  }

  /// Registra una dirección recién creada desde el checkout y la selecciona.
  void addSavedAddress(Address address) {
    emit(state.copyWith(savedAddresses: [address, ...state.savedAddresses]));
    selectAddress(address);
  }

  void updateAddress({String? address, String? addressType}) {
    emit(
      state.copyWith(
        address: address ?? state.address,
        addressType: addressType ?? state.addressType,
      ),
    );
  }

  void updateDeliveryInstructions(String instructions) {
    emit(state.copyWith(deliveryInstructions: instructions));
  }

  void toggleSaveAddress(bool save) {
    emit(state.copyWith(saveAddress: save));
  }

  void selectPaymentMethod(PaymentMethod method) {
    emit(state.copyWith(paymentMethod: method));
  }

  void toggleSavePaymentMethod(bool save) {
    emit(state.copyWith(savePaymentMethod: save));
  }

  /// Crea el pedido real en Supabase. Los precios y el total los calcula
  /// el servidor a partir del catálogo; lo que se envía son ids y cantidades.
  Future<void> placeOrder() async {
    if (state.cartItems.isEmpty) {
      emit(state.copyWith(error: 'El carrito está vacío.'));
      return;
    }

    final OrderPaymentMethod? payment = switch (state.paymentMethod) {
      PaymentMethod.cash => OrderPaymentMethod.cash,
      PaymentMethod.mobilePayment => OrderPaymentMethod.sinpe,
      PaymentMethod.card => null,
    };
    if (payment == null) {
      emit(
        state.copyWith(
          error:
              'El pago con tarjeta aún no está disponible. '
              'Elige efectivo o SINPE Móvil.',
        ),
      );
      return;
    }

    if (state.address.trim().isEmpty) {
      emit(state.copyWith(error: 'Indica la dirección de entrega.'));
      return;
    }

    try {
      emit(state.copyWith(isLoading: true, error: null));

      // Guardar la dirección si el usuario lo pidió y es nueva
      if (state.saveAddress &&
          !state.savedAddresses.any((a) => a.detail == state.address)) {
        try {
          await addressRepository.saveAddress(
            label: state.addressType,
            detail: state.address,
            isDefault: state.savedAddresses.isEmpty,
          );
        } catch (_) {
          // No bloquear el pedido si falla el guardado de la dirección
        }
      }

      final order = await orderService.createOrder(
        storeId: state.cartItems.first.storeId,
        deliveryMethod: DeliveryMethod.delivery,
        paymentMethod: payment,
        items: state.cartItems,
        addressLabel: state.addressType,
        addressDetail: state.address,
        latitude: state.latitude,
        longitude: state.longitude,
        notes:
            state.deliveryInstructions.isEmpty
                ? null
                : state.deliveryInstructions,
      );

      await cartRepository.clearCart();

      emit(
        state.copyWith(
          isLoading: false,
          orderPlaced: true,
          orderConfirmationId: order.id,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Error al procesar el pedido: ${e.toString()}',
        ),
      );
    }
  }
}
