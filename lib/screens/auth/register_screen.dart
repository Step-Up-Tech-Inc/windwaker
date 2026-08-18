import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/config/app_config.dart';
import 'package:windwaker/core/utils/phone_number.dart';

/// Paso 1 del registro: el usuario ingresa su número de teléfono y se le
/// envía un código SMS de verificación. Flujo completo:
/// teléfono → verificar OTP → completar perfil (email + contraseña).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final _logger = Logger();

  String? _errorMessage;
  bool _isLoading = false;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _logger.i('🚀 === REGISTER SCREEN INICIADA ===');
    _logger.i('🚀 Modo actual: ${AppConfig.currentMode}');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String? phone = PhoneNumber.normalize(_phoneController.text.trim());
      if (phone == null) {
        setState(() => _errorMessage = 'Número de teléfono inválido.');
        return;
      }

      _logger.i('📱 Registrando teléfono: $phone');

      final smsResult = await _authService.sendRegistrationSms(phone);
      if (!smsResult.success) {
        _logger.e('❌ No se pudo enviar el SMS: ${smsResult.message}');
        setState(() => _errorMessage = smsResult.message);
        return;
      }

      _logger.i('✅ SMS enviado, navegando a verificación OTP');
      if (!mounted) return;
      context.go('/otp-verification?phone=${Uri.encodeComponent(phone)}');
    } catch (e) {
      _logger.e('❌ Error inesperado durante registro: $e');
      setState(() {
        _errorMessage = 'Ocurrió un error inesperado. Inténtalo de nuevo.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                  const Icon(
                    Icons.person_add,
                    size: 64,
                    color: Color(0xFF2979FF),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Crear perfil',
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
                  const SizedBox(height: 16),
                  const Text(
                    'Te enviaremos un código SMS para verificarlo',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Número de teléfono',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_outlined),
                      hintText: '8888 8888',
                      helperText:
                          'Números de Costa Rica: solo los 8 dígitos.',
                    ),
                    validator: PhoneNumber.validate,
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
                                'Enviar código SMS',
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
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      '¿Ya tienes cuenta? Inicia sesión',
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
