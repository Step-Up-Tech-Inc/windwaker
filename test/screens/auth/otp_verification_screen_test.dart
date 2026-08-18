import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/screens/auth/otp_verification_screen.dart';

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

  Future<void> pumpOtp(WidgetTester tester) => pumpAuthScreen(
        tester,
        path: '/otp-verification',
        screen: const OTPVerificationScreen(phone: phone),
      );

  final codeField = find.byType(TextField);
  final submitButton = find.widgetWithText(ElevatedButton, 'Verificar');

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();
  }

  testWidgets('con código válido y perfil incompleto navega a completar perfil',
      (tester) async {
    when(
      () => authService.authenticateWithSmsCode(
        phoneNumber: any(named: 'phoneNumber'),
        smsCode: any(named: 'smsCode'),
      ),
    ).thenAnswer((_) async => AuthResult.success('user-1'));
    when(
      () => authService.isProfileCompleteAsync(),
    ).thenAnswer((_) async => false);

    await pumpOtp(tester);
    await tester.enterText(codeField, '123456');
    await submit(tester);
    await tester.pumpAndSettle();

    verify(
      () => authService.authenticateWithSmsCode(
        phoneNumber: phone,
        smsCode: '123456',
      ),
    ).called(1);
    expect(find.text('COMPLETE_PROFILE'), findsOneWidget);
  });

  testWidgets('con código válido y perfil completo navega a home', (
    tester,
  ) async {
    when(
      () => authService.authenticateWithSmsCode(
        phoneNumber: any(named: 'phoneNumber'),
        smsCode: any(named: 'smsCode'),
      ),
    ).thenAnswer((_) async => AuthResult.success('user-1'));
    when(
      () => authService.isProfileCompleteAsync(),
    ).thenAnswer((_) async => true);

    await pumpOtp(tester);
    await tester.enterText(codeField, '123456');
    await submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('muestra el error cuando el código es incorrecto', (
    tester,
  ) async {
    when(
      () => authService.authenticateWithSmsCode(
        phoneNumber: any(named: 'phoneNumber'),
        smsCode: any(named: 'smsCode'),
      ),
    ).thenAnswer(
      (_) async => AuthResult.failure('Código de testing inválido'),
    );

    await pumpOtp(tester);
    await tester.enterText(codeField, '000001');
    await submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Código de testing inválido'), findsOneWidget);
    expect(find.text('COMPLETE_PROFILE'), findsNothing);
    verifyNever(() => authService.isProfileCompleteAsync());
  });
}
