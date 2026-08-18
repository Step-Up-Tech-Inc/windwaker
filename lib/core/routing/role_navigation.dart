import '../models/profile.dart';

/// Reglas de navegación por rol: cada tipo de usuario vive en su propio
/// shell (cliente → /home, negocio → /business, repartidor → /driver).
/// Funciones puras para que el redirect del router sea testeable.
class RoleNavigation {
  RoleNavigation._();

  static const String customerRoot = '/home';
  static const String businessRoot = '/business';
  static const String driverRoot = '/driver';

  /// Secciones exclusivas del cliente.
  static const List<String> _customerSections = [
    '/home',
    '/search',
    '/order-tracking',
    '/order-history',
    '/addresses',
  ];

  /// Pantalla inicial según el rol.
  static String homePath(UserRole role) {
    switch (role) {
      case UserRole.business:
        return businessRoot;
      case UserRole.driver:
        return driverRoot;
      case UserRole.customer:
      case UserRole.admin:
        return customerRoot;
    }
  }

  /// ¿Puede este rol visitar la ubicación? Las rutas no listadas
  /// (perfil, logout de emergencia, etc.) son compartidas.
  static bool canAccess(UserRole role, String location) {
    if (role == UserRole.admin) return true;
    if (_inSection(location, businessRoot)) return role == UserRole.business;
    if (_inSection(location, driverRoot)) return role == UserRole.driver;
    if (_customerSections.any((s) => _inSection(location, s))) {
      return role == UserRole.customer;
    }
    return true;
  }

  static bool _inSection(String location, String root) =>
      location == root || location.startsWith('$root/');
}
