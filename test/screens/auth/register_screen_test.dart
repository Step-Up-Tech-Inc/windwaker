import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/screens/auth/register_screen.dart';

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

  Future<void> pumpRegister(WidgetTester tester) =>
      pumpAuthScreen(tester, path: '/register', screen: const RegisterScreen());

  final phoneField = find.byType(TextFormField);
  final submitButton = find.widgetWithText(ElevatedButton, 'Enviar código SMS');

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();
  }

  testWidgets('muestra error de validación con teléfono inválido', (
    tester,
  ) async {
    await pumpRegister(tester);

    await tester.enterText(phoneField, '123');
    await submit(tester);

    expect(
      find.text('Número inválido. Usa 8 dígitos (CR) o formato internacional.'),
      findsOneWidget,
    );
    verifyNever(() => authService.sendRegistrationSms(any()));
  });

  testWidgets('envía SMS con el teléfono normalizado y navega al OTP', (
    tester,
  ) async {
    when(
      () => authService.sendRegistrationSms(any()),
    ).thenAnswer((_) async => SmsResult.success('Código enviado'));

    await pumpRegister(tester);
    await tester.enterText(phoneField, '8888 8888');
    await submit(tester);
    await tester.pumpAndSettle();

    verify(() => authService.sendRegistrationSms('+50688888888')).called(1);
    expect(find.text('OTP'), findsOneWidget);
  });

  testWidgets('muestra el error cuando el número ya está registrado', (
    tester,
  ) async {
    when(() => authService.sendRegistrationSms(any())).thenAnswer(
      (_) async => SmsResult.failure(
        'Este número ya está registrado. Por favor inicia sesión.',
      ),
    );

    await pumpRegister(tester);
    await tester.enterText(phoneField, '88888888');
    await submit(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Este número ya está registrado. Por favor inicia sesión.'),
      findsOneWidget,
    );
    expect(find.text('OTP'), findsNothing);
  });
}
