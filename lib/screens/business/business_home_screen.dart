import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/models/order.dart';
import 'package:windwaker/core/repositories/business_repository.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/screens/business/business_menu_tab.dart';
import 'package:windwaker/screens/business/business_summary.dart';
import 'package:windwaker/screens/business/create_store_form.dart';
import 'package:windwaker/screens/business/cubit/business_orders_cubit.dart';
import 'package:windwaker/screens/business/orders_grouping.dart';

/// Panel del negocio: pedidos entrantes en tiempo real, en curso e historial.
class BusinessHomeScreen extends StatelessWidget {
  const BusinessHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BusinessOrdersCubit>()..load(),
      child: const _BusinessHomeView(),
    );
  }
}

class _BusinessHomeView extends StatelessWidget {
  const _BusinessHomeView();

  Future<void> _signOut(BuildContext context) async {
    await getIt<AuthService>().signOut();
    if (context.mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessOrdersCubit, BusinessOrdersState>(
      builder: (context, state) {
        return state.when(
          loading:
              () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
          error:
              (message) => Scaffold(
                appBar: AppBar(title: const Text('Mi negocio')),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(message, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () =>
                                  context.read<BusinessOrdersCubit>().load(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          noStore:
              () => Scaffold(
                appBar: AppBar(
                  title: const Text('Crea tu tienda'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: 'Cerrar sesión',
                      onPressed: () => _signOut(context),
                    ),
                  ],
                ),
                body: const CreateStoreForm(),
              ),
          loaded:
              (store, orders) => _BusinessShell(
                store: store,
                orders: orders,
                onSignOut: () => _signOut(context),
              ),
        );
      },
    );
  }
}

class _BusinessShell extends StatefulWidget {
  final BusinessStore store;
  final List<Order> orders;
  final VoidCallback onSignOut;

  const _BusinessShell({
    required this.store,
    required this.orders,
    required this.onSignOut,
  });

  @override
  State<_BusinessShell> createState() => _BusinessShellState();
}

class _BusinessShellState extends State<_BusinessShell> {
  int _index = 0;

  /// Número SINPE Móvil donde el negocio recibe los pagos.
  Future<void> _showSinpeDialog(BuildContext context) async {
    final cubit = context.read<BusinessOrdersCubit>();
    final controller = TextEditingController(
      text: widget.store.sinpeNumber ?? '',
    );

    await showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('SINPE Móvil'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              maxLength: 20,
              decoration: const InputDecoration(
                labelText: 'Número donde recibes los pagos',
                hintText: '8888 8888',
                border: OutlineInputBorder(),
                counterText: '',
                helperText:
                    'Los clientes verán este número al pagar por SINPE. '
                    'Déjalo vacío para no aceptar SINPE.',
                helperMaxLines: 3,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  cubit.setSinpeNumber(controller.text);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  Widget _buildSection() {
    final grouped = groupOrdersForBusiness(widget.orders);
    return switch (_index) {
      0 => DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: const Color(0xFF2979FF),
              tabs: [
                Tab(text: 'Nuevos (${grouped.nuevos.length})'),
                Tab(text: 'En curso (${grouped.enCurso.length})'),
                const Tab(text: 'Historial'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OrderList(
                    orders: grouped.nuevos,
                    emptyText: 'Sin pedidos nuevos',
                  ),
                  _OrderList(
                    orders: grouped.enCurso,
                    emptyText: 'Nada en curso',
                  ),
                  _OrderList(
                    orders: grouped.historial,
                    emptyText: 'Sin historial',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      1 => BusinessMenuTab(storeId: widget.store.id),
      _ => _SummaryTab(orders: widget.orders),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.store.name),
        actions: [
          Row(
            children: [
              Text(
                widget.store.isOpen ? 'Abierto' : 'Cerrado',
                style: const TextStyle(fontSize: 13),
              ),
              Switch(
                value: widget.store.isOpen,
                onChanged:
                    (_) => context.read<BusinessOrdersCubit>().toggleOpen(),
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logo') {
                final cubit = context.read<BusinessOrdersCubit>();
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1024,
                  imageQuality: 80,
                );
                if (picked == null) return;
                final bytes = await picked.readAsBytes();
                await cubit.changeStoreLogo(
                  bytes: bytes,
                  fileName: picked.name,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logo actualizado.')),
                  );
                }
              } else if (value == 'sinpe') {
                await _showSinpeDialog(context);
              } else if (value == 'logout') {
                widget.onSignOut();
              }
            },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(
                    value: 'logo',
                    child: Text('Cambiar logo de la tienda'),
                  ),
                  PopupMenuItem(
                    value: 'sinpe',
                    child: Text('Configurar SINPE Móvil'),
                  ),
                  PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (!widget.store.isApproved)
            Container(
              width: double.infinity,
              color: widget.store.isRejected
                  ? const Color(0xFFFFEBEE)
                  : const Color(0xFFFFF8E1),
              padding: const EdgeInsets.all(12),
              child: Text(
                widget.store.isRejected
                    ? 'Tu tienda fue rechazada. Contacta a soporte para más '
                        'información.'
                    : 'Tu tienda está en revisión. Puedes preparar tu menú, '
                        'pero aún no aparecerás ante los clientes.',
                style: TextStyle(
                  color: widget.store.isRejected
                      ? Colors.red.shade700
                      : Colors.orange.shade900,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(child: _buildSection()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menú',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Resumen',
          ),
        ],
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  final List<Order> orders;

  const _SummaryTab({required this.orders});

  @override
  Widget build(BuildContext context) {
    final summary = summarizeBusinessOrders(orders);
    final currency = NumberFormat.currency(locale: 'es_CR', symbol: '₡');

    Widget statCard(String label, String value) => Expanded(
      child: Card(
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
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            statCard('Pedidos hoy', '${summary.ordersToday}'),
            const SizedBox(width: 12),
            statCard('Ingresos hoy', currency.format(summary.revenueToday)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            statCard(
              'Ingresos últimos 7 días',
              currency.format(summary.revenueWeek),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Más vendidos (entregados)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (summary.topProducts.isEmpty)
          const Text(
            'Aún no hay ventas entregadas.',
            style: TextStyle(color: Colors.grey),
          )
        else
          for (final p in summary.topProducts)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.star_outline, color: Color(0xFF2979FF)),
              title: Text(p.name),
              trailing: Text('${p.quantity} uds.'),
            ),
      ],
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Order> orders;
  final String emptyText;

  const _OrderList({required this.orders, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Text(emptyText, style: const TextStyle(color: Colors.grey)),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<BusinessOrdersCubit>().load(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _BusinessOrderCard(order: orders[index]),
      ),
    );
  }
}

class _BusinessOrderCard extends StatelessWidget {
  final Order order;

  const _BusinessOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BusinessOrdersCubit>();
    final currency = NumberFormat.currency(locale: 'es_CR', symbol: '₡');
    final time = DateFormat('hh:mm a').format(order.createdAt.toLocal());

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
                Text(
                  'Pedido de las $time',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  order.status.label,
                  style: const TextStyle(
                    color: Color(0xFF2979FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('${item.quantity} × ${item.productName}'),
              ),
            if (order.notes != null && order.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Nota: ${order.notes}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Total: ${currency.format(order.total)} · '
              '${order.paymentMethod == OrderPaymentMethod.cash ? 'Efectivo' : 'SINPE Móvil'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (order.paymentMethod == OrderPaymentMethod.sinpe) ...[
              const SizedBox(height: 8),
              _SinpeReviewSection(order: order),
            ],
            const SizedBox(height: 12),
            _actionsFor(order, cubit),
          ],
        ),
      ),
    );
  }

  Widget _actionsFor(Order order, BusinessOrdersCubit cubit) {
    switch (order.status) {
      case OrderStatus.pending:
        // Un pedido SINPE solo se acepta con el pago verificado
        // (el servidor también lo bloquea).
        final awaitingPayment =
            order.paymentMethod == OrderPaymentMethod.sinpe &&
            order.paymentStatus != PaymentStatus.verified;
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed:
                  () => cubit.advanceOrder(order.id, OrderStatus.rejected),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Rechazar'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed:
                  awaitingPayment
                      ? null
                      : () =>
                          cubit.advanceOrder(order.id, OrderStatus.accepted),
              child: Text(awaitingPayment ? 'Esperando pago' : 'Aceptar'),
            ),
          ],
        );
      case OrderStatus.accepted:
        return Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed:
                () => cubit.advanceOrder(order.id, OrderStatus.preparing),
            child: const Text('Iniciar preparación'),
          ),
        );
      case OrderStatus.preparing:
        return Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () => cubit.advanceOrder(order.id, OrderStatus.ready),
            child: const Text('Pedido listo'),
          ),
        );
      case OrderStatus.ready:
        if (order.deliveryMethod == DeliveryMethod.pickup) {
          return Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed:
                  () => cubit.advanceOrder(order.id, OrderStatus.delivered),
              child: const Text('Entregado al cliente'),
            ),
          );
        }
        return const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Esperando repartidor…',
            style: TextStyle(color: Colors.grey),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Estado del pago SINPE de un pedido, con revisión del comprobante:
/// el negocio verifica contra su cuenta y aprueba o rechaza.
class _SinpeReviewSection extends StatelessWidget {
  final Order order;

  const _SinpeReviewSection({required this.order});

  Future<void> _viewProof(BuildContext context) async {
    final cubit = context.read<BusinessOrdersCubit>();
    final path = order.paymentProofPath;
    if (path == null) return;
    try {
      final url = await cubit.paymentProofUrl(path);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder:
            (_) => Dialog(
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder:
                      (context, child, progress) =>
                          progress == null
                              ? child
                              : const Padding(
                                padding: EdgeInsets.all(48),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                ),
              ),
            ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo cargar el comprobante.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BusinessOrdersCubit>();

    final (label, color) = switch (order.paymentStatus) {
      PaymentStatus.pending => (
        'Esperando comprobante del cliente',
        Colors.orange,
      ),
      PaymentStatus.submitted => (
        'Comprobante recibido — revísalo',
        Colors.blue,
      ),
      PaymentStatus.verified => ('Pago verificado ✓', Colors.green),
      PaymentStatus.rejected => ('Comprobante rechazado', Colors.red),
      PaymentStatus.notRequired => ('', Colors.grey),
    };
    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (order.paymentReference != null &&
              order.paymentReference!.isNotEmpty)
            Text(
              'Referencia: ${order.paymentReference}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          if (order.paymentStatus == PaymentStatus.submitted) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _viewProof(context),
                  icon: const Icon(Icons.receipt_long, size: 18),
                  label: const Text('Ver comprobante'),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => cubit.reviewPayment(order.id, false),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Rechazar pago'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => cubit.reviewPayment(order.id, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                  ),
                  child: const Text('Confirmar pago'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
