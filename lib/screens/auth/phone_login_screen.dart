import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:windwaker/core/repositories/user_repository.dart';
import 'package:windwaker/core/config/di_config.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final _logger = Logger();
  late final UserRepository _userRepository;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userRepository = getIt<UserRepository>();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final String phone =
            '+${_phoneController.text.replaceAll(RegExp(r'[\s\-\(\)]'), '')}';

        _logger.i('Intentando iniciar sesión con teléfono: $phone');

        // Verificar si ya existe una sesión y cerrarla si es necesario
        final currentSession = Supabase.instance.client.auth.currentSession;
        if (currentSession != null) {
          _logger.i('Ya existe una sesión activa, cerrándola primero');
          await Supabase.instance.client.auth.signOut();
        }

        // Iniciar sesión con OTP
        await Supabase.instance.client.auth.signInWithOtp(
          phone: phone,
          shouldCreateUser: true,
        );

        _logger.i('OTP enviado al teléfono: $phone');

        // Verificar si hay un usuario autenticado después del envío de OTP
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser != null) {
          _logger.i('Usuario autenticado: ${currentUser.id}');

          // Intentar crear o actualizar el perfil del usuario
          try {
            await _userRepository.createOrUpdateUserProfile(
              userId: currentUser.id,
              phone: phone,
            );
            _logger.i('Perfil de usuario creado/actualizado con éxito');

            // Verificar que el perfil se guardó correctamente
            final updatedProfile = await _userRepository.getUserProfile(
              currentUser.id,
            );
            _logger.i('Perfil después de actualización: $updatedProfile');
          } catch (profileError) {
            _logger.e('Error al crear/actualizar perfil: $profileError');
          }
        }

        if (!mounted) return;
        context.go('/otp-verification?phone=${Uri.encodeComponent(phone)}');
      } on AuthException catch (err) {
        _logger.e('Error de autenticación: ${err.message}');
        setState(() {
          _errorMessage = err.message;
        });
      } catch (e) {
        _logger.e('Error inesperado: $e');
        setState(() {
          _errorMessage = 'Ocurrió un error inesperado.';
        });
      } finally {
        setState(() => _isLoading = false);
      }
    }
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 32),
                    const Icon(
                      Icons.phone_android,
                      size: 64,
                      color: Color(0xFF2979FF),
                    ),
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
                      'Ingresa tu número de teléfono',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Número de teléfono',
                        border: OutlineInputBorder(),
                        prefixText: '+',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'El número es obligatorio';
                        }
                        final cleaned = value.replaceAll(
                          RegExp(r'[\s\-\(\)]'),
                          '',
                        );
                        // Solo dígitos, entre 8 y 15
                        if (!RegExp(r'^[1-9]\d{7,14} ?$').hasMatch(cleaned)) {
                          return 'Número inválido. Usa formato internacional (ej: 50688888888).';
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
                                  'Enviar código',
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
      ),
    );
  }
}
