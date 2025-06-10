import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import '../../core/models/product.dart';
import '../../core/repositories/product_repository_interface.dart';
import '../../core/repositories/cart_repository.dart';
import '../cart/cart_screen.dart';
import 'cubit/store_products_cubit.dart';
import 'cubit/store_products_state.dart';
import 'widgets/product_card.dart';
import 'widgets/category_selector.dart';
import 'widgets/availability_badge.dart';
import 'product_detail_screen.dart';

class StoreProductsScreen extends HookWidget {
  final String storeId;
  final String storeName;

  const StoreProductsScreen({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => StoreProductsCubit(
            productRepository: GetIt.I<ProductRepositoryInterface>(),
            cartRepository: GetIt.I<CartRepository>(),
            storeId: storeId,
          )..initialize(),
      child: _StoreProductsView(storeName: storeName, storeId: storeId),
    );
  }
}

class _StoreProductsView extends StatefulWidget {
  final String storeName;
  final String storeId;

  const _StoreProductsView({required this.storeName, required this.storeId});

  @override
  State<_StoreProductsView> createState() => _StoreProductsViewState();
}

class _StoreProductsViewState extends State<_StoreProductsView>
    with WidgetsBindingObserver {
  late StoreProductsCubit _cubit;
  late ScrollController _scrollController;
  bool _dialogShown =
      false; // Bandera para controlar si ya se mostró el diálogo

  @override
  void initState() {
    super.initState();
    _cubit = context.read<StoreProductsCubit>();
    _scrollController = ScrollController();

    // Inicializar el cubit
    _cubit.initialize();

    // Registrar el observer para actualizar cuando la app vuelva al primer plano
    WidgetsBinding.instance.addObserver(this);

    // Para detectar cuando la pantalla recibe el foco de nuevo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _cubit.loadCartItems();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Actualizar el carrito cuando la app vuelve al primer plano
      setState(() {
        _dialogShown =
            false; // Resetear la bandera para permitir que el diálogo aparezca si es necesario
      });
      _cubit.loadCartItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 60.0, // Reducimos la altura
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title:
                  innerBoxIsScrolled
                      ? Text(
                        widget.storeName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      )
                      : null,
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.storeName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<StoreProductsCubit, StoreProductsState>(
                      builder: (context, state) {
                        return Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '4.6',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' (150+ reseñas)',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '15-25 min',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverCategoryDelegate(
                child: BlocBuilder<StoreProductsCubit, StoreProductsState>(
                  builder: (context, state) {
                    return CategorySelector(
                      categories: state.categories,
                      selectedCategory: state.selectedCategory,
                      onCategorySelected: (category) {
                        _cubit.selectCategory(category);
                      },
                    );
                  },
                ),
              ),
            ),
          ];
        },
        body: BlocConsumer<StoreProductsCubit, StoreProductsState>(
          listenWhen: (previous, current) {
            // Solo escuchar cuando hay cambios en estos estados específicos
            final hasErrorChange =
                previous.error != current.error && current.error != null;
            final hasConflictChange =
                !previous.hasItemsFromOtherStore &&
                current.hasItemsFromOtherStore;
            return hasErrorChange || hasConflictChange;
          },
          listener: (context, state) {
            // Mostrar diálogo si hay productos de otra tienda y no se ha mostrado el diálogo aún
            if (state.hasItemsFromOtherStore && !_dialogShown) {
              _dialogShown = true; // Marcar que ya se mostró
              _showStoreConflictDialog(context, state);
            }

            // Mostrar errores
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(
                child: Text(
                  'Error: ${state.error}',
                  style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
                ),
              );
            }

            if (state.products.isEmpty) {
              return Center(
                child: Text(
                  'No hay productos disponibles',
                  style: theme.textTheme.bodyLarge,
                ),
              );
            }

            return _buildProductSection(context, state);
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<StoreProductsCubit, StoreProductsState>(
        buildWhen:
            (previous, current) =>
                previous.cartItems != current.cartItems ||
                previous.cartTotal != current.cartTotal,
        builder: (context, state) {
          if (state.cartItems.isEmpty) {
            return const SizedBox.shrink();
          }

          final formattedTotal = '₡${state.cartTotal.toInt()}';
          return SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a la nueva pantalla del carrito
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CartScreen(
                            storeId: widget.storeId,
                            storeName: widget.storeName,
                            storeCategory: 'Tienda', // Puedes ajustar esto
                            storeRating: 4.6, // Puedes ajustar esto
                            deliveryTime: '15-25 min', // Puedes ajustar esto
                          ),
                    ),
                  ).then((_) {
                    // Recargar datos del carrito al volver
                    if (mounted) {
                      _cubit.loadCartItems();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      '${state.cartItems.length} ${state.cartItems.length == 1 ? 'item' : 'items'} - $formattedTotal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ver carrito',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductSection(BuildContext context, StoreProductsState state) {
    final products = state.products;
    final selectedCategory = state.selectedCategory;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildCategoryHeader(context, selectedCategory),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = products[index];
                return _buildProductItem(context, product);
              }, childCount: products.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String category) {
    final theme = Theme.of(context);

    String headerText;
    String subtitleText;

    switch (category) {
      case 'Frutas':
        headerText = 'Frutas frescas';
        subtitleText = 'Frutas y verduras frescas';
        break;
      case 'Verduras':
        headerText = 'Verduras frescas';
        subtitleText = 'Verduras frescas';
        break;
      case 'Lácteos':
        headerText = 'Productos lácteos';
        subtitleText = 'Leche, queso y más';
        break;
      case 'Carnes':
        headerText = 'Productos cárnicos';
        subtitleText = 'Carne y aves frescas';
        break;
      case 'Hamburguesas':
        headerText = 'Hamburguesas';
        subtitleText = 'Deliciosas hamburguesas';
        break;
      case 'Pizzas':
        headerText = 'Pizzas';
        subtitleText = 'Pizzas al estilo italiano';
        break;
      case 'Acompañamientos':
        headerText = 'Acompañamientos';
        subtitleText = 'Complementos perfectos';
        break;
      case 'Bebidas':
        headerText = 'Bebidas';
        subtitleText = 'Bebidas refrescantes';
        break;
      case 'Medicamentos':
        headerText = 'Medicamentos';
        subtitleText = 'Productos de salud';
        break;
      case 'Primeros Auxilios':
        headerText = 'Primeros auxilios';
        subtitleText = 'Productos de emergencia';
        break;
      case 'Suplementos':
        headerText = 'Suplementos';
        subtitleText = 'Vitaminas y suplementos';
        break;
      default:
        if (category == 'Todos') {
          headerText = 'Todos los productos';
          subtitleText = 'Explorar todas las categorías';
        } else {
          // Para cualquier otra categoría no definida explícitamente
          headerText = category;
          subtitleText = 'Productos en esta categoría';
        }
    }

    return Container(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerText,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, Product product) {
    return ProductCard(
      name: product.name,
      imageUrl: product.imageUrl,
      price: product.price,
      unit: product.unit,
      quantity: product.quantity,
      availabilityBadge: _getAvailabilityBadge(product.status),
      onAddToCart: () {
        // Resetear la bandera de diálogo antes de intentar agregar al carrito
        setState(() {
          _dialogShown = false;
        });
        _cubit.addToCart(product);
      },
      onTap: () {
        // Navegar a la pantalla de detalle del producto
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailScreen(
                  product: product,
                  storeName: widget.storeName,
                  storeCategory:
                      'Tienda', // Aquí podrías obtener la categoría real
                  storeRating: 4.6, // Aquí podrías obtener el rating real
                  deliveryTime:
                      '15-25 min', // Aquí podrías obtener el tiempo real
                ),
          ),
        );
      },
    );
  }

  Widget _getAvailabilityBadge(ProductStatus status) {
    switch (status) {
      case ProductStatus.available:
        return const AvailabilityBadge(text: 'Disponible', color: Colors.green);
      case ProductStatus.lowStock:
        return const AvailabilityBadge(
          text: 'Pocas unidades',
          color: Colors.orange,
        );
      case ProductStatus.outOfStock:
        return const AvailabilityBadge(text: 'Agotado', color: Colors.red);
    }
  }

  // Método para mostrar el diálogo de conflicto entre tiendas
  void _showStoreConflictDialog(
    BuildContext context,
    StoreProductsState state,
  ) {
    // Evitar mostrar el diálogo múltiples veces
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => AlertDialog(
              title: const Text('Cambiar de tienda'),
              content: Text(
                'Tienes productos de otra tienda en tu carrito. '
                'Si continúas, tu carrito actual será eliminado y se '
                'iniciará uno nuevo con este producto.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _cubit.cancelReplaceCart();
                    _dialogShown = false; // Resetear la bandera
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _cubit.confirmReplaceCart();
                    _dialogShown = false; // Resetear la bandera
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text('Continuar'),
                ),
              ],
            ),
      );
    });
  }
}

class _SliverCategoryDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverCategoryDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Calcular la opacidad basada en el desplazamiento
    // shrinkOffset es mayor a 0 cuando hay scroll
    final double opacity = shrinkOffset > 10 ? 1.0 : 0.0;

    // Añadir sombra para dar sensación de profundidad cuando se hace scroll
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(
                26,
              ), // 0.1 aproximado en alpha (255 * 0.1 = 25.5)
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: child,
      ),
    );
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
