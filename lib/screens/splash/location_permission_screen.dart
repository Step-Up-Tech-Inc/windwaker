import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
//import '../../core/config/di_config.dart';
//import '../../core/services/app_intro_service.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  String? _errorMessage;
  bool _isRequesting = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    setState(() {
      _isChecking = true;
    });

    final PermissionStatus status = await Permission.location.status;

    if (status.isGranted || status.isLimited) {
      // Si ya tenemos el permiso (completo o limitado), navegamos a la siguiente pantalla
      if (mounted) {
        _navigateToNextScreen();
      }
      return;
    }

    // Si está permanentemente denegado, mostramos el mensaje adecuado
    if (status.isPermanentlyDenied) {
      setState(() {
        _isChecking = false;
        _errorMessage =
            'Permiso de ubicación bloqueado. Ve a la configuración para habilitarlo.';
      });
      return;
    }

    // Si está restringido, mostramos un mensaje específico
    if (status.isRestricted) {
      setState(() {
        _isChecking = false;
        _errorMessage =
            'El acceso a la ubicación está restringido por controles parentales o políticas de la organización.';
      });
      return;
    }

    // Para cualquier otro estado (denegado o no determinado), mostramos la pantalla de solicitud
    setState(() {
      _isChecking = false;
    });
  }

  Future<void> requestLocationPermission() async {
    setState(() {
      _isRequesting = true;
      _errorMessage = null;
    });

    // Primero intentar con el permiso preciso
    PermissionStatus status = await Permission.locationWhenInUse.request();

    setState(() {
      _isRequesting = false;
    });

    if (status.isGranted || status.isLimited) {
      // Navegar a la siguiente pantalla si el permiso es concedido o limitado
      if (mounted) {
        _navigateToNextScreen();
      }
      return;
    }

    if (status.isDenied) {
      setState(() {
        _errorMessage =
            'Permiso de ubicación denegado. Por favor, acepta para continuar.';
      });
      return;
    }

    if (status.isPermanentlyDenied) {
      setState(() {
        _errorMessage =
            'Permiso de ubicación bloqueado. Ve a la configuración para habilitarlo.';
      });
      await openAppSettings();
    }
  }

  Future<void> _navigateToNextScreen() async {
    // Temporalmente omitimos la verificación de si el usuario ya ha visto la intro
    // y siempre navegamos a la pantalla de introducción
    if (mounted) {
      context.go('/app-intro');
    }

    // Código original comentado:
    /*
    // Verificar si el usuario ya ha visto la pantalla de introducción
    final hasSeenIntro = await getIt<AppIntroService>().hasSeenIntro();
    
    if (mounted) {
      if (!hasSeenIntro) {
        // Si no ha visto la intro, navegar a la pantalla de introducción
        context.go('/app-intro');
      } else {
        // Si ya vio la intro, navegar directamente a la pantalla principal
        context.go('/home');
      }
    }
    */
  }

  void _skipPermission() {
    // Navegar a la siguiente pantalla sin permisos
    _navigateToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: <Widget>[
                const _PageIndicator(),
                const SizedBox(height: 40),
                const _LocationIcon(),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Habilitar ubicación',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Necesitamos acceder a tu ubicación para mostrarte las tiendas más cercanas y calcular los tiempos de entrega.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF424242),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: SelectableText.rich(
                      TextSpan(
                        text: _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 15),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isRequesting ? null : requestLocationPermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2979FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child:
                              _isRequesting
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Text(
                                    'Permitir acceso a ubicación',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isRequesting ? null : _skipPermission,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5F5F5),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Ahora no',
                            style: TextStyle(
                              color: Color(0xFF424242),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _skipPermission,
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Saltar este paso',
                      style: TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildDot(isActive: false),
        const SizedBox(width: 8),
        _buildDot(isActive: true),
        const SizedBox(width: 8),
        _buildDot(isActive: false),
      ],
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2979FF) : const Color(0xFFE3F2FD),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _LocationIcon extends StatelessWidget {
  const _LocationIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFE3F2FD),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(Icons.location_on, color: Color(0xFF2979FF), size: 48),
      ),
    );
  }
}
