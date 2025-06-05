import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/cart_repository.dart';
import '../../../core/models/cart_item.dart';
import 'cart_screen_state.dart';

class CartScreenCubit extends Cubit<CartScreenState> {
  final CartRepository _cartRepository;
  final String? _storeId;

  CartScreenCubit({
    required CartRepository cartRepository,
    String? storeId,
    String storeName = '',
    String storeCategory = '',
    double storeRating = 4.5,
    String deliveryTime = '20-30 min',
  }) : _cartRepository = cartRepository,
       _storeId = storeId,
       super(
         CartScreenState(
           storeName: storeName,
           storeCategory: storeCategory,
           storeRating: storeRating,
           deliveryTime: deliveryTime,
         ),
       );

  Future<void> initialize() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      // Cargar items del carrito
      final List<CartItem> cartItems;
      if (_storeId != null) {
        cartItems = await _cartRepository.getCartItemsByStore(_storeId);
      } else {
        cartItems = await _cartRepository.getCartItems();
      }

      // Calcular valores
      final subtotal = _calculateSubtotal(cartItems);
      final tax = subtotal * 0.13; // 13% de impuesto
      final deliveryCost =
          state.deliveryMethod == DeliveryMethod.delivery ? 1500.0 : 0.0;
      final total = subtotal + tax + deliveryCost - state.discount;

      emit(
        state.copyWith(
          isLoading: false,
          cartItems: cartItems,
          subtotal: subtotal,
          tax: tax,
          deliveryCost: deliveryCost,
          cartTotal: total,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> updateCartItem(CartItem cartItem) async {
    try {
      // Actualizar en el repositorio
      await _cartRepository.updateCartItem(cartItem);

      // Actualizar la UI
      await initialize();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      // Eliminar del repositorio
      await _cartRepository.removeFromCart(cartItemId);

      // Actualizar la UI
      await initialize();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> clearCart() async {
    try {
      // Vaciar el carrito
      await _cartRepository.clearCart();

      // Actualizar la UI
      emit(
        state.copyWith(
          cartItems: [],
          subtotal: 0.0,
          tax: 0.0,
          deliveryCost: 0.0,
          cartTotal: 0.0,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void changeDeliveryMethod(DeliveryMethod method) {
    final deliveryCost = method == DeliveryMethod.delivery ? 1500.0 : 0.0;
    final total = state.subtotal + state.tax + deliveryCost - state.discount;

    emit(
      state.copyWith(
        deliveryMethod: method,
        deliveryCost: deliveryCost,
        cartTotal: total,
      ),
    );
  }

  void applyDiscountCode(String code) {
    // Aquí iría la lógica real para validar y aplicar el código de descuento
    // Por ahora solo simularemos un descuento fijo si el código no está vacío

    final discount = code.isNotEmpty ? 1000.0 : 0.0;
    final total = state.subtotal + state.tax + state.deliveryCost - discount;

    emit(
      state.copyWith(discountCode: code, discount: discount, cartTotal: total),
    );
  }

  double _calculateSubtotal(List<CartItem> items) {
    double subtotal = 0.0;
    for (final item in items) {
      subtotal += item.price * item.quantity;
    }
    return subtotal;
  }
}
