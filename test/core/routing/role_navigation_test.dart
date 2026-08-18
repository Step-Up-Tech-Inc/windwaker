import 'package:flutter_test/flutter_test.dart';
import 'package:windwaker/core/models/profile.dart';
import 'package:windwaker/core/routing/role_navigation.dart';

void main() {
  group('RoleNavigation.homePath', () {
    test('cada rol aterriza en su shell', () {
      expect(RoleNavigation.homePath(UserRole.customer), '/home');
      expect(RoleNavigation.homePath(UserRole.business), '/business');
      expect(RoleNavigation.homePath(UserRole.driver), '/driver');
      expect(RoleNavigation.homePath(UserRole.admin), '/home');
    });
  });

  group('RoleNavigation.canAccess', () {
    test('el cliente usa sus secciones pero no las de negocio/repartidor', () {
      expect(RoleNavigation.canAccess(UserRole.customer, '/home'), isTrue);
      expect(RoleNavigation.canAccess(UserRole.customer, '/search'), isTrue);
      expect(
        RoleNavigation.canAccess(UserRole.customer, '/order-tracking'),
        isTrue,
      );
      expect(RoleNavigation.canAccess(UserRole.customer, '/business'), isFalse);
      expect(RoleNavigation.canAccess(UserRole.customer, '/driver'), isFalse);
    });

    test('el negocio solo entra a su sección y a las compartidas', () {
      expect(RoleNavigation.canAccess(UserRole.business, '/business'), isTrue);
      expect(
        RoleNavigation.canAccess(UserRole.business, '/business/orders'),
        isTrue,
      );
      expect(RoleNavigation.canAccess(UserRole.business, '/home'), isFalse);
      expect(RoleNavigation.canAccess(UserRole.business, '/driver'), isFalse);
      expect(RoleNavigation.canAccess(UserRole.business, '/profile'), isTrue);
    });

    test('el repartidor solo entra a su sección y a las compartidas', () {
      expect(RoleNavigation.canAccess(UserRole.driver, '/driver'), isTrue);
      expect(RoleNavigation.canAccess(UserRole.driver, '/home'), isFalse);
      expect(RoleNavigation.canAccess(UserRole.driver, '/business'), isFalse);
      expect(RoleNavigation.canAccess(UserRole.driver, '/profile'), isTrue);
    });

    test('admin puede entrar a todo', () {
      for (final location in ['/home', '/business', '/driver', '/profile']) {
        expect(
          RoleNavigation.canAccess(UserRole.admin, location),
          isTrue,
          reason: location,
        );
      }
    });

    test('las rutas compartidas no se bloquean para nadie', () {
      for (final role in UserRole.values) {
        expect(
          RoleNavigation.canAccess(role, '/emergency-logout'),
          isTrue,
          reason: '$role',
        );
      }
    });
  });
}
