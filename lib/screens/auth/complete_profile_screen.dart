import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'widgets/social_login_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windwaker/core/repositories/user_repository.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String? phone;
  final String? otp;
  final bool bypass;
  const CompleteProfileScreen({
    super.key,
    this.phone,
    this.otp,
    this.bypass = false,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _success = false;
  late final UserRepository _userRepository;
  late final SharedPreferences _prefs;
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    _userRepository = getIt<UserRepository>();
    _prefs = getIt<SharedPreferences>();
    _loadSavedEmail();
  }

  void _loadSavedEmail() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user?.email != null && user!.email!.isNotEmpty) {
      _emailController.text = user.email!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _success = false;
    });

    // Validar el formulario
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _logger.i('=== INICIANDO SUBMIT EN COMPLETE PROFILE ===');
      _logger.i('Phone recibido: ${widget.phone}');
      _logger.i('OTP recibido: ${widget.otp}');
      _logger.i('Bypass mode: ${widget.bypass}');

      // Normalizar el correo electrónico: eliminar espacios y convertir a minúsculas
      final String email = _emailController.text.trim().toLowerCase();
      if (email.isEmpty) {
        setState(() {
          _errorMessage = 'El correo no puede estar vacío.';
        });
        return;
      }
      _logger.i('Email a procesar: $email');

      String? phone;
      String? userId;
      bool isAutoBypass =
          false; // Para rastrear si activamos bypass automáticamente

      if (widget.bypass) {
        // En modo bypass, usar los parámetros directamente
        _logger.i('=== MODO BYPASS ACTIVADO ===');
        phone = widget.phone;
        if (phone == null || phone.isEmpty) {
          setState(() {
            _errorMessage = 'Número de teléfono requerido en modo bypass.';
          });
          return;
        }
        // Generar un UUID válido para bypass
        const uuid = Uuid();
        userId = uuid.v4();
        _logger.i('Bypass - Phone: $phone, UserID UUID generado: $userId');
      } else {
        // Flujo normal - verificar autenticación
        _logger.i('=== VERIFICANDO AUTENTICACIÓN ===');
        var user = Supabase.instance.client.auth.currentUser;
        _logger.i('Current User no nulo: ${user != null}');

        if (user != null) {
          _logger.i('User ID: ${user.id}');
          _logger.i('User Phone: ${user.phone}');
          _logger.i('User Email: ${user.email}');
          _logger.i('User JSON completo: ${user.toJson()}');
        }

        // Verificar también si hay una sesión activa
        var session = Supabase.instance.client.auth.currentSession;
        _logger.i('Current Session no nula: ${session != null}');
        if (session != null) {
          _logger.i('Session User ID: ${session.user.id}');
          _logger.i('Session expires at: ${session.expiresAt}');
          _logger.i('Session is expired: ${session.isExpired}');
        }

        // Si no hay usuario pero tenemos phone y OTP, intentar re-verificar
        if (user == null && widget.phone != null && widget.otp != null) {
          _logger.i(
            '🔄 Usuario no autenticado, intentando re-verificar con OTP...',
          );

          // Si es modo bypass con OTP 000000, no intentar re-verificar con Supabase
          if (widget.otp == '000000') {
            _logger.i(
              '🚫 OTP es bypass (000000), saltando re-verificación de Supabase',
            );
            _logger.i('🔄 Cambiando a modo bypass automáticamente...');

            // Cambiar a modo bypass automáticamente
            const uuid = Uuid();
            userId = uuid.v4();
            phone = widget.phone;
            isAutoBypass = true;

            _logger.i('🎯 Bypass automático activado:');
            _logger.i('   Phone: $phone');
            _logger.i('   UserID UUID generado: $userId');
          } else {
            // OTP real, intentar re-verificar con Supabase
            try {
              final reVerifyResponse = await Supabase.instance.client.auth
                  .verifyOTP(
                    type: OtpType.sms,
                    phone: widget.phone!,
                    token: widget.otp!,
                  );

              if (reVerifyResponse.session != null &&
                  reVerifyResponse.user != null) {
                _logger.i('✅ Re-verificación exitosa');
                user = reVerifyResponse.user;
                session = reVerifyResponse.session;

                // Actualizar las variables de logging
                _logger.i('Re-verified User ID: ${user!.id}');
                _logger.i('Re-verified User Phone: ${user.phone}');
                _logger.i('Re-verified User Email: ${user.email}');
              } else {
                _logger.e('❌ Re-verificación falló - no session/user');
              }
            } catch (reVerifyError) {
              _logger.e('❌ Error en re-verificación: $reVerifyError');
            }
          }
        }

        // Verificar si tenemos usuario después de re-verificación o bypass automático
        if (user == null && userId == null) {
          _logger.e('CRÍTICO: No hay usuario autenticado en CompleteProfile');
          setState(() {
            _errorMessage =
                'No hay usuario autenticado. Por favor, inicia sesión nuevamente.';
          });
          return;
        }

        // Si tenemos user de Supabase, usar sus datos
        if (user != null) {
          userId = user.id;
          phone = user.phone;
          if (phone == null || phone.isEmpty) {
            setState(() {
              _errorMessage = 'No se pudo obtener el número de teléfono.';
            });
            return;
          }
        }
        // Si no tenemos user pero sí userId (bypass automático), usar phone del widget
        else if (userId != null && isAutoBypass) {
          phone = widget.phone;
        }
      }

      _logger.i('Email a guardar en Supabase: $email');
      _logger.i('Phone a guardar: $phone');
      _logger.i('UserID a usar: $userId');

      // Verificar que tenemos userId válido antes de continuar
      if (userId == null) {
        _logger.e(
          'CRÍTICO: userId es null después de toda la lógica de autenticación',
        );
        setState(() {
          _errorMessage = 'Error interno: No se pudo obtener el ID de usuario.';
        });
        return;
      }

      // DIAGNÓSTICO DE SUPABASE - Agregar antes del guardado
      _logger.i('🔧 === DIAGNÓSTICO DE SUPABASE ===');
      try {
        final diagResult = await _userRepository.verifyProfilesTable();
        _logger.i('📊 Resultado de diagnóstico: $diagResult');

        if (diagResult.containsKey('error')) {
          _logger.e('❌ Error en diagnóstico: ${diagResult['error']}');
          setState(() {
            _errorMessage =
                'Error de configuración en la base de datos: ${diagResult['error']}';
          });
          return;
        }

        if (diagResult['writable'] == false) {
          _logger.e('❌ La tabla profiles no es escribible');
          _logger.e('   Razón: ${diagResult['reason'] ?? 'Desconocida'}');
          setState(() {
            _errorMessage =
                'No tienes permisos para escribir en la base de datos. Verifica la configuración RLS.';
          });
          return;
        }

        _logger.i('✅ Diagnóstico exitoso - tabla accesible y escribible');
      } catch (diagError) {
        _logger.e('❌ Error durante el diagnóstico: $diagError');
        setState(() {
          _errorMessage =
              'Error al verificar la configuración de la base de datos: $diagError';
        });
        return;
      }

      // 1. Actualizar el email en Supabase Auth (solo si no es bypass)
      if (!widget.bypass && !isAutoBypass) {
        final user = Supabase.instance.client.auth.currentUser!;
        try {
          _logger.i('Intentando actualizar email en Auth a: $email');
          if (user.email != email) {
            final authResponse = await Supabase.instance.client.auth.updateUser(
              UserAttributes(email: email),
            );
            _logger.i(
              'Respuesta de actualización en Auth: ${authResponse.user?.email}',
            );
            if (authResponse.user?.email != email) {
              setState(() {
                _errorMessage = 'No se pudo actualizar el correo en Auth.';
              });
              return;
            }
          }
        } catch (e) {
          _logger.e('Error al actualizar email en Auth: $e');
          setState(() {
            _errorMessage = 'Error al actualizar el correo en Auth: $e';
          });
          return;
        }
      } else {
        _logger.i(
          'Bypass mode (original o automático): saltando actualización de Auth',
        );
      }

      // 2. Guardar ambos datos en la tabla profiles
      bool profileOk = false;

      // Usar solo el método del repositorio (más seguro y estable)
      try {
        _logger.i('=== GUARDANDO PERFIL CON REPOSITORIO ===');
        _logger.i('UserID: $userId');
        _logger.i('Email: $email');
        _logger.i('Phone: $phone');

        await _userRepository.createOrUpdateUserProfile(
          userId: userId,
          email: email,
          phone: phone,
        );
        _logger.i('✅ Guardado con repositorio completado, verificando...');

        // Esperar un momento para que se procese la operación
        await Future.delayed(const Duration(milliseconds: 1000));

        final updatedProfile = await _userRepository.getUserProfile(userId);
        _logger.i('📋 Perfil después de repositorio: $updatedProfile');

        if (updatedProfile != null) {
          final savedEmail = updatedProfile['email']?.toString().toLowerCase();
          final savedPhone = updatedProfile['phone']?.toString();

          _logger.i('🔍 Comparando valores:');
          _logger.i('   Expected email: "$email"');
          _logger.i('   Saved email: "$savedEmail"');
          _logger.i('   Expected phone: "$phone"');
          _logger.i('   Saved phone: "$savedPhone"');

          // Verificar que al menos uno de los campos se haya guardado
          bool emailOk = email == savedEmail;
          bool phoneOk = phone == savedPhone;

          _logger.i('🎯 Verificación de campos:');
          _logger.i('   Email coincide: $emailOk');
          _logger.i('   Phone coincide: $phoneOk');

          if (emailOk && phoneOk) {
            profileOk = true;
            _logger.i('✅ Ambos campos guardados correctamente');
          } else if (emailOk || phoneOk) {
            _logger.w('⚠️ Solo uno de los campos se guardó correctamente');
            _logger.w('   Email OK: $emailOk, Phone OK: $phoneOk');

            // Si solo uno se guardó, intentar guardar el otro por separado
            if (!emailOk) {
              _logger.i('🔄 Intentando guardar email por separado...');
              try {
                await _userRepository.createOrUpdateUserProfile(
                  userId: userId,
                  email: email,
                  phone: null, // No tocar el teléfono
                );
                _logger.i('✅ Email guardado por separado');
              } catch (e) {
                _logger.e('❌ Error al guardar email por separado: $e');
              }
            }

            if (!phoneOk) {
              _logger.i('🔄 Intentando guardar teléfono por separado...');
              try {
                await _userRepository.createOrUpdateUserProfile(
                  userId: userId,
                  email: null, // No tocar el email
                  phone: phone,
                );
                _logger.i('✅ Teléfono guardado por separado');
              } catch (e) {
                _logger.e('❌ Error al guardar teléfono por separado: $e');
              }
            }

            // Verificar nuevamente
            _logger.i(
              '🔄 Verificando nuevamente después de guardado individual...',
            );
            await Future.delayed(const Duration(milliseconds: 1000));
            final finalProfile = await _userRepository.getUserProfile(userId);
            _logger.i('📋 Perfil final: $finalProfile');

            final finalEmail =
                finalProfile != null
                    ? finalProfile['email']?.toString().toLowerCase()
                    : null;
            final finalPhone =
                finalProfile != null ? finalProfile['phone']?.toString() : null;

            _logger.i('🔍 Verificación final:');
            _logger.i('   Final email: "$finalEmail" (expected: "$email")');
            _logger.i('   Final phone: "$finalPhone" (expected: "$phone")');

            if (finalEmail == email && finalPhone == phone) {
              profileOk = true;
              _logger.i(
                '✅ Ambos campos guardados correctamente en segundo intento',
              );
            } else {
              _logger.w('⚠️ Aún hay problemas con el guardado');
              _logger.w('   Final email matches: ${finalEmail == email}');
              _logger.w('   Final phone matches: ${finalPhone == phone}');

              // Aceptar si al menos el email se guardó (es lo más importante)
              if (finalEmail == email) {
                profileOk = true;
                _logger.i('✅ Al menos el email se guardó correctamente');
              } else {
                _logger.e('❌ Ni siquiera el email se guardó correctamente');
              }
            }
          } else {
            _logger.e('❌ Ningún campo se guardó correctamente');
            _logger.e('   Expected email: "$email", got: "$savedEmail"');
            _logger.e('   Expected phone: "$phone", got: "$savedPhone"');
          }
        } else {
          _logger.e('❌ No se pudo obtener el perfil después del guardado');
          _logger.e('   getUserProfile devolvió null para userId: $userId');
        }
      } catch (e) {
        _logger.e('❌ Error al guardar perfil con repositorio: $e');
        _logger.e('   Tipo de error: ${e.runtimeType}');
        _logger.e('   Stack trace: ${StackTrace.current}');
      }

      // 4. Si sigue sin guardarse, mostrar error detallado
      if (!profileOk) {
        _logger.e('💥 CRÍTICO: No se pudo guardar el perfil');
        _logger.e('   profileOk = false');
        _logger.e('   userId = $userId');
        _logger.e('   email = $email');
        _logger.e('   phone = $phone');
        setState(() {
          _errorMessage =
              'No se pudo guardar el perfil completo en la base de datos. Intenta nuevamente.';
        });
        return;
      }

      _logger.i('🎉 PERFIL GUARDADO EXITOSAMENTE');
      if (!mounted) return;
      setState(() {
        _success = true;
      });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      context.go('/location-permission');
    } catch (e) {
      _logger.e('Error al completar perfil: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Ocurrió un error al guardar tu perfil. Por favor, intenta nuevamente.';
        _success = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
      _success = false;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Inicio de sesión cancelado.';
        });
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'No se pudo obtener el token de Google.';
        });
        return;
      }
      final AuthResponse response = await Supabase.instance.client.auth
          .signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);
      if (response.user == null) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'No se pudo iniciar sesión con Google.';
        });
        return;
      }

      // Guardar el email en SharedPreferences
      if (response.user?.email != null) {
        await _prefs.setString('user_email', response.user!.email!);
        debugPrint(
          'Email guardado en SharedPreferences: ${response.user!.email}',
        );

        // Crear o actualizar el perfil en la tabla profiles
        final phone = _prefs.getString('user_phone');
        await _userRepository.createOrUpdateUserProfile(
          userId: response.user!.id,
          email: response.user!.email,
          phone: phone,
        );
        debugPrint('Perfil actualizado en la tabla profiles');
      }

      if (!mounted) return;
      setState(() {
        _success = true;
      });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      context.go('/location-permission');
    } on AuthException catch (err) {
      if (!mounted) return;
      setState(() {
        _errorMessage = err.message;
      });
    } catch (_) {
      if (!mounted) return;
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

  Future<void> _signInWithFacebook() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
      _success = false;
    });
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'No se pudo iniciar sesión con Facebook.';
        });
        return;
      }
      final String? accessToken = result.accessToken?.token;
      if (accessToken == null) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'No se pudo obtener el token de Facebook.';
        });
        return;
      }
      final AuthResponse response = await Supabase.instance.client.auth
          .signInWithIdToken(
            provider: OAuthProvider.facebook,
            idToken: accessToken,
          );
      if (response.user == null) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'No se pudo iniciar sesión con Facebook.';
        });
        return;
      }

      // Guardar el email en SharedPreferences
      if (response.user?.email != null) {
        await _prefs.setString('user_email', response.user!.email!);
        debugPrint(
          'Email guardado en SharedPreferences: ${response.user!.email}',
        );

        // Crear o actualizar el perfil en la tabla profiles
        final phone = _prefs.getString('user_phone');
        await _userRepository.createOrUpdateUserProfile(
          userId: response.user!.id,
          email: response.user!.email,
          phone: phone,
        );
        debugPrint('Perfil actualizado en la tabla profiles');
      }

      if (!mounted) return;
      setState(() {
        _success = true;
      });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      context.go('/location-permission');
    } on AuthException catch (err) {
      if (!mounted) return;
      setState(() {
        _errorMessage = err.message;
      });
    } catch (_) {
      if (!mounted) return;
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
                      'Añade tu correo electrónico',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
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
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'El correo es obligatorio';
                        }
                        if (!RegExp(
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
                        ).hasMatch(value)) {
                          return 'Formato de correo electrónico inválido';
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SelectableText.rich(
                          const TextSpan(
                            text: '¡Correo guardado con éxito!',
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
                                  'Guardar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SocialLoginButtons(
                      onGooglePressed: _signInWithGoogle,
                      onFacebookPressed: _signInWithFacebook,
                      onApplePressed: null,
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
