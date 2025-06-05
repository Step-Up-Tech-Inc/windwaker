import 'package:flutter/material.dart';
import '../cubit/cart_screen_state.dart';

class DeliveryMethodSelector extends StatelessWidget {
  final DeliveryMethod selectedMethod;
  final Function(DeliveryMethod) onMethodSelected;

  const DeliveryMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Método de entrega',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMethodOption(
                    context,
                    DeliveryMethod.delivery,
                    'Delivery',
                    Icons.delivery_dining,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMethodOption(
                    context,
                    DeliveryMethod.pickup,
                    'Recoger',
                    Icons.store,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption(
    BuildContext context,
    DeliveryMethod method,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isSelected = selectedMethod == method;

    return InkWell(
      onTap: () => onMethodSelected(method),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[700],
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
