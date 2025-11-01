import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mash_grower_mobile/firebase_options.dart';
import 'package:mash_grower_mobile/main.dart';
import 'package:mash_grower_mobile/presentation/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Simplified startup test', (WidgetTester tester) async {
    debugPrint("--- Starting simplified startup test ---");

    // Ensure a clean state
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint("SharedPreferences cleared.");

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized.");

    // Pump the main app widget
    await tester.pumpWidget(const MASHGrowerApp());
    debugPrint("App widget pumped.");

    // Wait for all frames to settle
    await tester.pumpAndSettle(const Duration(seconds: 5));
    debugPrint("Pump and settle completed.");

    // The first screen should be the OnboardingScreen. Let's skip it.
    final skipButton = find.byKey(const Key('skip_onboarding_button'));
    if (tester.any(skipButton)) {
      debugPrint("Onboarding screen found, tapping skip.");
      await tester.tap(skipButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } else {
      debugPrint("Onboarding screen not found. This is unexpected for a clean run.");
      debugDumpApp();
    }

    // After skipping onboarding, LoginScreen should be visible.
    debugPrint("Checking for LoginScreen.");
    expect(find.byType(LoginScreen), findsOneWidget,
        reason: 'Expected to find the LoginScreen after skipping onboarding');
    debugPrint("LoginScreen found successfully.");
    debugPrint("--- Simplified startup test finished ---");
  });
}
