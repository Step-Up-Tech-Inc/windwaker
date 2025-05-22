import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:windwaker/screens/auth/widgets/social_login_buttons.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  bool showLogin = false;
  bool showRegister = false;
  bool _checkedSession = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkSessionAndRedirect();
  }

  Future<void> _checkSessionAndRedirect() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      if (!mounted) return;
      context.go('/location-permission');
    } else {
      setState(() {
        _checkedSession = true;
      });
    }
  }

  Future<void> _handleFacebookLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        // ignore: unused_local_variable
        final AccessToken accessToken = result.accessToken!;

        // Aquí se integraría con Supabase para autenticar con el token de Facebook
        // Ejemplo (adaptar según la implementación específica de Supabase):
        // await Supabase.instance.client.auth.signInWithIdToken(
        //   provider: Provider.facebook,
        //   idToken: accessToken.token,
        // );

        if (!mounted) return;
        context.go('/location-permission');
      } else {
        setState(() {
          _errorMessage = 'Error al iniciar sesión con Facebook';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
                  const SizedBox(height: 48),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withAlpha((0.08 * 255).round()),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: const Icon(
                      Icons.store,
                      size: 64,
                      color: Color(0xFF2979FF),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Tilarán en Línea',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tu ciudad en tu bolsillo',
                    style: TextStyle(
                      color: Color(0xFF424242),
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                context.go('/phone-login');
                              },
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
                                'Iniciar sesión con teléfono',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'o',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  SocialLoginButtons(
                    onFacebookPressed: _handleFacebookLogin,
                    onGooglePressed: () {
                      // Implementar login con Google
                    },
                    onApplePressed: null, // No disponible aún
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
