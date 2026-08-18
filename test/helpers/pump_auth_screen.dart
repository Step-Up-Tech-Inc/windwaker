import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Rutas del flujo de auth que se montan como pantallas stub (su nombre como
/// texto) para poder verificar navegación con `find.text(...)`.
const Map<String, String> stubRoutes = {
  '/home': 'HOME',
  '/auth': 'AUTH',
  '/login': 'LOGIN',
  '/register': 'REGISTER',
  '/otp-verification': 'OTP',
  '/complete-profile': 'COMPLETE_PROFILE',
  '/location-permission': 'LOCATION_PERMISSION',
};

/// Monta [screen] en [path] dentro de un GoRouter de prueba.
Future<void> pumpAuthScreen(
  WidgetTester tester, {
  required String path,
  required Widget screen,
}) async {
  final router = GoRouter(
    initialLocation: path,
    routes: [
      GoRoute(path: path, builder: (_, __) => screen),
      for (final entry in stubRoutes.entries)
        if (entry.key != path)
          GoRoute(
            path: entry.key,
            builder: (_, __) => Scaffold(body: Text(entry.value)),
          ),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
}
