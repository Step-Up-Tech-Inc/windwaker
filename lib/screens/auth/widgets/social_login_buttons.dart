import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  final void Function()? onGooglePressed;
  final void Function()? onFacebookPressed;
  final void Function()? onApplePressed;

  const SocialLoginButtons({
    super.key,
    this.onGooglePressed,
    this.onFacebookPressed,
    this.onApplePressed,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
          label: const Text(
            'Continuar con Google',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: onGooglePressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.facebook, size: 24, color: Color(0xFF1877F2)),
          label: const Text(
            'Continuar con Facebook',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: onFacebookPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.apple, size: 24, color: Colors.black),
          label: const Text(
            'Continuar con Apple (próximamente)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: onApplePressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    ],
  );
}
