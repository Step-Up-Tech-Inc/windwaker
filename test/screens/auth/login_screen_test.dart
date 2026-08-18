import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/screens/auth/login_screen.dart';

import '../../helpers/mocks.dart';
import '../../helpers/pump_auth_screen.dart';

void main() {
  late MockAuthService authService;

  setUp(() {
    authService = MockAuthService();
    getIt.registerSingleton<AuthService>(authService);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpLogin(WidgetTester tester) =>
      pumpAuthScreen(tester, path: '/login', screen: const LoginScreen());

  final identifierField = find.byType(TextFormField).at(0);
  final passwordField = find.byType(TextFormField).at(1);
  final submitButton = find.widgetWithText(ElevatedButton, 'Iniciar sesión');

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();
  }

  testWidgets('muestra error de validación con correo inválido', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tester.enterText(identifierField, 'correo@invalido');
    await tester.enterText(passwordField, 'Secreto123');
    await submit(tester);

    expect(find.text('Formato de correo electrónico inválido'), findsOneWidget);
    verifyNever(
      () => authService.signInWithPassword(
        identifier: any(named: 'identifier'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('muestra error de validación con teléfono inválido', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tester.enterText(identifierField, '123');
    await tester.enterText(passwordField, 'Secreto123');
    await submit(tester);

    expect(
      find.text('Número inválido. Usa 8 dígitos (CR) o formato internacional.'),
      findsOneWidget,
    );
  });

  testWidgets('exige contraseña', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(identifierField, 'edgar@test.com');
    await submit(tester);

    expect(find.text('La contraseña es obligatoria'), findsOneWidget);
  });

  testWidgets('login con correo lo normaliza a minúsculas y navega a home', (
    tester,
  ) async {
    when(
      () => authService.signInWithPassword(
        identifier: any(named: 'identifier'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => AuthResult.success('user-1'));

    await pumpLogin(tester);
    await tester.enterText(identifierField, 'Edgar@Test.com');
    await tester.enterText(passwordField, 'Secreto123');
    await submit(tester);
    await tester.pumpAndSettle();

    verify(
      () => authService.signInWithPassword(
        identifier: 'edgar@test.com',
        password: 'Secreto123',
      ),
    ).called(1);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('login con teléfono de 8 dígitos antepone +506', (tester) async {
    when(
      () => authService.signInWithPassword(
        identifier: any(named: 'identifier'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => AuthResult.success('user-1'));

    await pumpLogin(tester);
    await tester.enterText(identifierField, '8888 8888');
    await tester.enterText(passwordField, 'Secreto123');
    await submit(tester);
    await tester.pumpAndSettle();

    verify(
      () => authService.signInWithPassword(
        identifier: '+50688888888',
        password: 'Secreto123',
      ),
    ).called(1);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('muestra el error cuando las credenciales son inválidas', (
    tester,
  ) async {
    when(
      () => authService.signInWithPassword(
        identifier: any(named: 'identifier'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async =>
          AuthResult.failure('Correo/teléfono o contraseña incorrectos.'),
    );

    await pumpLogin(tester);
    await tester.enterText(identifierField, 'edgar@test.com');
    await tester.enterText(passwordField, 'ContraseñaMala1');
    await submit(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Correo/teléfono o contraseña incorrectos.'),
      findsOneWidget,
    );
    expect(find.text('HOME'), findsNothing);
  });
}
