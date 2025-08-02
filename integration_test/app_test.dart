import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:product_manager_demo/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('app starts and displays home page', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify that the app starts successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Look for common UI elements that should be present
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('app displays content correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify that the app displays some content
      final textWidgets = find.byType(Text);
      expect(textWidgets.evaluate().length, greaterThan(0));
      
      // Look for images or icons
      final imageWidgets = find.byType(Image);
      final iconWidgets = find.byType(Icon);
      
      // At least some visual content should be present
      expect(
        imageWidgets.evaluate().length + iconWidgets.evaluate().length,
        greaterThan(0),
      );
    });

    testWidgets('app handles basic interactions without crashes', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test basic interactions like tapping buttons
      final buttonFinder = find.byType(ElevatedButton);
      final iconButtonFinder = find.byType(IconButton);
      final floatingActionButtonFinder = find.byType(FloatingActionButton);
      
      // If any interactive elements exist, test them
      if (buttonFinder.evaluate().isNotEmpty) {
        await tester.tap(buttonFinder.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      
      if (iconButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(iconButtonFinder.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      
      if (floatingActionButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(floatingActionButtonFinder.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });
}