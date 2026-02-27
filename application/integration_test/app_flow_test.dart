import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:application/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots and shows entry flow', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // App brand should be visible on splash/auth entry points.
    expect(find.text('GeoQuest'), findsWidgets);
  });
}
