import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/screens/auth/complete_profile_screen.dart';

import '../../helpers/mocks.dart';
import '../../helpers/pump_auth_screen.dart';

void main() {
  const phone = '+50688888888';
  late MockAuthService authService;

  setUp(() {
    authService = MockAuthService();
    getIt.registerSingleton<AuthService>(authService);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpCompleteProfile(WidgetTester tester) => pumpAuthScreen(
        tester,
        path: '/complete-profile',
        screen: const CompleteProfileScreen(phone: phone),
      );

  final emailField = find.byType(TextFormField).at(0);
  final passwordField = find.byType(TextFormField).at(1);
  final confirmField = find.byType(TextFormField).at(2);
  final submitButton = find.widgetWithText(ElevatedButton, 'Crear cuenta');

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();
  }

  testWidgets('valida contraseña débil', (tester) async {
    await pumpCompleteProfile(tester);

    await tester.enterText(emailField, 'edgar@test.com');
    await tester.enterText(passwordField, 'corta1');
    await tester.enterText(confirmField, 'corta1');
    await submit(tester);

    expect(find.text('Debe tener al menos 8 caracteres'), findsOneWidget);
    verifyNever(
      () => authService.completeRegistration(
        email: any(named: 'email'),
        password: any(named: 'password'),
        phone: any(named: 'phone'),
      ),
    );
  });

  testWidgets('exige letras y números en la contraseña', (tester) async {
    await pumpCompleteProfile(tester);

    await tester.enterText(emailField, 'edgar@test.com');
    await tester.enterText(passwordField, 'solotexto');
    await tester.enterText(confirmField, 'solotexto');
    await submit(tester);

    expect(find.text('Debe incluir letras y números'), findsOneWidget);
  });

  testWidgets('valida que las contraseñas coincidan', (tester) async {
    await pumpCompleteProfile(tester);

    await tester.enterText(emailField, 'edgar@test.com');
    await tester.enterText(passwordField, 'Secreto123');
    await tester.enterText(confirmField, 'Secreto124');
    await submit(tester);

    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
  });

  testWidgets(
      'completa el registro y navega a permisos de ubicación', (tester) async {
    when(
      () => authService.completeRegistration(
        email: any(named: 'email'),
        password: any(named: 'password'),
        phone: any(named: 'phone'),
      ),
    ).thenAnswer((_) async => AuthResult.success('user-1', isNewUser: true));

    await pumpCompleteProfile(tester);
    await tester.enterText(emailField, 'Edgar@Test.com');
    await tester.enterText(passwordField, 'Secreto123');
    await tester.enterText(confirmField, 'Secreto123');
    await submit(tester);

    expect(find.text('¡Perfil creado con éxito!'), findsOneWidget);

    // Esperar la pausa de 800 ms antes de la navegación
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    verify(
      () => authService.completeRegistration(
        email: 'edgar@test.com',
        password: 'Secreto123',
        phone: phone,
      ),
    ).called(1);
    expect(find.text('LOCATION_PERMISSION'), findsOneWidget);
  });

  testWidgets('muestra el error cuando el correo ya está en uso', (
    tester,
  ) async {
    when(
      () => authService.completeRegistration(
        email: any(named: 'email'),
        password: any(named: 'password'),
        phone: any(named: 'phone'),
      ),
    ).thenAnswer(
      (_) async => AuthResult.failure('Ya existe una cuenta con este correo.'),
    );
    when(() => authService.isAuthenticated()).thenReturn(true);

    await pumpCompleteProfile(tester);
    await tester.enterText(emailField, 'edgar@test.com');
    await tester.enterText(passwordField, 'Secreto123');
    await tester.enterText(confirmField, 'Secreto123');
    await submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Ya existe una cuenta con este correo.'), findsOneWidget);
    expect(find.text('LOCATION_PERMISSION'), findsNothing);
  });

  testWidgets('si la sesión expiró regresa a /auth', (tester) async {
    when(
      () => authService.completeRegistration(
        email: any(named: 'email'),
        password: any(named: 'password'),
        phone: any(named: 'phone'),
      ),
    ).thenAnswer(
      (_) async => AuthResult.failure(
        'Tu sesión expiró. Por favor verifica tu número nuevamente.',
      ),
    );
    when(() => authService.isAuthenticated()).thenReturn(false);

    await pumpCompleteProfile(tester);
    await tester.enterText(emailField, 'edgar@test.com');
    await tester.enterText(passwordField, 'Secreto123');
    await tester.enterText(confirmField, 'Secreto123');
    await submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('AUTH'), findsOneWidget);
  });
}
