import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import '../../core/models/cart_item.dart';
import '../../core/repositories/cart_repository.dart';
import '../checkout/checkout_screen.dart';
import 'cubit/cart_screen_cubit.dart';
import 'cubit/cart_screen_state.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/discount_code_field.dart';
import 'widgets/delivery_method_selector.dart';
import 'widgets/store_info_card.dart';
import 'widgets/order_summary_card.dart';

class CartScreen extends HookWidget {
  final String? storeId;
  final String storeName;
  final String storeCategory;
  final double storeRating;
  final String deliveryTime;

  const CartScreen({
    super.key,
    this.storeId,
    this.storeName = '',
    this.storeCategory = '',
    this.storeRating = 4.5,
    this.deliveryTime = '20-30 min',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => CartScreenCubit(
            cartRepository: GetIt.I<CartRepository>(),
            storeId: storeId,
            storeName: storeName,
            storeCategory: storeCategory,
            storeRating: storeRating,
            deliveryTime: deliveryTime,
          )..initialize(),
      child: const _CartScreenView(),
    );
  }
}

class _CartScreenView extends HookWidget {
  const _CartScreenView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<CartScreenCubit>();
    final discountCodeController = useTextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Carrito de Compras',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          BlocBuilder<CartScreenCubit, CartScreenState>(
            buildWhen:
                (previous, current) =>
                    previous.cartItems.isEmpty != current.cartItems.isEmpty,
            builder: (context, state) {
              if (state.cartItems.isEmpty) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Vaciar carrito',
                onPressed: () {
                  // Mostrar diálogo de confirmación
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Vaciar carrito'),
                          content: const Text(
                            '¿Estás seguro de que deseas vaciar tu carrito?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                cubit.clearCart();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Vaciar'),
                            ),
                          ],
                        ),
                  );
                },
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: BlocConsumer<CartScreenCubit, CartScreenState>(
        listener: (context, state) {
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

          if (state.cartItems.isEmpty) {
            return _buildEmptyCart(context);
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lista de productos
                  _buildCartItemsList(context, state.cartItems),

                  const SizedBox(height: 16),

                  // Campo de código de descuento
                  DiscountCodeField(
                    controller: discountCodeController,
                    onApply: () {
                      cubit.applyDiscountCode(discountCodeController.text);
                      FocusScope.of(context).unfocus();
                    },
                  ),

                  const SizedBox(height: 16),

                  // Selector de método de entrega
                  DeliveryMethodSelector(
                    selectedMethod: state.deliveryMethod,
                    onMethodSelected: (method) {
                      cubit.changeDeliveryMethod(method);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Información del restaurante
                  StoreInfoCard(
                    storeName: state.storeName,
                    storeCategory: state.storeCategory,
                    storeRating: state.storeRating,
                    deliveryTime: state.deliveryTime,
                  ),

                  const SizedBox(height: 16),

                  // Resumen del pedido
                  OrderSummaryCard(
                    subtotal: state.subtotal,
                    tax: state.tax,
                    deliveryCost: state.deliveryCost,
                    discount: state.discount,
                    total: state.cartTotal,
                  ),

                  const SizedBox(height: 24),

                  // Botón de proceder al pago
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => CheckoutScreen(
                                  cartItems: state.cartItems,
                                  subtotal: state.subtotal,
                                  tax: state.tax,
                                  deliveryCost: state.deliveryCost,
                                  discount: state.discount,
                                  total: state.cartTotal,
                                  storeName: state.storeName,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Proceder al pago',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildEmptyCart(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tu carrito está vacío',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega productos para comenzar tu pedido',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Volver a la tienda'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(BuildContext context, List<CartItem> items) {
    final cubit = context.read<CartScreenCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productos',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return CartItemCard(
              item: item,
              onQuantityChanged: (quantity) {
                final updatedItem = item.copyWith(quantity: quantity);
                cubit.updateCartItem(updatedItem);
              },
              onRemove: () {
                cubit.removeFromCart(item.id);
              },
            );
          },
        ),
      ],
    );
  }
}
