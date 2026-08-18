import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:windwaker/core/repositories/business_repository.dart';

part 'business_menu_state.dart';
part 'business_menu_cubit.freezed.dart';

/// Menú del negocio: CRUD de productos con foto en Supabase Storage.
class BusinessMenuCubit extends Cubit<BusinessMenuState> {
  final BusinessRepository _repository;
  final String storeId;

  BusinessMenuCubit({
    required BusinessRepository repository,
    required this.storeId,
  }) : _repository = repository,
       super(const BusinessMenuState.loading());

  Future<void> load() async {
    emit(const BusinessMenuState.loading());
    try {
      final products = await _repository.getMyProducts(storeId);
      if (!isClosed) emit(BusinessMenuState.loaded(products));
    } catch (e) {
      if (!isClosed) {
        emit(BusinessMenuState.error('Error cargando el menú: $e'));
      }
    }
  }

  Future<void> saveProduct({
    String? productId,
    required String name,
    required String description,
    required double price,
    required String category,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      String? imageUrl;
      if (imageBytes != null) {
        imageUrl = await _repository.uploadProductImage(
          storeId: storeId,
          fileName: imageName ?? 'producto.jpg',
          bytes: imageBytes,
        );
      }

      if (productId == null) {
        await _repository.createProduct(
          storeId: storeId,
          name: name,
          description: description,
          price: price,
          category: category,
          imageUrl: imageUrl ?? '',
        );
      } else {
        await _repository.updateProduct(
          productId: productId,
          name: name,
          description: description,
          price: price,
          category: category,
          imageUrl: imageUrl,
        );
      }
      await load();
    } catch (e) {
      if (!isClosed) {
        final current = state;
        emit(BusinessMenuState.error('No se pudo guardar el producto: $e'));
        if (current is _Loaded) emit(current);
      }
    }
  }

  Future<void> toggleAvailable(BusinessProduct product) async {
    try {
      await _repository.setProductAvailable(product.id, !product.isAvailable);
      await load();
    } catch (e) {
      if (!isClosed) {
        emit(BusinessMenuState.error('No se pudo actualizar: $e'));
      }
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _repository.deleteProduct(productId);
      await load();
    } catch (e) {
      if (!isClosed) {
        emit(BusinessMenuState.error('No se pudo eliminar: $e'));
      }
    }
  }
}
