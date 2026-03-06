import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:application/screens/role_select_screen.dart';

void main() {
  testWidgets('role select shows both entry buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RoleSelectScreen()));

    expect(find.text('Als Admin anmelden'), findsOneWidget);
    expect(find.text('Als Spieler anmelden'), findsOneWidget);
  });
}
