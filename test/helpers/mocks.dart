import 'package:mocktail/mocktail.dart';
import 'package:windwaker/core/repositories/address_repository.dart';
import 'package:windwaker/core/repositories/cart_repository.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/core/services/order_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockOrderService extends Mock implements OrderService {}

class MockCartRepository extends Mock implements CartRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}
