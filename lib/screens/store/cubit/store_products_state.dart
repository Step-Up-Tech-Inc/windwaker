import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/models/product.dart';
import '../../../core/models/cart_item.dart';

part 'store_products_state.freezed.dart';

@freezed
class StoreProductsState with _$StoreProductsState {
  const factory StoreProductsState({
    @Default(false) bool isLoading,
    @Default(null) String? error,
    @Default([]) List<Product> products,
    @Default([]) List<CartItem> cartItems,
    @Default('Todos') String selectedCategory,
    @Default(['Todos']) List<String> categories,
    @Default(0.0) double cartTotal,
    // Propiedades para manejar conflictos entre tiendas
    @Default(false) bool hasItemsFromOtherStore,
    @Default('') String otherStoreId,
    Product? pendingProductToAdd,
  }) = _StoreProductsState;
}
