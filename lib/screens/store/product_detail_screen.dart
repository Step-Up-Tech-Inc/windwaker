import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../core/models/product.dart';
import '../../core/repositories/cart_repository.dart';
import 'cubit/store_products_cubit.dart';
import 'cubit/store_products_state.dart';
import 'widgets/availability_badge.dart';
import 'package:go_router/go_router.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final String storeName;
  final String storeCategory;
  final double storeRating;
  final String deliveryTime;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.storeName = '',
    this.storeCategory = '',
    this.storeRating = 4.5,
    this.deliveryTime = '20-30 min',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => StoreProductsCubit(
            productRepository: GetIt.I(),
            cartRepository: GetIt.I<CartRepository>(),
            storeId: product.storeId,
          ),
      child: _ProductDetailView(
        product: product,
        storeName: storeName,
        storeCategory: storeCategory,
        storeRating: storeRating,
        deliveryTime: deliveryTime,
      ),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  final Product product;
  final String storeName;
  final String storeCategory;
  final double storeRating;
  final String deliveryTime;

  const _ProductDetailView({
    required this.product,
    required this.storeName,
    required this.storeCategory,
    required this.storeRating,
    required this.deliveryTime,
  });

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView>
    with WidgetsBindingObserver {
  late StoreProductsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<StoreProductsCubit>();
    // Inicializar el cubit para cargar los elementos del carrito
    _cubit.initialize();
    // Registrar el observer para detectar cuando la app vuelve al primer plano
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Actualizar el carrito cuando la app vuelve al primer plano
      _cubit.loadCartItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedPrice = '₡${widget.product.price.toInt()}';
    final displayQuantity =
        widget.product.unit == 'g' || widget.product.unit == 'ml'
            ? '${widget.product.quantity.toInt()}${widget.product.unit}'
            : '${widget.product.quantity.toInt()}${widget.product.unit}';

    // Actualizar el carrito al construir la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _cubit.loadCartItems();
      }
    });

    Widget getAvailabilityBadge(ProductStatus status) {
      switch (status) {
        case ProductStatus.available:
          return const AvailabilityBadge(
            text: 'Disponible',
            color: Colors.green,
          );
        case ProductStatus.lowStock:
          return const AvailabilityBadge(
            text: 'Pocas unidades',
            color: Colors.orange,
          );
        case ProductStatus.outOfStock:
          return const AvailabilityBadge(text: 'Agotado', color: Colors.red);
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Detalle del producto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Botón para ir al carrito
          BlocBuilder<StoreProductsCubit, StoreProductsState>(
            buildWhen:
                (previous, current) =>
                    previous.cartItems.isEmpty != current.cartItems.isEmpty ||
                    previous.cartTotal != current.cartTotal,
            builder: (context, state) {
              // Solo mostrar el icono del carrito si hay elementos
              if (state.cartItems.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  // Navegar a la pantalla del carrito
                  context.push(
                    '/cart?storeId=${widget.product.storeId}&storeName=${widget.storeName}'
                    '&storeCategory=${widget.storeCategory}&storeRating=${widget.storeRating}'
                    '&deliveryTime=${widget.deliveryTime}',
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            SizedBox(
              width: double.infinity,
              height: 250,
              child: _buildProductImage(context),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge de disponibilidad
                  getAvailabilityBadge(widget.product.status),

                  const SizedBox(height: 12),

                  // Nombre del producto
                  Text(
                    widget.product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Precio y cantidad
                  Row(
                    children: [
                      Text(
                        formattedPrice,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ $displayQuantity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Descripción
                  Text(
                    'Descripción',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: theme.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 24),

                  // Información de la tienda
                  if (widget.storeName.isNotEmpty) ...[
                    Text(
                      'Vendido por',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.store,
                                color: theme.primaryColor,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.storeName,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.storeCategory,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.storeRating.toString(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<StoreProductsCubit, StoreProductsState>(
        buildWhen:
            (previous, current) =>
                previous.cartItems.isEmpty != current.cartItems.isEmpty ||
                previous.cartTotal != current.cartTotal,
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Botón para agregar al carrito
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _cubit.addToCart(widget.product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Producto agregado al carrito'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Agregar al carrito',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Botón para ir al carrito (solo visible si hay elementos)
                  if (state.cartItems.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        // Navegar a la pantalla del carrito
                        context.push(
                          '/cart?storeId=${widget.product.storeId}&storeName=${widget.storeName}'
                          '&storeCategory=${widget.storeCategory}&storeRating=${widget.storeRating}'
                          '&deliveryTime=${widget.deliveryTime}',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.primaryColor),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shopping_cart),
                          SizedBox(width: 8),
                          Text(
                            'Ver carrito',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    if (widget.product.imageUrl.isNotEmpty &&
        !widget.product.imageUrl.startsWith('assets/')) {
      return Image.network(
        widget.product.imageUrl,
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
      child: Center(
        child: Icon(
          Icons.image,
          size: 80,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
