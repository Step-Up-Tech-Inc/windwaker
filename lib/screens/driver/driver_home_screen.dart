import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/models/order.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/screens/driver/cubit/driver_cubit.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DriverCubit>()..load(),
      child: const _DriverView(),
    );
  }
}

class _DriverView extends StatefulWidget {
  const _DriverView();

  @override
  State<_DriverView> createState() => _DriverViewState();
}

class _DriverViewState extends State<_DriverView> {
  int _index = 0;

  Future<void> _signOut() async {
    await getIt<AuthService>().signOut();
    if (mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis entregas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _signOut,
          ),
        ],
      ),
      body: BlocBuilder<DriverCubit, DriverState>(
        builder: (context, state) {
          return state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.read<DriverCubit>().load(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
            loaded: (available, active, history) {
              return switch (_index) {
                0 => _AvailableList(available: available, hasActive: active != null),
                1 => _ActiveDelivery(order: active),
                _ => _History(history: history),
              };
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Disponibles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Mi entrega',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }
}

class _AvailableList extends StatelessWidget {
  final List<Order> available;
  final bool hasActive;

  const _AvailableList({required this.available, required this.hasActive});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_CR', symbol: '₡');

    if (available.isEmpty) {
      return const Center(
        child: Text(
          'No hay pedidos listos para recoger',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: available.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = available[index];
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
                Text(
                  order.storeName ?? 'Tienda',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Entregar en: ${order.addressDetail ?? '-'}'),
                const SizedBox(height: 4),
                Text(
                  'Tarifa de envío: ${currency.format(order.deliveryFee)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed:
                        hasActive
                            ? null
                            : () async {
                                final claimed = await context
                                    .read<DriverCubit>()
                                    .claim(order.id);
                                if (!claimed && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Otro repartidor tomó este pedido.',
                                      ),
                                    ),
                                  );
                                }
                              },
                    child: Text(
                      hasActive ? 'Termina tu entrega actual' : 'Tomar pedido',
                    ),
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

class _ActiveDelivery extends StatelessWidget {
  final Order? order;

  const _ActiveDelivery({required this.order});

  Future<void> _openMaps(Order order) async {
    final query =
        (order.latitude != null && order.longitude != null)
            ? '${order.latitude},${order.longitude}'
            : Uri.encodeComponent(
                '${order.addressDetail ?? ''} Tilarán Costa Rica',
              );
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final current = order;
    if (current == null) {
      return const Center(
        child: Text(
          'No tienes una entrega activa',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final cubit = context.read<DriverCubit>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          current.storeName ?? 'Tienda',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('Estado: ${current.status.label}'),
        const SizedBox(height: 12),
        Text('Entregar en:\n${current.addressDetail ?? '-'}'),
        const SizedBox(height: 8),
        for (final item in current.items)
          Text('${item.quantity} × ${item.productName}'),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _openMaps(current),
          icon: const Icon(Icons.map_outlined),
          label: const Text('Abrir en Google Maps'),
        ),
        const SizedBox(height: 8),
        if (current.status == OrderStatus.ready)
          FilledButton(
            onPressed: () => cubit.markPickedUp(current.id),
            child: const Text('Ya recogí el pedido'),
          )
        else if (current.status == OrderStatus.pickedUp)
          FilledButton(
            onPressed: () => cubit.markDelivered(current.id),
            child: const Text('Pedido entregado'),
          ),
      ],
    );
  }
}

class _History extends StatelessWidget {
  final List<Order> history;

  const _History({required this.history});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_CR', symbol: '₡');
    final earnings = history.fold<double>(0, (sum, o) => sum + o.deliveryFee);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Ganancias (tarifas de envío)'),
                const SizedBox(height: 8),
                Text(
                  currency.format(earnings),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (history.isEmpty)
          const Center(
            child: Text(
              'Aún no has completado entregas',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          for (final order in history)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(order.storeName ?? 'Pedido'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm a')
                    .format((order.updatedAt ?? order.createdAt).toLocal()),
              ),
              trailing: Text(currency.format(order.deliveryFee)),
            ),
      ],
    );
  }
}
