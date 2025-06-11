import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';

class CheckoutButton extends StatelessWidget {
  const CheckoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      buildWhen:
          (previous, current) =>
              previous.isLoading != current.isLoading ||
              previous.total != current.total,
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed:
                state.isLoading
                    ? null
                    : () => context.read<CheckoutCubit>().placeOrder(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: theme.primaryColor.withAlpha(153),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child:
                state.isLoading
                    ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Procesando...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                    : const Text(
                      'Confirmar Pedido',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        );
      },
    );
  }
}
