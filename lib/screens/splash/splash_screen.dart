import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/core/services/app_intro_service.dart';

/// Pantalla de carga inicial de la aplicación.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _checkAuthAndNavigate);
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;

    final authService = getIt<AuthService>();
    final appIntroService = getIt<AppIntroService>();

    // Verificar si el usuario ya vio la introducción
    final hasSeenIntro = await appIntroService.hasSeenIntro();
    if (!hasSeenIntro) {
      if (!mounted) return;
      context.go('/app-intro');
      return;
    }

    // Verificar si el usuario está autenticado
    final isAuthenticated = authService.isAuthenticated();
    final isProfileComplete = authService.isProfileComplete();

    if (!mounted) return;

    if (!isAuthenticated) {
      context.go('/auth');
    } else if (!isProfileComplete) {
      context.go('/complete-profile');
    } else {
      context.go('/location-permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _SplashColors.background,
      body: SafeArea(child: Center(child: _SplashContent())),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withAlpha((0.08 * 255).toInt()),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(32),
          child: const Icon(Icons.store, size: 64, color: _SplashColors.icon),
        ),
        const SizedBox(height: 32),
        const Text(
          'Tilarán en Línea',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tu ciudad en tu bolsillo',
          style: TextStyle(
            color: _SplashColors.subtitle,
            fontWeight: FontWeight.w400,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 40),
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3,
        ),
      ],
    );
  }
}

class _SplashColors {
  static const Color background = Color(0xFF2979FF);
  static const Color icon = Color(0xFF2979FF);
  static const Color subtitle = Color(0xFFBBDEFB);
}
