import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/services/auth_service.dart';

/// Pantalla de emergencia para cerrar sesión cuando hay problemas con la autenticación
class EmergencyLogoutScreen extends StatefulWidget {
  const EmergencyLogoutScreen({super.key});

  @override
  State<EmergencyLogoutScreen> createState() => _EmergencyLogoutScreenState();
}

class _EmergencyLogoutScreenState extends State<EmergencyLogoutScreen> {
  final _logger = Logger();
  bool _isLoading = false;
  String? _statusMessage;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _checkSessionStatus();
  }

  Future<void> _checkSessionStatus() async {
    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;

    setState(() {
      _statusMessage = '''
Estado de sesión:
- Sesión activa: ${session != null ? 'Sí' : 'No'}
- Usuario autenticado: ${user != null ? 'Sí (${user.id})' : 'No'}
- Email: ${user?.email ?? 'No disponible'}
- Teléfono: ${user?.phone ?? 'No disponible'}
''';
    });
  }

  Future<void> _forceSignOut() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Cerrando sesión...';
    });

    try {
      // Cerrar sesión en Supabase
      await Supabase.instance.client.auth.signOut();
      _logger.i('Sesión de Supabase cerrada');

      // Limpiar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _logger.i('SharedPreferences limpiadas');

      // Usar el servicio de autenticación para asegurar que se limpie todo
      await _authService.signOut();

      setState(() {
        _statusMessage = 'Sesión cerrada con éxito. Redirigiendo...';
      });

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      // Redirigir a la pantalla de autenticación
      context.go('/auth');
    } catch (e) {
      _logger.e('Error al cerrar sesión: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error al cerrar sesión: $e';
      });
    }
  }

  Future<void> _resetSupabase() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Reiniciando Supabase...';
    });

    try {
      // Cerrar sesión
      await Supabase.instance.client.auth.signOut();

      // Limpiar almacenamiento local
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reiniciar la aplicación
      setState(() {
        _statusMessage =
            'Supabase reiniciado. Por favor, reinicia la aplicación.';
        _isLoading = false;
      });
    } catch (e) {
      _logger.e('Error al reiniciar Supabase: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error al reiniciar Supabase: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cierre de Sesión de Emergencia'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child:
              _isLoading
                  ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Procesando...'),
                    ],
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Herramienta de Emergencia',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Esta pantalla te permite cerrar sesión cuando hay problemas con la autenticación.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      if (_statusMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            _statusMessage!,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _forceSignOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'CERRAR SESIÓN DE EMERGENCIA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _resetSupabase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'REINICIAR SUPABASE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
