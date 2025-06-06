import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/negocio.dart';
import '../../core/models/cart_item.dart';
import 'cubit/home_cubit.dart';
import 'widgets/promotion_carousel.dart';
import 'widgets/category_carousel.dart';
import '../search/widgets/bottom_navigation.dart';
import 'package:go_router/go_router.dart';
import '../store/store_products_screen.dart';
import '../cart/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _ubicacionExpandida = false;

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return state.map(
              initial: (_) => const SizedBox.shrink(),
              loading: (_) => const Center(child: CircularProgressIndicator()),
              loaded: (loaded) => _buildLoadedState(context, loaded),
              error:
                  (error) => Center(
                    child: SelectableText.rich(
                      TextSpan(
                        text: 'Error: ${error.message}',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildLoadedState(BuildContext context, HomeState loaded) {
    // Extraer los datos del estado loaded
    final String ciudad = (loaded as dynamic).ciudad;
    final List<Negocio> negocios = (loaded as dynamic).negocios;

    return CustomScrollView(
      slivers: [
        _buildCustomHeader(ciudad),
        if (_ubicacionExpandida)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.place_outlined, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Próximamente podrás ajustar tu ubicación exacta aquí (pin en el mapa, dirección, etc.)',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar tiendas y productos',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(Icons.search, color: Colors.grey, size: 22),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  filled: true,
                  fillColor: Colors.transparent,
                  isDense: true,
                ),
                enabled: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    context.go('/search?query=$value');
                  } else {
                    context.go('/search');
                  }
                },
                onTap: () {
                  // Opcionalmente, se puede navegar directamente al hacer clic
                  // context.go('/search');
                },
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'Categorías',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: CategoryCarousel()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'Promociones',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverToBoxAdapter(child: const PromotionCarousel()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'Tiendas populares',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final negocio = negocios[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: _buildNegocioListItem(negocio),
            );
          }, childCount: negocios.length),
        ),
        // Añadir espacio al final para evitar que el último elemento quede oculto
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _buildNegocioListItem(Negocio negocio) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => StoreProductsScreen(
                    storeId: negocio.id,
                    storeName: negocio.nombre,
                  ),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del negocio
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  Image.network(
                    negocio.imagenUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.error_outline, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                  if (negocio.esDestacado)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Información del negocio
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      negocio.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          negocio.calificacion.toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Text(
                          " • ",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '${negocio.tiempoEntregaMin}-${negocio.tiempoEntregaMax} min',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.delivery_dining,
                          color: Colors.grey[600],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '₡${negocio.costoEnvio.toInt()} Envío',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Botón de favorito
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
              child: IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // Acción para marcar como favorito (para el futuro)
                },
                color: Colors.grey,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(String ciudad) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sección de ubicación
            GestureDetector(
              onTap: () {
                setState(() {
                  _ubicacionExpandida = !_ubicacionExpandida;
                });
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 20,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Entregar a',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Row(
                        children: [
                          Text(
                            'Guanacaste, $ciudad',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AnimatedRotation(
                            turns: _ubicacionExpandida ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Botones de acción
            Row(
              children: [
                // Botón del carrito
                BlocBuilder<HomeCubit, HomeState>(
                  buildWhen: (previous, current) {
                    // Verificar estado del carrito
                    if (previous.maybeMap(
                              loaded: (loaded) => loaded,
                              orElse: () => null,
                            ) !=
                            null &&
                        current.maybeMap(
                              loaded: (loaded) => loaded,
                              orElse: () => null,
                            ) !=
                            null) {
                      final previousLoaded =
                          previous.maybeMap(
                            loaded: (state) => state,
                            orElse: () => null,
                          )!;
                      final currentLoaded =
                          current.maybeMap(
                            loaded: (state) => state,
                            orElse: () => null,
                          )!;

                      return previousLoaded.cartItems.length !=
                              currentLoaded.cartItems.length ||
                          previousLoaded.cartTotal != currentLoaded.cartTotal;
                    }
                    return false;
                  },
                  builder: (context, state) {
                    // Extraer estado cargado si existe
                    final loadedState = state.maybeMap(
                      loaded: (loaded) => loaded,
                      orElse: () => null,
                    );

                    if (loadedState != null &&
                        loadedState.cartItems.isNotEmpty) {
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined),
                            onPressed: () {
                              // Mostrar diálogo con contenido del carrito
                              _showCartDialog(
                                context,
                                loadedState.cartItems,
                                loadedState.cartTotal,
                              );
                            },
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${loadedState.cartItems.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      onPressed: () {
                        // Mostrar diálogo indicando que el carrito está vacío
                        _showEmptyCartDialog(context);
                      },
                    );
                  },
                ),
                // Botón de notificaciones
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // Sin funcionalidad por ahora
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Método para navegar al carrito de manera segura
  void _navigateToCart(BuildContext context, String storeId, String storeName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CartScreen(
              storeId: storeId,
              storeName: storeName,
              storeCategory: 'Tienda',
              storeRating: 4.6,
              deliveryTime: '15-25 min',
            ),
      ),
    ).then((_) {
      // Verificar si el widget sigue montado antes de actualizar
      if (mounted) {
        // ignore: use_build_context_synchronously
        context.read<HomeCubit>().loadCartItems();
      }
    });
  }

  void _showCartDialog(
    BuildContext context,
    List<CartItem> cartItems,
    double cartTotal,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.shopping_cart, color: theme.primaryColor),
                const SizedBox(width: 8),
                const Text('Tu Carrito'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cartItems.isNotEmpty) ...[
                    const Text('Productos en tu carrito:'),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: SizedBox(
                              width: 40,
                              height: 40,
                              child: _buildCartItemImage(item),
                            ),
                            title: Text(
                              item.productName,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${item.quantity.toInt()} x ₡${item.price.toInt()}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              '₡${(item.quantity * item.price).toInt()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[300]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₡${cartTotal.toInt()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cerrar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  if (cartItems.isNotEmpty) {
                    final storeId = cartItems.first.storeId;
                    final storeName =
                        'Tienda'; // Aquí deberías obtener el nombre real

                    _navigateToCart(context, storeId, storeName);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                ),
                child: const Text('Ver carrito completo'),
              ),
            ],
          ),
    );
  }

  // Método para mostrar diálogo cuando el carrito está vacío
  void _showEmptyCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Carrito Vacío'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Tu carrito está vacío',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Añade productos de cualquier tienda para comenzar a llenar tu carrito',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  // Método para construir la imagen del ítem del carrito
  Widget _buildCartItemImage(CartItem item) {
    if (item.imageUrl.isNotEmpty) {
      return Image.network(
        item.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildCartItemImagePlaceholder();
        },
      );
    } else {
      return _buildCartItemImagePlaceholder();
    }
  }

  // Método para construir el placeholder de la imagen
  Widget _buildCartItemImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}
