import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Botón flotante de emergencia para cerrar sesión
///
/// Este botón se puede agregar a cualquier pantalla para proporcionar
/// acceso rápido a la pantalla de cierre de sesión de emergencia
class EmergencyLogoutButton extends StatelessWidget {
  /// Posición del botón en la pantalla
  final FloatingActionButtonLocation? location;

  /// Color del botón
  final Color? backgroundColor;

  const EmergencyLogoutButton({super.key, this.location, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: () => context.go('/emergency-logout'),
      backgroundColor: backgroundColor ?? Colors.red,
      tooltip: 'Cierre de sesión de emergencia',
      heroTag: 'emergencyLogout',
      child: const Icon(Icons.power_settings_new, color: Colors.white),
    );
  }
}
