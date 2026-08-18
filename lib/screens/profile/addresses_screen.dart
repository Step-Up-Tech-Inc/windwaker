import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/models/address.dart';
import 'package:windwaker/core/repositories/address_repository.dart';
import 'package:windwaker/screens/profile/address_editor_screen.dart';

/// Direcciones guardadas del usuario: listar, agregar, eliminar y
/// marcar como predeterminada. Se usan como sugerencias en el checkout.
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  late final AddressRepository _repository;
  late Future<List<Address>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _repository = getIt<AddressRepository>();
    _reload();
  }

  void _reload() {
    setState(() {
      _addressesFuture = _repository.getMyAddresses();
    });
  }

  Future<void> _showAddDialog() async {
    final saved = await Navigator.of(context).push<Address>(
      MaterialPageRoute(builder: (_) => const AddressEditorScreen()),
    );
    if (saved != null) _reload();
  }

  Future<void> _delete(Address address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Eliminar dirección'),
            content: Text('¿Eliminar "${address.label}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    await _repository.deleteAddress(address.id);
    _reload();
  }

  Future<void> _setDefault(Address address) async {
    await _repository.setDefault(address.id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Direcciones Guardadas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          tooltip: 'Volver',
          onPressed: () => context.go('/profile'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Agregar'),
      ),
      body: FutureBuilder<List<Address>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error cargando direcciones: ${snapshot.error}'),
            );
          }

          final addresses = snapshot.data ?? const [];
          if (addresses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aún no tienes direcciones guardadas',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color:
                        address.isDefault
                            ? const Color(0xFF2979FF)
                            : Colors.grey.shade300,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Icon(
                    address.isDefault ? Icons.home : Icons.place_outlined,
                    color: const Color(0xFF2979FF),
                  ),
                  title: Row(
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2979FF).withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Predeterminada',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF2979FF),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.detail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((address.reference?.isNotEmpty ?? false) ||
                          (address.district?.isNotEmpty ?? false))
                        Text(
                          [
                            if (address.reference?.isNotEmpty ?? false)
                              'Ref: ${address.reference}',
                            if (address.district?.isNotEmpty ?? false)
                              address.district!,
                          ].join(' · '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      if (address.latitude != null)
                        const Text(
                          '📍 Con pin en el mapa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2979FF),
                          ),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'default') _setDefault(address);
                      if (value == 'delete') _delete(address);
                    },
                    itemBuilder:
                        (_) => [
                          if (!address.isDefault)
                            const PopupMenuItem(
                              value: 'default',
                              child: Text('Marcar como predeterminada'),
                            ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar'),
                          ),
                        ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
