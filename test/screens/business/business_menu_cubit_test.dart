import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:windwaker/core/repositories/business_repository.dart';
import 'package:windwaker/screens/business/cubit/business_menu_cubit.dart';

class MockBusinessRepository extends Mock implements BusinessRepository {}

const product = BusinessProduct(
  id: 'prod-1',
  name: 'Casado Típico',
  description: 'Con pollo',
  price: 4500,
  category: 'Platos',
  imageUrl: '',
  isAvailable: true,
);

void main() {
  late MockBusinessRepository repository;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    repository = MockBusinessRepository();
    when(
      () => repository.getMyProducts(any()),
    ).thenAnswer((_) async => [product]);
  });

  BusinessMenuCubit buildCubit() =>
      BusinessMenuCubit(repository: repository, storeId: 'store-1');

  test('load trae los productos de la tienda', () async {
    final cubit = buildCubit();
    await cubit.load();

    expect(
      cubit.state,
      const BusinessMenuState.loaded([product]),
    );
  });

  test('crear producto sube la foto y usa su URL pública', () async {
    when(
      () => repository.uploadProductImage(
        storeId: any(named: 'storeId'),
        fileName: any(named: 'fileName'),
        bytes: any(named: 'bytes'),
      ),
    ).thenAnswer((_) async => 'https://cdn/img.jpg');
    when(
      () => repository.createProduct(
        storeId: any(named: 'storeId'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        price: any(named: 'price'),
        category: any(named: 'category'),
        imageUrl: any(named: 'imageUrl'),
      ),
    ).thenAnswer((_) async {});

    final cubit = buildCubit();
    await cubit.saveProduct(
      name: 'Gallo Pinto',
      description: '',
      price: 2500,
      category: 'Desayunos',
      imageBytes: Uint8List.fromList([1, 2, 3]),
      imageName: 'pinto.jpg',
    );

    verify(
      () => repository.createProduct(
        storeId: 'store-1',
        name: 'Gallo Pinto',
        description: '',
        price: 2500,
        category: 'Desayunos',
        imageUrl: 'https://cdn/img.jpg',
      ),
    ).called(1);
  });

  test('editar sin foto nueva no toca la imagen (imageUrl null)', () async {
    when(
      () => repository.updateProduct(
        productId: any(named: 'productId'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        price: any(named: 'price'),
        category: any(named: 'category'),
        imageUrl: any(named: 'imageUrl'),
      ),
    ).thenAnswer((_) async {});

    final cubit = buildCubit();
    await cubit.saveProduct(
      productId: 'prod-1',
      name: 'Casado',
      description: '',
      price: 4800,
      category: 'Platos',
    );

    verify(
      () => repository.updateProduct(
        productId: 'prod-1',
        name: 'Casado',
        description: '',
        price: 4800,
        category: 'Platos',
        imageUrl: null,
      ),
    ).called(1);
    verifyNever(
      () => repository.uploadProductImage(
        storeId: any(named: 'storeId'),
        fileName: any(named: 'fileName'),
        bytes: any(named: 'bytes'),
      ),
    );
  });

  test('marcar agotado invierte la disponibilidad', () async {
    when(
      () => repository.setProductAvailable(any(), any()),
    ).thenAnswer((_) async {});

    final cubit = buildCubit();
    await cubit.load();
    await cubit.toggleAvailable(product);

    verify(() => repository.setProductAvailable('prod-1', false)).called(1);
  });
}
