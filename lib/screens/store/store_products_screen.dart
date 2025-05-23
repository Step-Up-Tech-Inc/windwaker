import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import '../../core/models/product.dart';
import '../../core/repositories/product_repository_interface.dart';
import '../../core/repositories/cart_repository.dart';
import 'cubit/store_products_cubit.dart';
import 'cubit/store_products_state.dart';
import 'widgets/product_card.dart';
import 'widgets/category_selector.dart';
import 'widgets/cart_bottom_sheet.dart';
import 'widgets/availability_badge.dart';

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
      child: _StoreProductsView(storeName: storeName),
    );
  }
}

class _StoreProductsView extends HookWidget {
  final String storeName;

  const _StoreProductsView({required this.storeName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<StoreProductsCubit>();

    useEffect(() {
      cubit.initialize();
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              storeName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            BlocBuilder<StoreProductsCubit, StoreProductsState>(
              builder: (context, state) {
                return Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '4.6',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(' (150+ reseñas)', style: theme.textTheme.bodyMedium),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.black87),
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
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          BlocBuilder<StoreProductsCubit, StoreProductsState>(
            builder: (context, state) {
              return CategorySelector(
                categories: state.categories,
                selectedCategory: state.selectedCategory,
                onCategorySelected: (category) {
                  cubit.selectCategory(category);
                },
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<StoreProductsCubit, StoreProductsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.error != null) {
                  return Center(
                    child: Text(
                      'Error: ${state.error}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.red,
                      ),
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
        ],
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

          return CartBottomSheet(
            itemCount: state.cartItems.length,
            total: state.cartTotal,
            cartItems: state.cartItems,
            onRemoveItem: (itemId) {
              // Primero actualizamos el estado
              context.read<StoreProductsCubit>().removeFromCart(itemId);

              // Mostrar feedback al usuario
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Producto eliminado del carrito'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            onClearCart: () {
              context.read<StoreProductsCubit>().clearCart();

              // Mostrar feedback al usuario
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Carrito vaciado correctamente'),
                  duration: Duration(seconds: 2),
                ),
              );

              // No navegamos aquí, solo actualizamos el estado
            },
            onCheckout: () {
              // Aquí se implementará la lógica de checkout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad de checkout en desarrollo'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
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
            padding: const EdgeInsets.only(bottom: 16.0),
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
    IconData headerIcon;

    switch (category) {
      case 'Frutas':
        headerText = 'Fresh fruits';
        subtitleText = 'Fresh fruits and vegetables';
        headerIcon = Icons.eco;
        break;
      case 'Verduras':
        headerText = 'Fresh vegetables';
        subtitleText = 'Fresh vegetables';
        headerIcon = Icons.grass;
        break;
      case 'Lácteos':
        headerText = 'Dairy products';
        subtitleText = 'Milk, cheese and more';
        headerIcon = Icons.egg;
        break;
      case 'Carnes':
        headerText = 'Meat products';
        subtitleText = 'Fresh meat and poultry';
        headerIcon = Icons.restaurant;
        break;
      case 'Hamburguesas':
        headerText = 'Hamburgers';
        subtitleText = 'Delicious burgers';
        headerIcon = Icons.lunch_dining;
        break;
      case 'Pizzas':
        headerText = 'Pizzas';
        subtitleText = 'Italian style pizzas';
        headerIcon = Icons.local_pizza;
        break;
      case 'Acompañamientos':
        headerText = 'Side dishes';
        subtitleText = 'Perfect companions';
        headerIcon = Icons.dining;
        break;
      case 'Bebidas':
        headerText = 'Drinks';
        subtitleText = 'Refreshing drinks';
        headerIcon = Icons.local_drink;
        break;
      case 'Medicamentos':
        headerText = 'Medicines';
        subtitleText = 'Health products';
        headerIcon = Icons.medication;
        break;
      case 'Primeros Auxilios':
        headerText = 'First aid';
        subtitleText = 'Emergency products';
        headerIcon = Icons.healing;
        break;
      case 'Suplementos':
        headerText = 'Supplements';
        subtitleText = 'Vitamins and supplements';
        headerIcon = Icons.fitness_center;
        break;
      default:
        if (category == 'Todos') {
          headerText = 'All products';
          subtitleText = 'Browse all categories';
          headerIcon = Icons.category;
        } else {
          // Para cualquier otra categoría no definida explícitamente
          headerText = category;
          subtitleText = 'Products in this category';
          headerIcon = Icons.shopping_bag;
        }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
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
          Icon(headerIcon, size: 24, color: Colors.grey[700]),
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, Product product) {
    final cubit = context.read<StoreProductsCubit>();

    return ProductCard(
      name: product.name,
      imageUrl: product.imageUrl,
      price: product.price,
      unit: product.unit,
      quantity: product.quantity,
      availabilityBadge: _getAvailabilityBadge(product.status),
      onAddToCart: () {
        cubit.addToCart(product);
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
}
