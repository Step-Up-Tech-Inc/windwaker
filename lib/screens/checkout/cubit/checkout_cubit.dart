import 'package:bloc/bloc.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/repositories/cart_repository.dart';
import '../../../core/services/order_service.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CartRepository cartRepository;
  final OrderService orderService;

  CheckoutCubit({
    required this.cartRepository,
    required this.orderService,
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

  void initialize() {
    // Cargar direcciones guardadas o configurar valores predeterminados
    emit(
      state.copyWith(
        address: '200m Este del Banco Nacional, Tilarán, Guanacaste',
        addressType: 'Casa',
        estimatedDeliveryTime: '30-45 min',
      ),
    );
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

  Future<void> placeOrder() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      // Simular un tiempo de procesamiento
      await Future.delayed(const Duration(seconds: 2));

      // Crear el pedido usando el servicio
      await orderService.createOrder(
        restaurantName: state.storeName,
        items: state.cartItems,
        subtotal: state.subtotal,
        tax: state.tax,
        deliveryCost: state.deliveryCost,
        discount: state.discount,
        total: state.total,
      );

      // Limpiar el carrito después de realizar el pedido
      await cartRepository.clearCart();

      emit(
        state.copyWith(
          isLoading: false,
          orderPlaced: true,
          orderConfirmationId:
              'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
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
