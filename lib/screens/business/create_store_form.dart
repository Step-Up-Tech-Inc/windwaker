import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:windwaker/screens/business/cubit/business_orders_cubit.dart';

/// Onboarding del negocio: formulario para crear su tienda.
class CreateStoreForm extends StatefulWidget {
  const CreateStoreForm({super.key});

  @override
  State<CreateStoreForm> createState() => _CreateStoreFormState();
}

class _CreateStoreFormState extends State<CreateStoreForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deliveryFeeController = TextEditingController(text: '1000');
  final _deliveryTimeController = TextEditingController(text: '30');

  static const List<String> _categories = [
    'Restaurante',
    'Supermercado',
    'Farmacia',
    'Tienda',
    'Panadería',
    'Otro',
  ];
  String _category = _categories.first;

  Uint8List? _logoBytes;
  String? _logoName;

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _logoBytes = bytes;
      _logoName = picked.name;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _deliveryFeeController.dispose();
    _deliveryTimeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<BusinessOrdersCubit>().createStore(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      deliveryFee: double.parse(_deliveryFeeController.text.trim()),
      deliveryTimeMinutes: int.parse(_deliveryTimeController.text.trim()),
      logoBytes: _logoBytes,
      logoName: _logoName,
    );
  }

  String? _requiredValidator(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Campo obligatorio' : null;

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obligatorio';
    return double.tryParse(value.trim()) == null ? 'Número inválido' : null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.storefront, size: 64, color: Color(0xFF2979FF)),
            const SizedBox(height: 16),
            const Text(
              'Registra tu negocio para empezar a recibir pedidos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: 'Nombre del negocio',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in _categories)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _deliveryFeeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tarifa de envío (₡)',
                      border: OutlineInputBorder(),
                    ),
                    validator: _numberValidator,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _deliveryTimeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tiempo (min)',
                      border: OutlineInputBorder(),
                    ),
                    validator: _numberValidator,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickLogo,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                _logoName ?? 'Agregar logo o foto del negocio',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Crear tienda'),
            ),
          ],
        ),
      ),
    );
  }
}
