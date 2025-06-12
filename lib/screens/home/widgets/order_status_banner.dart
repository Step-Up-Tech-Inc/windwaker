import 'package:flutter/material.dart';
import '../../../core/models/order.dart';

class OrderStatusBanner extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderStatusBanner({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              // Ícono de moto
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 24,
                  child: Icon(
                    Icons.delivery_dining,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),

              // Información del pedido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Pedido en camino',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.restaurantName} • Llega en ${order.estimatedDeliveryTime} min',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _calculateProgress(),
                        minHeight: 4,
                        backgroundColor: Colors.white.withAlpha(70),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Flecha para navegar
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(Icons.chevron_right, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Calcular el progreso basado en el estado del pedido
  double _calculateProgress() {
    switch (order.status) {
      case OrderStatus.confirmed:
        return 0.25;
      case OrderStatus.inProgress:
        return 0.5;
      case OrderStatus.onTheWay:
        // Cálculo más preciso basado en el tiempo transcurrido
        if (order.estimatedArrival != null) {
          final now = DateTime.now();
          final created = order.createdAt;
          final arrival = order.estimatedArrival!;

          // Tiempo total estimado en milisegundos
          final totalTime = arrival.difference(created).inMilliseconds;
          // Tiempo transcurrido en milisegundos
          final elapsedTime = now.difference(created).inMilliseconds;

          // Calcular progreso, pero asegurar que esté entre 0.5 y 0.95
          final rawProgress = 0.5 + (0.45 * (elapsedTime / totalTime));
          return rawProgress.clamp(0.5, 0.95);
        }
        return 0.75;
      case OrderStatus.delivered:
        return 1.0;
    }
  }
}
