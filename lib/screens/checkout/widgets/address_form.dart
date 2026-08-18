import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/address.dart';
import '../../profile/address_editor_screen.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';

class AddressForm extends StatelessWidget {
  const AddressForm({super.key});

  /// Selector de direcciones guardadas + opción de escribir una nueva.
  void _showAddressPicker(BuildContext context, CheckoutState state) {
    final cubit = context.read<CheckoutCubit>();

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Dirección de entrega',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              for (final Address address in state.savedAddresses)
                ListTile(
                  leading: Icon(
                    address.isDefault ? Icons.home : Icons.place_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(address.label),
                  subtitle: Text(
                    address.detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    cubit.selectAddress(address);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.add_location_alt_outlined),
                title: const Text('Agregar nueva dirección'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final saved = await Navigator.of(context).push<Address>(
                    MaterialPageRoute(
                      builder: (_) => const AddressEditorScreen(),
                    ),
                  );
                  if (saved != null) cubit.addSavedAddress(saved);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      buildWhen:
          (previous, current) =>
              previous.address != current.address ||
              previous.addressType != current.addressType ||
              previous.savedAddresses != current.savedAddresses ||
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
                      onPressed: () => _showAddressPicker(context, state),
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
                  maxLength: 500,
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
