import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      buildWhen:
          (previous, current) =>
              previous.paymentMethod != current.paymentMethod,
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
                  'Método de Pago',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Opción de tarjeta
                _buildPaymentOption(
                  context: context,
                  icon: Icons.credit_card,
                  title: 'Tarjeta',
                  isSelected: state.paymentMethod == PaymentMethod.card,
                  onTap:
                      () => context.read<CheckoutCubit>().selectPaymentMethod(
                        PaymentMethod.card,
                      ),
                ),

                const SizedBox(height: 12),

                // Opción de SINPE Móvil
                _buildPaymentOption(
                  context: context,
                  icon: Icons.phone_android,
                  title: 'SINPE Móvil',
                  isSelected:
                      state.paymentMethod == PaymentMethod.mobilePayment,
                  onTap:
                      () => context.read<CheckoutCubit>().selectPaymentMethod(
                        PaymentMethod.mobilePayment,
                      ),
                ),

                const SizedBox(height: 12),

                // Opción de efectivo
                _buildPaymentOption(
                  context: context,
                  icon: Icons.payments_outlined,
                  title: 'Efectivo',
                  isSelected: state.paymentMethod == PaymentMethod.cash,
                  onTap:
                      () => context.read<CheckoutCubit>().selectPaymentMethod(
                        PaymentMethod.cash,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color:
              isSelected ? theme.primaryColor.withAlpha(26) : Colors.grey[100],
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.primaryColor : Colors.grey[700],
              size: 28,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.primaryColor : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.primaryColor, size: 24),
          ],
        ),
      ),
    );
  }
}
