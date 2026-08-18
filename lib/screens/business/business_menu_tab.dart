import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/repositories/business_repository.dart';
import 'package:windwaker/screens/business/cubit/business_menu_cubit.dart';

/// Pestaña "Menú" del panel del negocio: CRUD de productos.
class BusinessMenuTab extends StatelessWidget {
  final String storeId;

  const BusinessMenuTab({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => BusinessMenuCubit(
            repository: getIt<BusinessRepository>(),
            storeId: storeId,
          )..load(),
      child: const _MenuView(),
    );
  }
}

class _MenuView extends StatelessWidget {
  const _MenuView();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_CR', symbol: '₡');

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Producto'),
      ),
      body: BlocBuilder<BusinessMenuCubit, BusinessMenuState>(
        builder: (context, state) {
          return state.when(
            loading:
                () => const Center(child: CircularProgressIndicator()),
            error:
                (message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed:
                            () => context.read<BusinessMenuCubit>().load(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
            loaded: (products) {
              if (products.isEmpty) {
                return const Center(
                  child: Text(
                    'Agrega tu primer producto con el botón +',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                itemCount: products.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child:
                            product.imageUrl.isEmpty
                                ? Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.fastfood,
                                      color: Colors.grey),
                                )
                                : CachedNetworkImage(
                                  imageUrl: product.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                      '${currency.format(product.price)} · ${product.category}',
                    ),
                    trailing: Switch(
                      value: product.isAvailable,
                      onChanged:
                          (_) => context
                              .read<BusinessMenuCubit>()
                              .toggleAvailable(product),
                    ),
                    onTap: () => _showProductForm(context, product: product),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showProductForm(BuildContext context, {BusinessProduct? product}) {
    final cubit = context.read<BusinessMenuCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => BlocProvider.value(
            value: cubit,
            child: _ProductForm(product: product),
          ),
    );
  }
}

class _ProductForm extends StatefulWidget {
  final BusinessProduct? product;

  const _ProductForm({this.product});

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.name);
  late final _description =
      TextEditingController(text: widget.product?.description);
  late final _price =
      TextEditingController(text: widget.product?.price.toStringAsFixed(0));
  late final _category =
      TextEditingController(text: widget.product?.category ?? 'General');

  Uint8List? _imageBytes;
  String? _imageName;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageName = picked.name;
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    await context.read<BusinessMenuCubit>().saveProduct(
      productId: widget.product?.id,
      name: _name.text.trim(),
      description: _description.text.trim(),
      price: double.parse(_price.text.trim()),
      category: _category.text.trim(),
      imageBytes: _imageBytes,
      imageName: _imageName,
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Editar producto' : 'Nuevo producto',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                validator:
                    (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo obligatorio'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Precio (₡)',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (v) => double.tryParse(v?.trim() ?? '') == null
                              ? 'Precio inválido'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _category,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  _imageName ??
                      (isEditing && widget.product!.imageUrl.isNotEmpty
                          ? 'Cambiar foto'
                          : 'Agregar foto'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                child:
                    _saving
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(isEditing ? 'Guardar cambios' : 'Crear producto'),
              ),
              if (isEditing)
                TextButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          await context
                              .read<BusinessMenuCubit>()
                              .deleteProduct(widget.product!.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Eliminar producto'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
