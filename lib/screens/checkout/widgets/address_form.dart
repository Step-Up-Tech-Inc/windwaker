import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';

class AddressForm extends StatelessWidget {
  const AddressForm({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      buildWhen:
          (previous, current) =>
              previous.address != current.address ||
              previous.addressType != current.addressType ||
              previous.deliveryInstructions != current.deliveryInstructions,
      builder: (context, state) {
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dirección de Entrega',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Acción para cambiar la dirección
                        // Podría navegar a una pantalla de selección de dirección
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Función para cambiar dirección'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        'Cambiar',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dirección actual
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.addressType,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.address,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Instrucciones de entrega
                Text(
                  'Instrucciones de Entrega',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) {
                    context.read<CheckoutCubit>().updateDeliveryInstructions(
                      value,
                    );
                  },
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ej: Casa color verde, portón negro...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
