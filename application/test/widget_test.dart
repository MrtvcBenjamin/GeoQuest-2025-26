import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:application/auth/auth_validators.dart';
import 'package:application/screens/change_password_screen.dart';
import 'package:application/screens/create_account_screen.dart';
import 'package:application/screens/login_screen.dart';
import 'package:application/screens/onboarding_flow.dart';
import 'package:application/screens/role_select_screen.dart';

void main() {
  test('auth validators basics', () {
    expect(AuthValidators.isValidEmail('test@example.com'), isTrue);
    expect(AuthValidators.isValidEmail('invalid-mail'), isFalse);
    expect(AuthValidators.isValidUsername('Player_01'), isTrue);
    expect(AuthValidators.isValidUsername('x'), isFalse);
    expect(AuthValidators.isValidPassword('123456'), isTrue);
    expect(AuthValidators.isValidPassword('123'), isFalse);
  });

  testWidgets('role select shows both entry buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RoleSelectScreen()));

    expect(find.text('Als Admin anmelden'), findsOneWidget);
    expect(find.text('Als Spieler anmelden'), findsOneWidget);
  });

  testWidgets('onboarding includes QR or teacher task explanation',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingFlow()));

    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();

    expect(find.textContaining('QR-Code'), findsOneWidget);
  });

  testWidgets('login validates missing password before backend call',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen(role: LoginRole.player)),
    );

    await tester.enterText(find.byType(TextField).first, 'spieler123');
    await tester.tap(find.text('Weiter'));
    await tester.pump();

    expect(find.textContaining('Bitte Passwort eingeben'), findsOneWidget);
  });

  testWidgets('create account validates password mismatch locally',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreateAccountScreen()));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'spieler_01');
    await tester.enterText(fields.at(1), 'spieler@example.com');
    await tester.enterText(fields.at(2), '123456');
    await tester.enterText(fields.at(3), '654321');
    await tester.tap(find.text('Weiter'));
    await tester.pump();

    expect(find.textContaining('Passwörter stimmen nicht überein'),
        findsOneWidget);
  });

  testWidgets('reset password validates empty input locally', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ChangePasswordScreen(role: LoginRole.player)),
    );

    await tester.tap(find.text('Weiter'));
    await tester.pump();

    expect(find.textContaining('Bitte Username oder E-Mail eingeben'),
        findsOneWidget);
  });
}
