import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
      _success = false;
    });
    try {
      final otp = _otpController.text.trim();

      // Código bypass para desarrollo - navegar directamente sin autenticación
      if (otp == '000000') {
        _logger.i(
          'Usando código bypass 000000 para pruebas - navegando directamente',
        );
        setState(() {
          _success = true;
        });

        // En modo bypass, navegamos directamente a completar perfil
        // pasando los parámetros necesarios
        _logger.i('Bypass: navegando directamente a completar perfil');
        if (!mounted) return;
        context.go(
          '/complete-profile?phone=${Uri.encodeComponent(widget.phone)}&otp=$otp&bypass=true',
        );
        return;
      }

      _logger.i('Verificando OTP: $otp para teléfono: ${widget.phone}');
      final AuthResponse response = await Supabase.instance.client.auth
          .verifyOTP(type: OtpType.sms, phone: widget.phone, token: otp);

      _logger.i('=== RESPUESTA VERIFY OTP ===');
      _logger.i('Session no nula: ${response.session != null}');
      _logger.i('User no nulo: ${response.user != null}');
      if (response.session != null) {
        _logger.i(
          'Access Token: ${response.session!.accessToken.substring(0, 20)}...',
        );
        _logger.i(
          'Refresh Token no nulo: ${response.session!.refreshToken != null}',
        );
        _logger.i('User ID: ${response.session!.user.id}');
        _logger.i('User Phone: ${response.session!.user.phone}');
        _logger.i('User Email: ${response.session!.user.email}');
      }

      _logger.i('=== USUARIO ACTUAL ANTES DEL DELAY ===');
      final userBeforeDelay = Supabase.instance.client.auth.currentUser;
      _logger.i('Current User no nulo: ${userBeforeDelay != null}');
      if (userBeforeDelay != null) {
        _logger.i('Current User ID: ${userBeforeDelay.id}');
        _logger.i('Current User Phone: ${userBeforeDelay.phone}');
        _logger.i('Current User Email: ${userBeforeDelay.email}');
      }

      if (response.session != null) {
        setState(() {
          _success = true;
        });

        // Intentar refrescar la sesión para asegurar que esté correctamente establecida
        try {
          _logger.i('Intentando refrescar la sesión...');
          final refreshResponse =
              await Supabase.instance.client.auth.refreshSession();
          _logger.i(
            'Sesión refrescada exitosamente: ${refreshResponse.session != null}',
          );
        } catch (e) {
          _logger.w('Error al refrescar la sesión: $e');
        }

        // Delay para asegurar que la sesión se establezca completamente
        await Future.delayed(const Duration(milliseconds: 1000));

        _logger.i('=== USUARIO ACTUAL DESPUÉS DEL DELAY ===');
        final currentUser = Supabase.instance.client.auth.currentUser;
        _logger.i('Current User no nulo: ${currentUser != null}');
        if (currentUser != null) {
          _logger.i('Current User ID: ${currentUser.id}');
          _logger.i('Current User Phone: ${currentUser.phone}');
          _logger.i('Current User Email: ${currentUser.email}');
          _logger.i('Current User JSON: ${currentUser.toJson()}');
        }

        if (currentUser == null) {
          _logger.e(
            'CRÍTICO: Usuario no autenticado después de verifyOTP, refresh y delay',
          );
          setState(() {
            _errorMessage = 'Error en la autenticación. Intenta nuevamente.';
          });
          return;
        }

        final user = response.user;
        String? email = user?.email;
        if (email == null || email.isEmpty) {
          _logger.i('Usuario sin email, navegando a completar perfil');
          if (!mounted) return;
          context.go(
            '/complete-profile?phone=${Uri.encodeComponent(widget.phone)}&otp=$otp',
          );
          return;
        } else {
          _logger.i('Usuario con email, navegando a permisos de ubicación');
          if (!mounted) return;
          context.go('/location-permission');
          return;
        }
      } else {
        _logger.w('Código OTP incorrecto o expirado');
        setState(() {
          _errorMessage = 'Código incorrecto o expirado.';
        });
      }
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 32),
                  const Icon(Icons.sms, size: 64, color: Color(0xFF2979FF)),
                  const SizedBox(height: 24),
                  const Text(
                    'Verificar código',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ingresa el código que recibiste por SMS',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Código de verificación',
                      border: OutlineInputBorder(),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SelectableText.rich(
                        const TextSpan(
                          text: '¡Teléfono verificado con éxito!',
                          style: TextStyle(color: Colors.green, fontSize: 15),
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
