import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      buildWhen:
          (previous, current) =>
              previous.subtotal != current.subtotal ||
              previous.tax != current.tax ||
              previous.deliveryCost != current.deliveryCost ||
              previous.discount != current.discount ||
              previous.total != current.total,
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
                Text(
                  'Resumen del Pedido',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Subtotal
                _buildSummaryRow(
                  context: context,
                  label: 'Subtotal',
                  value: '₡${state.subtotal.toStringAsFixed(0)}',
                  isBold: false,
                ),

                const SizedBox(height: 8),

                // Envío
                _buildSummaryRow(
                  context: context,
                  label: 'Envío',
                  value: '₡${state.deliveryCost.toStringAsFixed(0)}',
                  isBold: false,
                ),

                const SizedBox(height: 8),

                // Impuestos
                _buildSummaryRow(
                  context: context,
                  label: 'Impuestos',
                  value: '₡${state.tax.toStringAsFixed(0)}',
                  isBold: false,
                ),

                if (state.discount > 0) ...[
                  const SizedBox(height: 8),

                  // Descuento
                  _buildSummaryRow(
                    context: context,
                    label: 'Descuento',
                    value: '-₡${state.discount.toStringAsFixed(0)}',
                    valueColor: Colors.green,
                    isBold: false,
                  ),
                ],

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),

                // Total
                _buildSummaryRow(
                  context: context,
                  label: 'Total',
                  value: '₡${state.total.toStringAsFixed(0)}',
                  isBold: true,
                  labelSize: 18,
                  valueSize: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow({
    required BuildContext context,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
    double labelSize = 16,
    double valueSize = 16,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: labelSize,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
            fontSize: valueSize,
          ),
        ),
      ],
    );
  }
}
