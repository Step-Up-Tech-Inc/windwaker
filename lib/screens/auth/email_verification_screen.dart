import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;
  final Logger _logger = Logger();

  EmailVerificationScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar correo'),
        backgroundColor: const Color(0xFF2979FF),
        foregroundColor: Colors.white,
        elevation: 0,
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
                  const Icon(
                    Icons.mark_email_read,
                    size: 64,
                    color: Color(0xFF2979FF),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Te hemos enviado un correo de confirmación.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Revisa tu bandeja de entrada y haz clic en el enlace para activar tu cuenta.',
                    style: TextStyle(color: Colors.grey[800], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Color(0xFF2979FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () {
                      // Aquí puedes implementar la lógica para reenviar el correo si lo deseas
                      _logger.i('Reenviar correo a: $email');
                    },
                    child: const Text('Reenviar correo de confirmación'),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Volver al inicio de sesión'),
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
