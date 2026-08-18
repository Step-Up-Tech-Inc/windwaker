import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:windwaker/core/models/order.dart';
import 'package:windwaker/core/repositories/business_repository.dart';
import 'package:windwaker/core/repositories/order_repository.dart';
import 'package:windwaker/screens/business/cubit/business_orders_cubit.dart';
import 'package:windwaker/screens/business/orders_grouping.dart';

class MockBusinessRepository extends Mock implements BusinessRepository {}

class MockOrderRepository extends Mock implements OrderRepository {}

Order orderWith(String id, OrderStatus status) => Order(
      id: id,
      customerId: 'c',
      storeId: 'store-1',
      status: status,
      subtotal: 1000,
      total: 1500,
      createdAt: DateTime(2026, 7, 1),
    );

const store = BusinessStore(
  id: 'store-1',
  name: 'Soda La Amistad',
  description: 'Comida típica',
  category: 'Restaurante',
  isOpen: true,
  deliveryFee: 1000,
  deliveryTimeMinutes: 30,
);

void main() {
  group('BusinessStore aprobación', () {
    test('las tiendas nuevas nacen pendientes', () {
      final parsed = BusinessStore.fromJson(const {
        'id': 's',
        'name': 'Nueva',
      });
      expect(parsed.status, 'pending');
      expect(parsed.isApproved, isFalse);
    });

    test('una tienda aprobada se reconoce como tal', () {
      final parsed = BusinessStore.fromJson(const {
        'id': 's',
        'name': 'Vieja',
        'status': 'approved',
      });
      expect(parsed.isApproved, isTrue);
      expect(parsed.isRejected, isFalse);
    });
  });

  group('groupOrdersForBusiness', () {
    test('separa nuevos, en curso e historial', () {
      final grouped = groupOrdersForBusiness([
        orderWith('a', OrderStatus.pending),
        orderWith('b', OrderStatus.preparing),
        orderWith('c', OrderStatus.pickedUp),
        orderWith('d', OrderStatus.delivered),
        orderWith('e', OrderStatus.rejected),
      ]);

      expect(grouped.nuevos.map((o) => o.id), ['a']);
      expect(grouped.enCurso.map((o) => o.id), ['b', 'c']);
      expect(grouped.historial.map((o) => o.id), ['d', 'e']);
    });
  });

  group('BusinessOrdersCubit', () {
    late MockBusinessRepository businessRepository;
    late MockOrderRepository orderRepository;

    setUpAll(() {
      registerFallbackValue(OrderStatus.accepted);
    });

    setUp(() {
      businessRepository = MockBusinessRepository();
      orderRepository = MockOrderRepository();
      when(
        () => businessRepository.watchStoreOrderChanges(any()),
      ).thenAnswer((_) => const Stream.empty());
    });

    BusinessOrdersCubit buildCubit() => BusinessOrdersCubit(
          businessRepository: businessRepository,
          orderRepository: orderRepository,
        );

    test('sin tienda emite noStore (onboarding)', () async {
      when(
        () => businessRepository.getMyStore(),
      ).thenAnswer((_) async => null);

      final cubit = buildCubit();
      await cubit.load();

      expect(cubit.state, const BusinessOrdersState.noStore());
      await cubit.close();
    });

    test('con tienda carga los pedidos y se suscribe a realtime', () async {
      when(
        () => businessRepository.getMyStore(),
      ).thenAnswer((_) async => store);
      when(
        () => businessRepository.getStoreOrders(any()),
      ).thenAnswer((_) async => [orderWith('a', OrderStatus.pending)]);

      final cubit = buildCubit();
      await cubit.load();

      cubit.state.maybeWhen(
        loaded: (loadedStore, orders) {
          expect(loadedStore.id, 'store-1');
          expect(orders, hasLength(1));
        },
        orElse: () => fail('Estado inesperado: ${cubit.state}'),
      );
      verify(() => businessRepository.watchStoreOrderChanges('store-1'))
          .called(1);
      await cubit.close();
    });

    test('aceptar un pedido llama al RPC y recarga la lista', () async {
      when(
        () => businessRepository.getMyStore(),
      ).thenAnswer((_) async => store);
      when(
        () => businessRepository.getStoreOrders(any()),
      ).thenAnswer((_) async => [orderWith('a', OrderStatus.pending)]);
      when(
        () => orderRepository.advanceStatus(any(), any()),
      ).thenAnswer((_) async {});

      final cubit = buildCubit();
      await cubit.load();
      await cubit.advanceOrder('a', OrderStatus.accepted);

      verify(
        () => orderRepository.advanceStatus('a', OrderStatus.accepted),
      ).called(1);
      // load + recarga tras aceptar
      verify(() => businessRepository.getStoreOrders('store-1')).called(2);
      await cubit.close();
    });

    test('abrir/cerrar tienda actualiza el estado local', () async {
      when(
        () => businessRepository.getMyStore(),
      ).thenAnswer((_) async => store);
      when(
        () => businessRepository.getStoreOrders(any()),
      ).thenAnswer((_) async => const []);
      when(
        () => businessRepository.setStoreOpen(any(), any()),
      ).thenAnswer((_) async {});

      final cubit = buildCubit();
      await cubit.load();
      await cubit.toggleOpen();

      cubit.state.maybeWhen(
        loaded: (loadedStore, _) => expect(loadedStore.isOpen, isFalse),
        orElse: () => fail('Estado inesperado: ${cubit.state}'),
      );
      verify(() => businessRepository.setStoreOpen('store-1', false)).called(1);
      await cubit.close();
    });

    test('si el RPC rechaza la transición muestra error y restaura', () async {
      when(
        () => businessRepository.getMyStore(),
      ).thenAnswer((_) async => store);
      when(
        () => businessRepository.getStoreOrders(any()),
      ).thenAnswer((_) async => const []);
      when(
        () => orderRepository.advanceStatus(any(), any()),
      ).thenThrow(Exception('Transición no permitida'));

      final cubit = buildCubit();
      await cubit.load();

      final emitted = <BusinessOrdersState>[];
      final sub = cubit.stream.listen(emitted.add);
      await cubit.advanceOrder('a', OrderStatus.accepted);
      await Future<void>.delayed(Duration.zero);

      expect(
        emitted.any(
          (s) => s.maybeWhen(error: (_) => true, orElse: () => false),
        ),
        isTrue,
      );
      // El último estado vuelve a ser loaded (la lista se restaura)
      cubit.state.maybeWhen(
        loaded: (_, __) {},
        orElse: () => fail('Estado inesperado: ${cubit.state}'),
      );
      await sub.cancel();
      await cubit.close();
    });
  });
}
