import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:windwaker/core/models/order.dart';
import 'package:windwaker/core/repositories/driver_repository.dart';
import 'package:windwaker/core/repositories/order_repository.dart';
import 'package:windwaker/screens/driver/cubit/driver_cubit.dart';

class MockDriverRepository extends Mock implements DriverRepository {}

class MockOrderRepository extends Mock implements OrderRepository {}

Order orderWith(String id, OrderStatus status) => Order(
      id: id,
      customerId: 'c',
      storeId: 's',
      status: status,
      subtotal: 1000,
      total: 1500,
      deliveryFee: 500,
      createdAt: DateTime(2026, 7, 2),
    );

void main() {
  late MockDriverRepository driverRepository;
  late MockOrderRepository orderRepository;

  setUpAll(() {
    registerFallbackValue(OrderStatus.pickedUp);
  });

  setUp(() {
    driverRepository = MockDriverRepository();
    orderRepository = MockOrderRepository();
    when(
      () => driverRepository.watchOrderChanges(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => driverRepository.getAvailableOrders(),
    ).thenAnswer((_) async => [orderWith('a', OrderStatus.ready)]);
    when(
      () => driverRepository.getActiveDelivery(),
    ).thenAnswer((_) async => null);
    when(
      () => driverRepository.getDeliveryHistory(),
    ).thenAnswer((_) async => const []);
  });

  DriverCubit buildCubit() => DriverCubit(
        driverRepository: driverRepository,
        orderRepository: orderRepository,
      );

  test('load carga disponibles, activa e historial', () async {
    final cubit = buildCubit();
    await cubit.load();

    cubit.state.maybeWhen(
      loaded: (available, active, history) {
        expect(available, hasLength(1));
        expect(active, isNull);
        expect(history, isEmpty);
      },
      orElse: () => fail('Estado inesperado: ${cubit.state}'),
    );
    await cubit.close();
  });

  test('claim exitoso refresca y devuelve true', () async {
    when(
      () => driverRepository.claimOrder('a'),
    ).thenAnswer((_) async => true);

    final cubit = buildCubit();
    await cubit.load();
    final claimed = await cubit.claim('a');

    expect(claimed, isTrue);
    verify(() => driverRepository.claimOrder('a')).called(1);
    await cubit.close();
  });

  test('claim perdido (otro repartidor ganó) devuelve false', () async {
    when(
      () => driverRepository.claimOrder('a'),
    ).thenAnswer((_) async => false);

    final cubit = buildCubit();
    await cubit.load();

    expect(await cubit.claim('a'), isFalse);
    await cubit.close();
  });

  test('marcar recogido y entregado pasa por el RPC', () async {
    when(
      () => orderRepository.advanceStatus(any(), any()),
    ).thenAnswer((_) async {});

    final cubit = buildCubit();
    await cubit.load();
    await cubit.markPickedUp('a');
    await cubit.markDelivered('a');

    verify(
      () => orderRepository.advanceStatus('a', OrderStatus.pickedUp),
    ).called(1);
    verify(
      () => orderRepository.advanceStatus('a', OrderStatus.delivered),
    ).called(1);
    await cubit.close();
  });
}
