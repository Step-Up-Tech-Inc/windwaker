import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class AuthSelectionScreen extends StatefulWidget {
  const AuthSelectionScreen({super.key});

  @override
  State<AuthSelectionScreen> createState() => _AuthSelectionScreenState();
}

class _AuthSelectionScreenState extends State<AuthSelectionScreen> {
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    _logger.i('🚀 === AUTH SELECTION SCREEN INICIADA ===');
  }

  void _navigateToLogin() {
    _logger.i('🔑 Usuario eligió: INICIAR SESIÓN');
    context.go('/login');
  }

  void _navigateToCreateProfile() {
    _logger.i('🆕 Usuario eligió: CREAR PERFIL');
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Botón de volver
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => context.go('/app-intro'),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF2979FF),
                    size: 28,
                  ),
                ),
              ),
            ),
            // Contenido principal
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 16),
                        const Icon(
                          Icons.account_circle,
                          size: 80,
                          color: Color(0xFF2979FF),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          '¡Bienvenido a Tilarán en Línea!',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '¿Qué te gustaría hacer?',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Botón para iniciar sesión
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _navigateToLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2979FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.login,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Botón para crear perfil
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _navigateToCreateProfile,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF2979FF),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.person_add,
                                  color: Color(0xFF2979FF),
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Crear perfil',
                                  style: TextStyle(
                                    color: Color(0xFF2979FF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
