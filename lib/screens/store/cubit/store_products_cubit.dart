import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/product_repository_interface.dart';
import '../../../core/repositories/cart_repository.dart';
import '../../../core/models/product.dart';
import '../../../core/models/cart_item.dart';
import 'store_products_state.dart';

class StoreProductsCubit extends Cubit<StoreProductsState> {
  final ProductRepositoryInterface _productRepository;
  final CartRepository _cartRepository;
  final String _storeId;

  StoreProductsCubit({
    required ProductRepositoryInterface productRepository,
    required CartRepository cartRepository,
    required String storeId,
  }) : _productRepository = productRepository,
       _cartRepository = cartRepository,
       _storeId = storeId,
       super(const StoreProductsState());

  Future<void> initialize() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      // Cargar datos de muestra si no existen
      await _productRepository.seedSampleData();

      // Cargar productos
      await loadProducts();

      // Configurar categorías según los productos disponibles
      await setupCategories();

      // Cargar carrito
      await loadCartItems();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> setupCategories() async {
    final products = await _productRepository.getProductsByStore(_storeId);

    if (products.isEmpty) {
      emit(state.copyWith(categories: ['Todos']));
      return;
    }

    // Extraer categorías únicas de los productos
    final uniqueCategories = <String>{};
    for (final product in products) {
      uniqueCategories.add(product.category);
    }

    // Construir la lista de categorías con 'Todos' al principio
    final categories = ['Todos', ...uniqueCategories.toList()..sort()];

    emit(state.copyWith(categories: categories));
  }

  Future<void> loadProducts() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final products = await _productRepository.getProductsByStore(_storeId);

      emit(state.copyWith(isLoading: false, products: products));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadProductsByCategory(String category) async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          error: null,
          selectedCategory: category,
        ),
      );

      final List<Product> products;
      if (category == 'Todos') {
        products = await _productRepository.getProductsByStore(_storeId);
      } else {
        products = await _productRepository.getProductsByCategory(
          _storeId,
          category,
        );
      }

      emit(state.copyWith(isLoading: false, products: products));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadCartItems() async {
    try {
      final cartItems = await _cartRepository.getCartItemsByStore(_storeId);
      final cartTotal = await _cartRepository.getCartTotal();

      // Asegurarse de que incluso si el carrito está vacío, el estado se actualice correctamente
      if (cartItems.isEmpty) {
        emit(
          state.copyWith(
            cartItems: [],
            cartTotal: 0.0,
            hasItemsFromOtherStore: false, // Restablecer el estado de conflicto
            pendingProductToAdd: null, // Limpiar producto pendiente
          ),
        );
      } else {
        emit(
          state.copyWith(
            cartItems: cartItems,
            cartTotal: cartTotal,
            hasItemsFromOtherStore: false, // Restablecer el estado de conflicto
            pendingProductToAdd: null, // Limpiar producto pendiente
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> addToCart(Product product) async {
    try {
      // Primero obtenemos todos los items del carrito (no solo los de esta tienda)
      final allCartItems = await _cartRepository.getCartItems();

      // Verificamos si hay productos de otras tiendas
      final otherStoreItems =
          allCartItems
              .where(
                (item) => item.storeId != _storeId && item.storeId.isNotEmpty,
              )
              .toList();

      // Si hay productos de otras tiendas, notificamos esto en el estado
      if (otherStoreItems.isNotEmpty) {
        final otherStoreId = otherStoreItems.first.storeId;
        emit(
          state.copyWith(
            hasItemsFromOtherStore: true,
            otherStoreId: otherStoreId,
            pendingProductToAdd: product,
          ),
        );
        return;
      }

      // Si no hay conflicto, procedemos normalmente
      final cartItem = CartItem(
        id: '',
        productId: product.id,
        productName: product.name,
        imageUrl: product.imageUrl,
        price: product.price,
        unit: product.unit,
        quantity: product.quantity,
        storeId: product.storeId,
      );

      await _cartRepository.addToCart(cartItem);
      await loadCartItems();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      // Obtener el estado actual
      final currentItems = List<CartItem>.from(state.cartItems);

      // Verificar si el ítem existe para evitar el error "no element"
      final itemIndex = currentItems.indexWhere(
        (item) => item.id == cartItemId,
      );
      if (itemIndex == -1) {
        // Si no existe, solo recargamos del repositorio
        await loadCartItems();
        return;
      }

      // Obtener el item a eliminar
      final itemToRemove = currentItems[itemIndex];

      // Calcular el nuevo total
      final newTotal =
          state.cartTotal - (itemToRemove.price * itemToRemove.quantity);

      // Eliminar el item de la lista
      currentItems.removeAt(itemIndex);

      // Actualizar el estado inmediatamente
      emit(
        state.copyWith(
          cartItems: currentItems,
          cartTotal: newTotal,
          error: null, // Limpiar errores anteriores
        ),
      );

      // Luego realizamos la persistencia en el repositorio
      final bool success = await _cartRepository.removeFromCart(cartItemId);
      if (!success) {
        // Si falla, recargamos del repositorio (recuperar estado original)
        await loadCartItems();
        emit(state.copyWith(error: 'No se pudo eliminar el ítem del carrito'));
      }
    } catch (e) {
      emit(
        state.copyWith(error: 'Error al eliminar del carrito: ${e.toString()}'),
      );
      // Recuperar el estado correcto
      await loadCartItems();
    }
  }

  Future<void> clearCart() async {
    try {
      // Primero actualizamos el estado UI inmediatamente
      emit(state.copyWith(cartItems: [], cartTotal: 0.0));

      // Luego realizamos la persistencia
      final bool success = await _cartRepository.clearCart();
      if (!success) {
        // Si falla, recargamos del repositorio
        await loadCartItems();
        emit(state.copyWith(error: 'No se pudo vaciar el carrito'));
      }
    } catch (e) {
      await loadCartItems(); // Recuperar estado original
      emit(
        state.copyWith(error: 'Error al vaciar el carrito: ${e.toString()}'),
      );
    }
  }

  void selectCategory(String category) {
    loadProductsByCategory(category);
  }

  // Método para confirmar el reemplazo del carrito
  Future<void> confirmReplaceCart() async {
    try {
      // Obtener el producto pendiente
      final product = state.pendingProductToAdd;
      if (product == null) {
        // No hay producto pendiente, simplemente limpiar el carrito existente
        await _cartRepository.clearCart();
        await loadCartItems();

        // Limpiar el estado de conflicto
        emit(
          state.copyWith(
            hasItemsFromOtherStore: false,
            otherStoreId: '',
            pendingProductToAdd: null,
          ),
        );
        return;
      }

      // Limpiar el carrito primero
      await _cartRepository.clearCart();

      // Agregar el nuevo producto
      final cartItem = CartItem(
        id: '',
        productId: product.id,
        productName: product.name,
        imageUrl: product.imageUrl,
        price: product.price,
        unit: product.unit,
        quantity: product.quantity,
        storeId: product.storeId,
      );

      await _cartRepository.addToCart(cartItem);

      // Recargar y actualizar el estado
      await loadCartItems();

      // Limpiar el estado de conflicto
      emit(
        state.copyWith(
          hasItemsFromOtherStore: false,
          otherStoreId: '',
          pendingProductToAdd: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Error al reemplazar el carrito: ${e.toString()}',
          hasItemsFromOtherStore: false,
          otherStoreId: '',
          pendingProductToAdd: null,
        ),
      );
    }
  }

  // Método para cancelar el reemplazo del carrito
  void cancelReplaceCart() {
    emit(
      state.copyWith(
        hasItemsFromOtherStore: false,
        otherStoreId: '',
        pendingProductToAdd: null,
      ),
    );
  }
}
