import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/models/order.dart';
import 'package:windwaker/core/repositories/cart_repository.dart';
import 'package:windwaker/core/services/order_service.dart';
import 'package:windwaker/core/utils/reorder.dart';
import 'package:windwaker/screens/search/widgets/bottom_navigation.dart';

/// Historial de pedidos del cliente, con seguimiento de los activos
/// y "volver a pedir" para los finalizados.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late final OrderService _orderService;
  late final CartRepository _cartRepository;
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _orderService = getIt<OrderService>();
    _cartRepository = getIt<CartRepository>();
    _ordersFuture = _orderService.getOrderHistory();
  }

  Future<void> _refresh() async {
    setState(() {
      _ordersFuture = _orderService.getOrderHistory();
    });
    await _ordersFuture;
  }

  Future<void> _reorder(Order order) async {
    final items = cartItemsFromOrder(order);
    if (items.isEmpty) {
      _showSnack('Este pedido ya no se puede repetir.');
      return;
    }
    for (final item in items) {
      await _cartRepository.addToCart(item);
    }
    _showSnack('Productos agregados al carrito.');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return const Color(0xFF2979FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis pedidos'),
        backgroundColor: const Color(0xFF2979FF),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
          onPressed: () => context.go('/home'),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Error cargando pedidos: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final orders = snapshot.data ?? const [];
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aún no has hecho pedidos',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _OrderCard(
                order: orders[index],
                statusColor: _statusColor(orders[index].status),
                onTrack: () => context.go(
                  '/order-tracking?order_id=${orders[index].id}',
                ),
                onReorder: () => _reorder(orders[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final Color statusColor;
  final VoidCallback onTrack;
  final VoidCallback onReorder;

  const _OrderCard({
    required this.order,
    required this.statusColor,
    required this.onTrack,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
    final currency = NumberFormat.currency(locale: 'es_CR', symbol: '₡');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.storeName ?? 'Pedido',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${dateFormat.format(order.createdAt.toLocal())} · '
              '${order.items.length} producto${order.items.length == 1 ? '' : 's'} · '
              '${currency.format(order.total)}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.isActive)
                  FilledButton.icon(
                    onPressed: onTrack,
                    icon: const Icon(Icons.location_on_outlined, size: 18),
                    label: const Text('Seguir pedido'),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: onReorder,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Volver a pedir'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
