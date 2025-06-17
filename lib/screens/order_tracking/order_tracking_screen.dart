import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:windwaker/screens/order_tracking/cubit/order_tracking_cubit.dart';
import 'package:windwaker/core/models/order_tracking_status.dart';

/// Pantalla principal de seguimiento de pedido.
/// Navega aquí desde el banner de detalles de la orden.
class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderTrackingCubit()..loadOrderTracking(orderId),
      child: BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Seguimiento de Pedido',
                style: TextStyle(color: Colors.black87),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => context.go('/home'),
              ),
            ),
            body: state.map(
              initial: (_) => const Center(child: CircularProgressIndicator()),
              loading: (_) => const Center(child: CircularProgressIndicator()),
              loaded:
                  (loaded) => SingleChildScrollView(
                    child: Column(
                      children: [
                        _OrderTimeline(timeline: loaded.timeline),
                        _OrderDeliveryDetails(
                          orderId: loaded.orderId,
                          address: loaded.address,
                          estimatedTime: loaded.estimatedTime,
                          deliveryPerson: loaded.deliveryPerson,
                        ),
                        _OrderSummary(
                          products: loaded.products,
                          subtotal: loaded.subtotal,
                        ),
                      ],
                    ),
                  ),
              error:
                  (error) => Center(
                    child: Text(
                      error.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              noOrder:
                  (_) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.assignment_late_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontró el pedido',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'El pedido que buscas no existe o ha sido eliminado',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Volver al inicio'),
                        ),
                      ],
                    ),
                  ),
              orderCancelled:
                  (cancelled) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cancel_outlined,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Pedido cancelado',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pedido #${cancelled.orderId}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Motivo: ${cancelled.reason}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Volver al inicio'),
                        ),
                      ],
                    ),
                  ),
              orderDelivered:
                  (delivered) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Pedido entregado',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pedido #${delivered.orderId}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Entregado el ${_formatDateTime(delivered.deliveryTime)}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Volver al inicio'),
                        ),
                      ],
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year a las $hour:$minute';
  }
}

/// Widget privado para el timeline de estados del pedido.
class _OrderTimeline extends StatelessWidget {
  final List<OrderTrackingStatus> timeline;
  const _OrderTimeline({required this.timeline});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < timeline.length; i++)
            _TimelineStep(
              status: timeline[i],
              isFirst: i == 0,
              isLast: i == timeline.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final OrderTrackingStatus status;
  final bool isFirst;
  final bool isLast;
  const _TimelineStep({
    required this.status,
    required this.isFirst,
    required this.isLast,
  });

  Color _getColor(BuildContext context) {
    switch (status.status) {
      case OrderStatusType.processed:
        return Colors.blue;
      case OrderStatusType.preparing:
        return Colors.blue;
      case OrderStatusType.onTheWay:
        return Colors.grey;
      case OrderStatusType.delivered:
        return Colors.green;
      case OrderStatusType.cancelled:
        return Colors.red;
    }
  }

  IconData _getIcon() {
    switch (status.status) {
      case OrderStatusType.processed:
        return Icons.check_circle;
      case OrderStatusType.preparing:
        return Icons.restaurant_menu;
      case OrderStatusType.onTheWay:
        return Icons.delivery_dining;
      case OrderStatusType.delivered:
        return Icons.home;
      case OrderStatusType.cancelled:
        return Icons.cancel;
    }
  }

  String _getTitle() {
    switch (status.status) {
      case OrderStatusType.processed:
        return 'Pedido Procesado';
      case OrderStatusType.preparing:
        return 'En Preparación';
      case OrderStatusType.onTheWay:
        return 'En Camino';
      case OrderStatusType.delivered:
        return 'Entregado';
      case OrderStatusType.cancelled:
        return 'Cancelado';
    }
  }

  String? _getTime() {
    if (status.time != null) {
      final hour = status.time!.hour.toString().padLeft(2, '0');
      final minute = status.time!.minute.toString().padLeft(2, '0');
      return '$hour:$minute AM';
    }
    return status.estimated != null ? 'Estimado: ${status.estimated}' : null;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(width: 2, height: 16, color: Colors.grey.shade300),
            Icon(_getIcon(), color: color, size: 28),
            if (!isLast)
              Container(width: 2, height: 32, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getTitle(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
              if (_getTime() != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _getTime()!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget privado para los detalles de entrega.
class _OrderDeliveryDetails extends StatelessWidget {
  final String orderId;
  final String address;
  final String estimatedTime;
  final String deliveryPerson;
  const _OrderDeliveryDetails({
    required this.orderId,
    required this.address,
    required this.estimatedTime,
    required this.deliveryPerson,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;
    final greyColor = Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Detalles de Entrega', style: textTheme.titleMedium),
                  Text(
                    'Pedido #$orderId',
                    style: textTheme.bodySmall?.copyWith(color: primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: greyColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dirección de Entrega',
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(address, style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, color: greyColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Tiempo Estimado',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(estimatedTime, style: textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, color: greyColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Repartidor',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(deliveryPerson, style: textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget privado para el resumen del pedido.
class _OrderSummary extends StatelessWidget {
  final List<OrderProductSummary> products;
  final int subtotal;
  const _OrderSummary({required this.products, required this.subtotal});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen del Pedido', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, i) {
                final product = products[i];
                return Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                      ),
                      child:
                          product.imageUrl != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                ),
                              )
                              : const Icon(Icons.image, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: textTheme.bodyMedium),
                          Text(
                            'x${product.quantity}',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text('₡${product.price}', style: textTheme.bodyMedium),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('₡$subtotal', style: textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.phone, color: primaryColor, size: 20),
                  label: const Text('Llamar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.message,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text('Mensaje'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
