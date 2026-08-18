import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/services/auth_service.dart';

/// Paso 3 (final) del registro: el usuario ya verificó su teléfono y está
/// autenticado. Aquí define su correo y contraseña, con los que después
/// podrá iniciar sesión (correo o teléfono + contraseña).
class CompleteProfileScreen extends StatefulWidget {
  final String? phone;

  const CompleteProfileScreen({super.key, this.phone});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _success = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  late final AuthService _authService;
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _logger.i('🔑 === COMPLETE PROFILE SCREEN INICIADA ===');
    _logger.i('🔑 phone: ${widget.phone}');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _success = false;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String email = _emailController.text.trim().toLowerCase();
      final String password = _passwordController.text;

      _logger.i('📧 Completando registro con email: $email');

      final result = await _authService.completeRegistration(
        email: email,
        password: password,
        phone: widget.phone,
      );

      if (!mounted) return;

      if (!result.success) {
        _logger.e('❌ Error completando registro: ${result.error}');
        setState(() => _errorMessage = result.error);

        // Sin sesión no se puede completar el registro: volver al inicio
        if (!_authService.isAuthenticated()) {
          context.go('/auth');
        }
        return;
      }

      _logger.i('🎉 Registro completado. Navegando a permisos de ubicación');
      setState(() => _success = true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      context.go('/location-permission');
    } catch (e) {
      _logger.e('❌ Error inesperado completando registro: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Ocurrió un error. Inténtalo de nuevo.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Rellena el campo de correo con la cuenta de Google del usuario.
  /// Solo lee el email: NO inicia sesión en Supabase (la cuenta se crea
  /// con teléfono verificado + contraseña, como el resto del flujo).
  Future<void> _fillEmailFromGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      // Permitir elegir cuenta aunque haya una recordada
      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) return; // el usuario canceló

      if (mounted) {
        setState(() {
          _emailController.text = account.email;
          _errorMessage = null;
        });
      }
    } catch (e) {
      _logger.e('Error obteniendo correo de Google: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'No se pudo obtener el correo de Google.';
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es obligatorio';
    }
    if (!RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(value)) {
      return 'Formato de correo electrónico inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 8) {
      return 'Debe tener al menos 8 caracteres';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'\d').hasMatch(value)) {
      return 'Debe incluir letras y números';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 32),
                    const Icon(
                      Icons.person,
                      size: 64,
                      color: Color(0xFF2979FF),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Completa tu perfil',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Añade tu correo y crea una contraseña para iniciar sesión',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _isLoading ? null : _fillEmailFromGoogle,
                        icon: const Icon(Icons.account_circle_outlined,
                            size: 18),
                        label: const Text('Usar mi correo de Google'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        helperText: 'Mínimo 8 caracteres, con letras y números',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscureConfirm = !_obscureConfirm);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
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
                    if (_success)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          '¡Perfil creado con éxito!',
                          style: TextStyle(color: Colors.green, fontSize: 15),
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
                                  'Crear cuenta',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
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
      ),
    );
  }
}
