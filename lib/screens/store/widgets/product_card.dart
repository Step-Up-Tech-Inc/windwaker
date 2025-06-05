import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double price;
  final String unit;
  final double quantity;
  final Widget availabilityBadge;
  final VoidCallback onAddToCart;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.availabilityBadge,
    required this.onAddToCart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedPrice = '₡${price.toInt()}';
    final displayQuantity =
        unit == 'g' || unit == 'ml'
            ? '${quantity.toInt()}$unit'
            : '$quantity$unit';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withAlpha(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: _buildProductImage(context),
                    ),
                  ),
                  Positioned(top: 8, right: 8, child: availabilityBadge),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayQuantity,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedPrice,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        _AddToCartButton(onTap: onAddToCart),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    // Si la URL comienza con assets/, intentamos cargar un recurso local
    if (imageUrl.startsWith('assets/')) {
      return _buildProductPlaceholder(
        icon: Icons.shopping_bag,
        backgroundColor: Theme.of(context).primaryColor.withAlpha(10),
        iconColor: Theme.of(context).primaryColor,
      );
    }

    // Si no, intentamos cargar la imagen desde la red
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildProductPlaceholder(
          icon: Icons.image,
          backgroundColor: Colors.grey[100]!,
          iconColor: Colors.grey[400]!,
        );
      },
    );
  }

  Widget _buildProductPlaceholder({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      color: backgroundColor,
      child: Center(child: Icon(icon, size: 40, color: iconColor)),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddToCartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.add_shopping_cart,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
