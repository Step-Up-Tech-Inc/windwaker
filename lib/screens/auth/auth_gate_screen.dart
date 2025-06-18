import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:logger/logger.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  bool showLogin = false;
  bool showRegister = false;
  bool _checkedSession = false;
  bool _isLoading = true;
  String? _errorMessage;
  final _logger = Logger();
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _checkSessionAndRedirect();
  }

  Future<void> _checkSessionAndRedirect() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _logger.i('Verificando sesión en AuthGateScreen');

      // Verificar si hay una sesión activa
      final session = Supabase.instance.client.auth.currentSession;
      _logger.i(
        'Sesión actual: ${session != null ? 'Activa' : 'No hay sesión'}',
      );

      if (session != null) {
        // Intentar refrescar la sesión
        final sessionValid = await _authService.verifyAndRefreshSession();
        _logger.i('Sesión válida después de verificación: $sessionValid');

        if (sessionValid) {
          _logger.i('Sesión válida, redirigiendo a la pantalla principal');
          if (!mounted) return;
          context.go('/location-permission');
          return;
        } else {
          _logger.w('Sesión no válida, se requiere nuevo inicio de sesión');
        }
      } else {
        _logger.i('No hay sesión activa, mostrando pantalla de autenticación');
      }

      setState(() {
        _checkedSession = true;
        _isLoading = false;
      });
    } catch (e) {
      _logger.e('Error al verificar la sesión: $e');
      setState(() {
        _checkedSession = true;
        _isLoading = false;
        _errorMessage = 'Error al verificar la sesión: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Verificando sesión...'),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 32),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.shopping_basket,
                        size: 120,
                        color: Color(0xFF2979FF),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Bienvenido',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Inicia sesión para continuar',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/phone-login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2979FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continuar con teléfono',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
