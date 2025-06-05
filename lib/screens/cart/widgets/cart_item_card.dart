import 'package:flutter/material.dart';
import '../../../core/models/cart_item.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(double) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedPrice = '₡${item.price.toInt()}';
    final formattedTotal = '₡${(item.price * item.quantity).toInt()}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: _buildImage(context),
              ),
            ),
            const SizedBox(width: 12),

            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del producto
                  Text(
                    item.productName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Precio unitario
                  Text(
                    '$formattedPrice / ${item.unit}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtotal y controles de cantidad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Subtotal
                      Text(
                        formattedTotal,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),

                      // Controles de cantidad
                      Row(
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: () {
                              if (item.quantity > 1) {
                                onQuantityChanged(item.quantity - 1);
                              } else {
                                onRemove();
                              }
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            constraints: const BoxConstraints(minWidth: 36),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity.toInt()}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: () {
                              onQuantityChanged(item.quantity + 1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (item.imageUrl.isNotEmpty) {
      return Image.network(
        item.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder(context);
        },
      );
    } else {
      return _buildImagePlaceholder(context);
    }
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withAlpha(25),
      child: Icon(Icons.image, size: 40, color: Theme.of(context).primaryColor),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: Colors.grey[700]),
      ),
    );
  }
}
