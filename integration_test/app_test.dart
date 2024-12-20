import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:project/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    setUpAll(() async {
      await Firebase.initializeApp();
    });

    Future<void> performLogin(WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'eslam@eslam.com'
      );
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          '123456789'
      );

      await tester.tap(find.text('Login'));

      // Wait for login and navigation to complete
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    }

    testWidgets('Home page navigation test', (tester) async {
      await performLogin(tester);

      // Verify initial home page state
      expect(find.text('Hedieaty Home'), findsOneWidget);

      // Test each navigation tab with proper delays and state settling
      final List<({IconData icon, Duration wait})> navigationSteps = [
        (icon: Icons.event, wait: const Duration(seconds: 1)),
        (icon: Icons.card_giftcard, wait: const Duration(seconds: 1)),
        (icon: Icons.person, wait: const Duration(seconds: 1)),
        (icon: Icons.home, wait: const Duration(seconds: 1)),
      ];

      for (final step in navigationSteps) {
        final iconFinder = find.byIcon(step.icon);
        expect(iconFinder, findsOneWidget);

        await tester.tap(iconFinder);
        await tester.pumpAndSettle();
        await Future.delayed(step.wait);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Basic UI elements visibility test', (tester) async {
      await performLogin(tester);
      await tester.pumpAndSettle();

      // Verify bottom navigation bar
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.event), findsOneWidget);
      expect(find.byIcon(Icons.card_giftcard), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    tearDownAll(() async {
      // Ensure cleanup of any remaining state
      await FirebaseAuth.instance.signOut();

      // Add a delay to allow for cleanup
      await Future.delayed(const Duration(seconds: 2));
    });
  });
}