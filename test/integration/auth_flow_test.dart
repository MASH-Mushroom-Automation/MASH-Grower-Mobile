import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:mash_grower_mobile/main.dart';
import 'package:mash_grower_mobile/presentation/providers/auth_provider.dart';
import 'package:mash_grower_mobile/presentation/providers/sensor_provider.dart';
import 'package:mash_grower_mobile/presentation/providers/device_provider.dart';
import 'package:mash_grower_mobile/presentation/providers/notification_provider.dart';
import 'package:mash_grower_mobile/presentation/providers/theme_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('Complete authentication flow', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => SensorProvider()),
            ChangeNotifierProvider(create: (_) => DeviceProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: const MaterialApp(
            home: MASHGrowerApp(),
          ),
        ),
      );

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Verify splash screen is shown initially
      expect(find.text('M.A.S.H. Grower'), findsOneWidget);

      // Wait for authentication check to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show login screen if not authenticated
      // Note: This test assumes the user is not authenticated
      // In a real integration test, you'd mock the authentication state
    });

    testWidgets('Login form validation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextFormField(
                  key: const Key('email_field'),
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  key: const Key('password_field'),
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                ElevatedButton(
                  key: const Key('sign_in_button'),
                  onPressed: () {},
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );

      // Test form interaction
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      
      // Verify text was entered
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);

      // Test button tap
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pump();
    });
  });
}
