import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import '../../core/models/cart_item.dart';
import '../../core/repositories/cart_repository.dart';
import '../../core/services/order_service.dart';
import 'cubit/checkout_cubit.dart';
import 'cubit/checkout_state.dart';
import 'widgets/address_form.dart';
import 'widgets/payment_method_selector.dart';
import 'widgets/order_summary.dart';
import 'widgets/checkout_button.dart';

class CheckoutScreen extends HookWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double tax;
  final double deliveryCost;
  final double discount;
  final double total;
  final String storeName;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.deliveryCost,
    required this.discount,
    required this.total,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => CheckoutCubit(
            cartRepository: GetIt.I<CartRepository>(),
            orderService: GetIt.I<OrderService>(),
            cartItems: cartItems,
            subtotal: subtotal,
            tax: tax,
            deliveryCost: deliveryCost,
            discount: discount,
            total: total,
            storeName: storeName,
          )..initialize(),
      child: const _CheckoutScreenView(),
    );
  }
}

class _CheckoutScreenView extends HookWidget {
  const _CheckoutScreenView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listenWhen:
          (previous, current) =>
              previous.orderPlaced != current.orderPlaced ||
              previous.error != current.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }

        if (state.orderPlaced) {
          // Navegar a la pantalla principal después de mostrar un diálogo de confirmación
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => AlertDialog(
                  title: const Text('¡Pedido Confirmado!'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu pedido ha sido confirmado con el número: ${state.orderConfirmationId}',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tiempo estimado de entrega: ${state.estimatedDeliveryTime}',
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Volver a la pantalla principal
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      child: const Text('Volver al inicio'),
                    ),
                  ],
                ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'Finalizar Compra',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    'Paso ${state.currentStep} de ${state.totalSteps}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Formulario de dirección
                  const AddressForm(),

                  const SizedBox(height: 16),

                  // Selector de método de pago
                  const PaymentMethodSelector(),

                  const SizedBox(height: 16),

                  // Resumen del pedido
                  const OrderSummary(),

                  const SizedBox(height: 24),

                  // Botón de confirmación
                  const CheckoutButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
