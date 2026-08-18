import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/config/app_config.dart';

/// Paso 2 del registro: verificar el número de teléfono con el código SMS.
/// Al verificarse, el usuario queda autenticado y pasa a completar su perfil
/// (email + contraseña).
class OTPVerificationScreen extends StatefulWidget {
  final String phone;

  const OTPVerificationScreen({super.key, required this.phone});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _success = false;
  final _logger = Logger();
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _logger.i('🚀 === OTP VERIFICATION SCREEN INICIADA ===');
    _logger.i('🚀 Teléfono: ${widget.phone} | Modo app: ${AppConfig.currentMode}');
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final otp = _otpController.text.trim();
    _logger.i('🔐 Verificando OTP para ${widget.phone}');

    setState(() {
      _errorMessage = null;
      _isLoading = true;
      _success = false;
    });

    try {
      // El AuthService resuelve el código según el modo:
      // bypass=000000, testing=123456, production=SMS real.
      final authResult = await _authService.authenticateWithSmsCode(
        phoneNumber: widget.phone,
        smsCode: otp,
      );

      if (!mounted) return;

      if (!authResult.success) {
        setState(() {
          _errorMessage = authResult.error ?? 'Código inválido. Inténtalo de nuevo.';
        });
        return;
      }

      setState(() => _success = true);
      _logger.i('✅ Teléfono verificado - UserID: ${authResult.userId}');

      // Si el perfil ya estaba completo (cuenta a medio crear que se retomó),
      // no pedir email/contraseña de nuevo.
      final isProfileComplete = await _authService.isProfileCompleteAsync();
      if (!mounted) return;

      if (isProfileComplete) {
        _logger.i('✅ Perfil ya completo - Navegando a Home');
        context.go('/home');
      } else {
        _logger.i('🆕 Navegando a completar perfil (email + contraseña)');
        context.go(
          '/complete-profile?phone=${Uri.encodeComponent(widget.phone)}',
        );
      }
    } catch (e) {
      _logger.e('❌ Error inesperado en verificación OTP: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/register'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
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
                  const Icon(Icons.sms, size: 64, color: Color(0xFF2979FF)),
                  const SizedBox(height: 24),
                  const Text(
                    'Verificar teléfono',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ingresa el código de 6 dígitos enviado a ${widget.phone}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'Código de verificación',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                      counterText: '',
                    ),
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
                        '¡Teléfono verificado con éxito!',
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
                                'Verificar',
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
