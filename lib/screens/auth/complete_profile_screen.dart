import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'widgets/social_login_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windwaker/core/repositories/user_repository.dart';
import 'package:windwaker/core/config/di_config.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

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
    } else {
      final savedEmail = _prefs.getString('user_email');
      if (savedEmail != null) {
        _emailController.text = savedEmail;
      }
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
      // Normalizar el correo electrónico: eliminar espacios y convertir a minúsculas
      final String email = _emailController.text.trim().toLowerCase();

      // Guardar el email en SharedPreferences
      await _prefs.setString('user_email', email);
      debugPrint('Email guardado en SharedPreferences: $email');

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Actualizar el email en Supabase Auth
        try {
          final authResponse = await Supabase.instance.client.auth.updateUser(
            UserAttributes(email: email),
          );
          debugPrint('Email actualizado en Auth: ${authResponse.user?.email}');

          // Crear o actualizar el perfil en la tabla profiles
          final phone = _prefs.getString('user_phone');
          await _userRepository.createOrUpdateUserProfile(
            userId: user.id,
            email: email,
            phone: phone,
          );
          debugPrint('Perfil actualizado en la tabla profiles');
        } catch (authError) {
          debugPrint(
            'Error al actualizar email en Auth (continuando de todos modos): $authError',
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _success = true;
      });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      context.go('/location-permission');
    } on AuthException catch (err) {
      debugPrint('Error de autenticación: ${err.message}');
      if (!mounted) return;
      setState(() {
        _errorMessage = err.message;
      });
    } catch (e) {
      debugPrint('Error inesperado: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Ocurrió un error inesperado: $e';
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
