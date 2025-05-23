import 'package:flutter/material.dart';
import '../../../core/models/cart_item.dart';

class CartDetailSheet extends StatelessWidget {
  final List<CartItem> cartItems;
  final double total;
  final Function(String) onRemoveItem;
  final VoidCallback onClearCart;
  final VoidCallback onCheckout;

  const CartDetailSheet({
    super.key,
    required this.cartItems,
    required this.total,
    required this.onRemoveItem,
    required this.onClearCart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Lista local para mostrar
    final List<CartItem> displayedItems = List.from(cartItems);

    // Calcular el total en base a los items para garantizar sincronización
    double displayedTotal = total;
    if (displayedItems.isEmpty && displayedTotal > 0) {
      displayedTotal = 0.0; // Si no hay items pero hay total, corregir
    }

    final formattedTotal = '₡${displayedTotal.toInt()}';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabecera
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, size: 24),
                const SizedBox(width: 16),
                Text(
                  'Carrito de compras',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Lista de productos
          Expanded(
            child:
                displayedItems.isEmpty
                    ? _buildEmptyCart(context)
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: displayedItems.length,
                      separatorBuilder:
                          (context, index) => const Divider(height: 1),
                      itemBuilder:
                          (context, index) =>
                              _buildCartItem(context, displayedItems[index]),
                    ),
          ),

          const Divider(height: 1),

          // Total y acciones
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formattedTotal,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Vaciar'),
                        onPressed:
                            displayedItems.isEmpty
                                ? null
                                : () {
                                  // Llamar al método para vaciar carrito
                                  onClearCart();
                                  // No cerramos el modal aquí, se cerrará en el BLoC si es necesario
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Carrito vaciado correctamente',
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_cart_checkout),
                        label: const Text('Realizar pedido'),
                        onPressed:
                            displayedItems.isEmpty
                                ? null
                                : () {
                                  // Mostrar un mensaje de confirmación
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Procesando tu pedido...'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.of(
                                    context,
                                  ).pop(); // Cerrar el sheet
                                  onCheckout();
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tu carrito está vacío',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega productos desde la tienda',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    final theme = Theme.of(context);
    final formattedPrice = '₡${item.price.toInt()}';
    final formattedSubtotal = '₡${(item.price * item.quantity).toInt()}';
    final displayQuantity =
        item.unit == 'g' || item.unit == 'ml'
            ? '${item.quantity.toInt()}${item.unit}'
            : '${item.quantity}${item.unit}';

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        onRemoveItem(item.id);
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildItemImage(context, item),
        title: Text(
          item.productName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '$formattedPrice / $displayQuantity',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cantidad: ${item.quantity}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  formattedSubtotal,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.red,
                ),
                onPressed: () => onRemoveItem(item.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage(BuildContext context, CartItem item) {
    if (item.imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 50,
          height: 50,
          child: Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder(context);
            },
          ),
        ),
      );
    } else {
      return _buildImagePlaceholder(context);
    }
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.shopping_bag, color: Theme.of(context).primaryColor),
    );
  }
}
