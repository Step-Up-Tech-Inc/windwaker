import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/repositories/user_repository.dart';

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
  late final SharedPreferences _prefs;
  late final UserRepository _userRepository;

  @override
  void initState() {
    super.initState();
    _prefs = getIt<SharedPreferences>();
    _userRepository = getIt<UserRepository>();
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
      // Permitir bypass para pruebas locales con código 000000
      if (_otpController.text.trim() == '000000') {
        setState(() {
          _success = true;
        });

        // Guardar el teléfono en SharedPreferences
        await _prefs.setString('user_phone', widget.phone);
        debugPrint('Teléfono guardado en SharedPreferences: ${widget.phone}');

        await Future.delayed(const Duration(milliseconds: 1200));
        if (!mounted) return;
        final user = Supabase.instance.client.auth.currentUser;
        final String? email = user?.email;

        if (user != null) {
          // Actualizar el perfil en la tabla profiles
          try {
            await _userRepository.createOrUpdateUserProfile(
              userId: user.id,
              email: email,
              phone: widget.phone,
            );
            debugPrint('Perfil actualizado en la tabla profiles');
          } catch (e) {
            debugPrint('Error al actualizar perfil: $e');
          }
        }

        if (!mounted) return;
        if (email == null || email.isEmpty) {
          context.go('/complete-profile');
        } else {
          // Si ya tiene email, guardarlo también
          await _prefs.setString('user_email', email);
          debugPrint('Email guardado en SharedPreferences: $email');
          if (!mounted) return;
          context.go('/location-permission');
        }
        return;
      }

      final AuthResponse response = await Supabase.instance.client.auth
          .verifyOTP(
            type: OtpType.sms,
            phone: widget.phone,
            token: _otpController.text.trim(),
          );
      if (response.session != null) {
        setState(() {
          _success = true;
        });

        // Guardar el teléfono en SharedPreferences
        await _prefs.setString('user_phone', widget.phone);
        debugPrint('Teléfono guardado en SharedPreferences: ${widget.phone}');

        // Si hay email, guardarlo también
        final user = response.user;
        if (user?.email != null && user!.email!.isNotEmpty) {
          await _prefs.setString('user_email', user.email!);
          debugPrint('Email guardado en SharedPreferences: ${user.email}');
        }

        // Actualizar el perfil en la tabla profiles
        if (user != null) {
          try {
            await _userRepository.createOrUpdateUserProfile(
              userId: user.id,
              email: user.email,
              phone: widget.phone,
            );
            debugPrint('Perfil actualizado en la tabla profiles');
          } catch (e) {
            debugPrint('Error al actualizar perfil: $e');
          }
        }

        await Future.delayed(const Duration(milliseconds: 1200));
        if (!mounted) return;

        final String? email = user?.email;
        if (email == null || email.isEmpty) {
          context.go('/complete-profile');
        } else {
          context.go('/location-permission');
        }
      } else {
        setState(() {
          _errorMessage = 'Código incorrecto o expirado.';
        });
      }
    } on AuthException catch (err) {
      setState(() {
        _errorMessage = err.message;
      });
    } catch (_) {
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
