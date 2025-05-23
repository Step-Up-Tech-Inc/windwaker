import 'package:flutter/material.dart';
import '../../../core/models/cart_item.dart';
import 'cart_detail_sheet.dart';

class CartBottomSheet extends StatelessWidget {
  final int itemCount;
  final double total;
  final List<CartItem> cartItems;
  final Function(String) onRemoveItem;
  final VoidCallback onClearCart;
  final VoidCallback onCheckout;

  const CartBottomSheet({
    super.key,
    required this.itemCount,
    required this.total,
    required this.cartItems,
    required this.onRemoveItem,
    required this.onClearCart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedTotal = '₡${total.toInt()}';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: () => _showCartDetail(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  formattedTotal,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCartDetail(BuildContext context) {
    // Crear copias locales de los datos para manejar actualizaciones dentro del modal
    List<CartItem> modalCartItems = List.from(cartItems);
    double modalTotal = total;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModalState) {
            // Función para manejar eliminación de productos
            void handleRemoveItem(String itemId) {
              // Encontrar el item para actualizar el total
              final itemIndex = modalCartItems.indexWhere(
                (item) => item.id == itemId,
              );
              if (itemIndex != -1) {
                final item = modalCartItems[itemIndex];
                // Actualizar total local
                modalTotal -= (item.price * item.quantity);
                // Eliminar de la lista local
                modalCartItems.removeAt(itemIndex);
                // Actualizar la UI del modal
                setModalState(() {});

                // Llamar al callback para actualizar el estado global
                onRemoveItem(itemId);

                // Si no quedan productos, cerrar el modal
                if (modalCartItems.isEmpty) {
                  Navigator.pop(modalContext);
                }
              }
            }

            // Función para manejar vaciado del carrito
            void handleClearCart() {
              setModalState(() {
                modalCartItems = [];
                modalTotal = 0;
              });

              // Llamar al callback para vaciar el carrito en el estado global
              onClearCart();

              // Cerrar el modal después de un pequeño retraso
              Future.delayed(const Duration(milliseconds: 300), () {
                if (modalContext.mounted) {
                  Navigator.pop(modalContext);
                }
              });
            }

            return CartDetailSheet(
              cartItems: modalCartItems,
              total: modalTotal,
              onRemoveItem: handleRemoveItem,
              onClearCart: handleClearCart,
              onCheckout: onCheckout,
            );
          },
        );
      },
    );
  }
}
