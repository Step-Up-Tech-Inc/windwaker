import 'package:flutter/material.dart';

class OrderSummaryCard extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double deliveryCost;
  final double discount;
  final double total;

  const OrderSummaryCard({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.deliveryCost,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Formatear valores monetarios en formato ₡XXX.XXX
    final formattedSubtotal = '₡${subtotal.toInt()}';
    final formattedTax = '₡${tax.toInt()}';
    final formattedDeliveryCost = '₡${deliveryCost.toInt()}';
    final formattedDiscount = '-₡${discount.toInt()}';
    final formattedTotal = '₡${total.toInt()}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del pedido',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Subtotal
            _buildSummaryRow(
              context: context,
              label: 'Subtotal',
              value: formattedSubtotal,
              isTotal: false,
            ),

            const SizedBox(height: 8),

            // Impuesto (13%)
            _buildSummaryRow(
              context: context,
              label: 'Impuesto (13%)',
              value: formattedTax,
              isTotal: false,
            ),

            const SizedBox(height: 8),

            // Costo de delivery
            _buildSummaryRow(
              context: context,
              label: 'Costo de delivery',
              value: formattedDeliveryCost,
              isTotal: false,
            ),

            // Descuento (si hay)
            if (discount > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                context: context,
                label: 'Descuento',
                value: formattedDiscount,
                valueColor: Colors.green,
                isTotal: false,
              ),
            ],

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1),
            ),

            // Total
            _buildSummaryRow(
              context: context,
              label: 'Total',
              value: formattedTotal,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required BuildContext context,
    required String label,
    required String value,
    Color? valueColor,
    required bool isTotal,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              isTotal
                  ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                  : theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
        ),
        Text(
          value,
          style:
              isTotal
                  ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  )
                  : theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
        ),
      ],
    );
  }
}
