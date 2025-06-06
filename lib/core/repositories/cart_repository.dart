import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';

class CartRepository {
  final SharedPreferences _sharedPreferences;
  final String _cartItemsKey = 'cart_items';
  final _uuid = const Uuid();

  // Stream controller para notificar cambios en el carrito
  final _cartChangedController = StreamController<bool>.broadcast();
  Stream<bool> get cartChanged => _cartChangedController.stream;

  CartRepository(this._sharedPreferences);

  // Método para notificar a los oyentes que el carrito ha cambiado
  void notifyCartChanged() {
    _cartChangedController.add(true);
  }

  // Obtener todos los ítems del carrito
  Future<List<CartItem>> getCartItems() async {
    try {
      final cartItemsJson =
          _sharedPreferences.getStringList(_cartItemsKey) ?? [];
      final cartItems =
          cartItemsJson
              .map(
                (json) =>
                    CartItem.fromJson(jsonDecode(json) as Map<String, dynamic>),
              )
              .toList();

      return cartItems;
    } catch (e) {
      return [];
    }
  }

  // Obtener ítems del carrito para una tienda específica
  Future<List<CartItem>> getCartItemsByStore(String storeId) async {
    final cartItems = await getCartItems();
    return cartItems.where((item) => item.storeId == storeId).toList();
  }

  // Añadir un ítem al carrito
  Future<CartItem> addToCart(CartItem cartItem) async {
    try {
      final cartItems = await getCartItems();
      final existingItemIndex = cartItems.indexWhere(
        (item) =>
            item.productId == cartItem.productId &&
            item.storeId == cartItem.storeId,
      );

      if (existingItemIndex != -1) {
        // El producto ya está en el carrito, actualizar cantidad
        final updatedItem = cartItems[existingItemIndex].copyWith(
          quantity: cartItems[existingItemIndex].quantity + cartItem.quantity,
        );
        cartItems[existingItemIndex] = updatedItem;

        final updatedCartItemsJson =
            cartItems.map((item) => jsonEncode(item.toJson())).toList();
        await _sharedPreferences.setStringList(
          _cartItemsKey,
          updatedCartItemsJson,
        );

        // Notificar cambio
        notifyCartChanged();

        return updatedItem;
      } else {
        // Nuevo producto en el carrito
        final newCartItem = cartItem.copyWith(
          id: _uuid.v4(),
          createdAt: DateTime.now(),
        );

        final cartItemsJson =
            _sharedPreferences.getStringList(_cartItemsKey) ?? [];
        cartItemsJson.add(jsonEncode(newCartItem.toJson()));
        await _sharedPreferences.setStringList(_cartItemsKey, cartItemsJson);

        // Notificar cambio
        notifyCartChanged();

        return newCartItem;
      }
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  // Actualizar un ítem del carrito
  Future<CartItem> updateCartItem(CartItem cartItem) async {
    try {
      final cartItems = await getCartItems();
      final index = cartItems.indexWhere((item) => item.id == cartItem.id);

      if (index == -1) {
        throw Exception('Cart item not found');
      }

      cartItems[index] = cartItem;
      final updatedCartItemsJson =
          cartItems.map((item) => jsonEncode(item.toJson())).toList();
      await _sharedPreferences.setStringList(
        _cartItemsKey,
        updatedCartItemsJson,
      );

      // Notificar cambio
      notifyCartChanged();

      return cartItem;
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  // Eliminar un ítem del carrito
  Future<bool> removeFromCart(String cartItemId) async {
    try {
      final cartItems = await getCartItems();

      // Verificar si el ítem existe
      final existingItemIndex = cartItems.indexWhere(
        (item) => item.id == cartItemId,
      );
      if (existingItemIndex == -1) {
        return false; // Ítem no encontrado
      }

      final updatedCartItems =
          cartItems.where((item) => item.id != cartItemId).toList();
      final updatedCartItemsJson =
          updatedCartItems.map((item) => jsonEncode(item.toJson())).toList();

      final success = await _sharedPreferences.setStringList(
        _cartItemsKey,
        updatedCartItemsJson,
      );

      // Notificar cambio
      notifyCartChanged();

      return success;
    } catch (e) {
      return false;
    }
  }

  // Limpiar el carrito
  Future<bool> clearCart() async {
    try {
      final success = await _sharedPreferences.setStringList(_cartItemsKey, []);

      // Notificar cambio
      notifyCartChanged();

      return success;
    } catch (e) {
      return false;
    }
  }

  // Obtener el total del carrito
  Future<double> getCartTotal() async {
    final cartItems = await getCartItems();
    double total = 0;
    for (final item in cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  // Obtener la cantidad de ítems en el carrito
  Future<int> getCartItemCount() async {
    final cartItems = await getCartItems();
    return cartItems.length;
  }
}
