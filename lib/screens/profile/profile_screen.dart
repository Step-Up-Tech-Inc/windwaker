import 'package:flutter/material.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/core/repositories/user_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthService _authService;
  late final UserRepository _userRepository;
  final _logger = Logger();
  String? _email;
  String? _phone;
  bool _isLoading = false;
  String? _diagnosticResult;
  bool _hasSessionError = false;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _userRepository = getIt<UserRepository>();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _hasSessionError = false;
    });

    try {
      // Verificar y refrescar la sesión si es necesario
      final sessionValid = await _authService.verifyAndRefreshSession();

      if (!sessionValid) {
        _logger.w('La sesión no es válida, mostrando opciones de emergencia');
        if (!mounted) return;

        setState(() {
          _hasSessionError = true;
          _isLoading = false;
        });

        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La sesión ha expirado. Usa el botón de emergencia para cerrar sesión.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      // Cargar datos del usuario
      _email = _authService.getUserEmail();
      _phone = _authService.getUserPhone();

      _logger.i('Datos de usuario cargados: email=$_email, phone=$_phone');
    } catch (e) {
      _logger.e('Error al cargar datos del usuario: $e');
      // Mostrar mensaje de error
      if (mounted) {
        setState(() {
          _hasSessionError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    await _authService.signOut();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;
    context.go('/auth');
  }

  void _goToEmergencyLogout() {
    context.go('/emergency-logout');
  }

  Future<void> _runDiagnostic() async {
    setState(() {
      _isLoading = true;
      _diagnosticResult = null;
    });

    try {
      _logger.i('Ejecutando diagnóstico de tabla profiles...');

      // Verificar si hay un usuario autenticado
      final currentUser = _userRepository.getCurrentUser();
      if (currentUser == null) {
        _logger.w('No hay usuario autenticado para el diagnóstico');
        setState(() {
          _diagnosticResult =
              'ERROR: No hay usuario autenticado.\n'
              'Debes iniciar sesión antes de ejecutar el diagnóstico.\n'
              'Intenta cerrar sesión y volver a iniciarla.';
        });
        return;
      }

      _logger.i('Usuario autenticado: ${currentUser.id}');

      final result = await _userRepository.verifyProfilesTable();

      setState(() {
        _diagnosticResult = 'Resultado del diagnóstico: ${result.toString()}';
      });

      _logger.i('Diagnóstico completado: $result');

      // Intentar actualizar el perfil del usuario actual
      try {
        await _userRepository.createOrUpdateUserProfile(
          userId: currentUser.id,
          email: _email,
          phone: _phone,
        );
        _logger.i('Perfil actualizado durante diagnóstico');

        // Actualizar el diagnóstico con el resultado
        final updatedProfile = await _userRepository.getUserProfile(
          currentUser.id,
        );
        setState(() {
          _diagnosticResult =
              '$_diagnosticResult\n\nPerfil actualizado: $updatedProfile';
        });
      } catch (e) {
        _logger.e('Error al actualizar perfil durante diagnóstico: $e');
        setState(() {
          _diagnosticResult =
              '$_diagnosticResult\n\nError al actualizar perfil: $e';
        });
      }
    } catch (e) {
      _logger.e('Error al ejecutar diagnóstico: $e');
      setState(() {
        _diagnosticResult = 'Error al ejecutar diagnóstico: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshSession() async {
    setState(() {
      _isLoading = true;
      _diagnosticResult = 'Intentando refrescar la sesión...';
    });

    try {
      // Obtener la sesión actual
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        _logger.w('No hay sesión activa para refrescar');
        setState(() {
          _diagnosticResult =
              'No hay sesión activa para refrescar.\n'
              'Debes iniciar sesión nuevamente.';
          _hasSessionError = true;
        });
        return;
      }

      // Refrescar la sesión
      final response = await Supabase.instance.client.auth.refreshSession();
      if (response.session != null) {
        _logger.i('Sesión refrescada con éxito');

        // Recargar datos del usuario
        await _loadUserData();

        setState(() {
          _diagnosticResult =
              'Sesión refrescada con éxito.\n'
              'Usuario: ${response.user?.id}\n'
              'Email: ${response.user?.email}\n'
              'Teléfono: ${response.user?.phone}';
          _hasSessionError = false;
        });
      } else {
        _logger.w('No se pudo refrescar la sesión');
        setState(() {
          _diagnosticResult =
              'No se pudo refrescar la sesión.\n'
              'Debes iniciar sesión nuevamente.';
          _hasSessionError = true;
        });
      }
    } catch (e) {
      _logger.e('Error al refrescar la sesión: $e');
      setState(() {
        _diagnosticResult = 'Error al refrescar la sesión: $e';
        _hasSessionError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasSessionError
              ? _buildSessionErrorView()
              : _buildProfileView(),
    );
  }

  Widget _buildSessionErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Error de Sesión',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Se ha detectado un problema con tu sesión. Esto puede deberse a que la sesión ha expirado o ha sido invalidada.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('INTENTAR REFRESCAR SESIÓN'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _goToEmergencyLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('IR A CIERRE DE SESIÓN DE EMERGENCIA'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          if (_email != null)
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Correo electrónico'),
              subtitle: Text(_email!),
            ),
          if (_phone != null)
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Teléfono'),
              subtitle: Text(_phone!),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _signOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
          const SizedBox(height: 32),
          const Text(
            'Herramientas de diagnóstico',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _runDiagnostic,
                  child: const Text('Ejecutar diagnóstico'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _refreshSession,
                  child: const Text('Refrescar sesión'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _goToEmergencyLogout,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Cierre de sesión de emergencia'),
          ),
          if (_diagnosticResult != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Resultado del diagnóstico:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _diagnosticResult!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
