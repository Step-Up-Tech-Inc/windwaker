import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/config/app_config.dart';
import 'package:windwaker/core/utils/phone_number.dart';

/// Inicio de sesión con correo o número de teléfono + contraseña.
/// La contraseña se crea durante el registro (completar perfil).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _logger = Logger();

  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _logger.i('🚀 === LOGIN SCREEN INICIADA ===');
    _logger.i('🚀 Modo actual: ${AppConfig.currentMode}');
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Convierte lo que escribió el usuario en el identificador que espera
  /// Supabase: email en minúsculas o teléfono en formato E.164.
  String? _resolveIdentifier(String input) {
    if (input.contains('@')) {
      return input.toLowerCase();
    }
    return PhoneNumber.normalize(input);
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String? identifier =
          _resolveIdentifier(_identifierController.text.trim());
      if (identifier == null) {
        setState(() {
          _errorMessage = 'Ingresa un correo o un número de teléfono válido.';
        });
        return;
      }

      _logger.i('🔑 Iniciando sesión con: $identifier');

      final result = await _authService.signInWithPassword(
        identifier: identifier,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (!result.success) {
        _logger.e('❌ Login fallido: ${result.error}');
        setState(() => _errorMessage = result.error);
        return;
      }

      _logger.i('✅ Login exitoso - UserID: ${result.userId}');
      // El redirect del router decide si falta completar el perfil.
      context.go('/home');
    } catch (e) {
      _logger.e('❌ Error inesperado durante inicio de sesión: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Ocurrió un error inesperado. Inténtalo de nuevo.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo o teléfono';
    }
    final input = value.trim();
    if (input.contains('@')) {
      if (!RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
      ).hasMatch(input)) {
        return 'Formato de correo electrónico inválido';
      }
      return null;
    }
    return PhoneNumber.validate(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/auth'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 10),
                  const Icon(Icons.login, size: 64, color: Color(0xFF2979FF)),
                  const SizedBox(height: 24),
                  const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingresa tu correo o teléfono y tu contraseña',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo o teléfono',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                      hintText: 'ejemplo@correo.com o 8888 8888',
                    ),
                    validator: _validateIdentifier,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La contraseña es obligatoria';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SelectableText.rich(
                        TextSpan(
                          text: _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2979FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
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
                                'Iniciar sesión',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text(
                      '¿No tienes cuenta? Crea tu perfil',
                      style: TextStyle(color: Color(0xFF2979FF)),
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
