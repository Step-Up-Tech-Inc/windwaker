import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:windwaker/core/models/address.dart';
import 'package:windwaker/core/models/cart_item.dart';
import 'package:windwaker/core/models/order.dart';
import 'package:windwaker/screens/checkout/cubit/checkout_cubit.dart';
import 'package:windwaker/screens/checkout/cubit/checkout_state.dart';

import '../../helpers/mocks.dart';

void main() {
  const cartItem = CartItem(
    id: 'ci-1',
    productId: 'prod-1',
    productName: 'Casado Típico',
    imageUrl: '',
    price: 4500,
    unit: 'unidad',
    quantity: 2,
    storeId: 'store-1',
  );

  const savedAddress = Address(
    id: 'addr-1',
    userId: 'user-1',
    label: 'Casa',
    detail: '200m Este del Banco Nacional',
    isDefault: true,
  );

  final createdOrder = Order(
    id: 'order-1',
    customerId: 'user-1',
    storeId: 'store-1',
    subtotal: 9000,
    total: 10500,
    createdAt: DateTime(2026, 7, 1),
  );

  late MockOrderService orderService;
  late MockCartRepository cartRepository;
  late MockAddressRepository addressRepository;

  setUpAll(() {
    registerFallbackValue(DeliveryMethod.delivery);
    registerFallbackValue(OrderPaymentMethod.cash);
  });

  setUp(() {
    orderService = MockOrderService();
    cartRepository = MockCartRepository();
    addressRepository = MockAddressRepository();
  });

  CheckoutCubit buildCubit({List<CartItem> items = const [cartItem]}) =>
      CheckoutCubit(
        cartRepository: cartRepository,
        orderService: orderService,
        addressRepository: addressRepository,
        cartItems: items,
        subtotal: 9000,
        tax: 0,
        deliveryCost: 1500,
        discount: 0,
        total: 10500,
        storeName: 'Soda La Amistad',
      );

  void stubAddresses([List<Address> addresses = const [savedAddress]]) {
    when(
      () => addressRepository.getMyAddresses(),
    ).thenAnswer((_) async => addresses);
  }

  void stubCreateOrder() {
    when(
      () => orderService.createOrder(
        storeId: any(named: 'storeId'),
        deliveryMethod: any(named: 'deliveryMethod'),
        paymentMethod: any(named: 'paymentMethod'),
        items: any(named: 'items'),
        addressLabel: any(named: 'addressLabel'),
        addressDetail: any(named: 'addressDetail'),
        notes: any(named: 'notes'),
      ),
    ).thenAnswer((_) async => createdOrder);
    when(() => cartRepository.clearCart()).thenAnswer((_) async => true);
  }

  test('initialize carga y preselecciona la dirección guardada', () async {
    stubAddresses();
    final cubit = buildCubit();

    await cubit.initialize();

    expect(cubit.state.savedAddresses, [savedAddress]);
    expect(cubit.state.address, savedAddress.detail);
    expect(cubit.state.addressType, savedAddress.label);
  });

  test('crea el pedido real, limpia el carrito y guarda el id', () async {
    stubAddresses();
    stubCreateOrder();
    final cubit = buildCubit();
    await cubit.initialize();
    cubit.selectPaymentMethod(PaymentMethod.cash);

    await cubit.placeOrder();

    expect(cubit.state.orderPlaced, isTrue);
    expect(cubit.state.orderConfirmationId, 'order-1');
    expect(cubit.state.isLoading, isFalse);
    verify(
      () => orderService.createOrder(
        storeId: 'store-1',
        deliveryMethod: DeliveryMethod.delivery,
        paymentMethod: OrderPaymentMethod.cash,
        items: const [cartItem],
        addressLabel: 'Casa',
        addressDetail: savedAddress.detail,
        notes: any(named: 'notes'),
      ),
    ).called(1);
    verify(() => cartRepository.clearCart()).called(1);
  });

  test('guarda la dirección nueva cuando el usuario lo pide', () async {
    stubAddresses(const []);
    stubCreateOrder();
    when(
      () => addressRepository.saveAddress(
        label: any(named: 'label'),
        detail: any(named: 'detail'),
        isDefault: any(named: 'isDefault'),
      ),
    ).thenAnswer((_) async => savedAddress);

    final cubit = buildCubit();
    await cubit.initialize();
    cubit.updateAddress(address: 'Frente a la escuela', addressType: 'Trabajo');
    cubit.toggleSaveAddress(true);
    cubit.selectPaymentMethod(PaymentMethod.cash);

    await cubit.placeOrder();

    expect(cubit.state.orderPlaced, isTrue);
    verify(
      () => addressRepository.saveAddress(
        label: 'Trabajo',
        detail: 'Frente a la escuela',
        isDefault: true,
      ),
    ).called(1);
  });

  test('exige una dirección antes de crear el pedido', () async {
    stubAddresses(const []);
    final cubit = buildCubit();
    await cubit.initialize();
    cubit.selectPaymentMethod(PaymentMethod.cash);

    await cubit.placeOrder();

    expect(cubit.state.orderPlaced, isFalse);
    expect(cubit.state.error, 'Indica la dirección de entrega.');
    verifyZeroInteractions(orderService);
  });

  test('SINPE Móvil se envía como sinpe', () async {
    stubAddresses();
    stubCreateOrder();
    final cubit = buildCubit();
    await cubit.initialize();
    cubit.selectPaymentMethod(PaymentMethod.mobilePayment);

    await cubit.placeOrder();

    verify(
      () => orderService.createOrder(
        storeId: any(named: 'storeId'),
        deliveryMethod: any(named: 'deliveryMethod'),
        paymentMethod: OrderPaymentMethod.sinpe,
        items: any(named: 'items'),
        addressLabel: any(named: 'addressLabel'),
        addressDetail: any(named: 'addressDetail'),
        notes: any(named: 'notes'),
      ),
    ).called(1);
  });

  test('rechaza tarjeta mientras no esté disponible', () async {
    stubAddresses();
    final cubit = buildCubit();
    await cubit.initialize();
    cubit.selectPaymentMethod(PaymentMethod.card);

    await cubit.placeOrder();

    expect(cubit.state.orderPlaced, isFalse);
    expect(cubit.state.error, contains('tarjeta'));
    verifyZeroInteractions(orderService);
  });

  test('rechaza un carrito vacío', () async {
    final cubit = buildCubit(items: const []);

    await cubit.placeOrder();

    expect(cubit.state.orderPlaced, isFalse);
    expect(cubit.state.error, 'El carrito está vacío.');
    verifyZeroInteractions(orderService);
  });

  test('muestra el error si el servidor rechaza el pedido', () async {
    stubAddresses();
    when(
      () => orderService.createOrder(
        storeId: any(named: 'storeId'),
        deliveryMethod: any(named: 'deliveryMethod'),
        paymentMethod: any(named: 'paymentMethod'),
        items: any(named: 'items'),
        addressLabel: any(named: 'addressLabel'),
        addressDetail: any(named: 'addressDetail'),
        notes: any(named: 'notes'),
      ),
    ).thenThrow(Exception('La tienda está cerrada en este momento'));

    final cubit = buildCubit();
    await cubit.initialize();
    cubit.selectPaymentMethod(PaymentMethod.cash);

    await cubit.placeOrder();

    expect(cubit.state.orderPlaced, isFalse);
    expect(cubit.state.error, contains('La tienda está cerrada'));
    expect(cubit.state.isLoading, isFalse);
  });
}
