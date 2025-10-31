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
import 'package:mash_grower_mobile/presentation/screens/auth/login_screen.dart';
import 'package:mash_grower_mobile/presentation/screens/auth/registration_pages/email_page.dart';
import 'package:mash_grower_mobile/presentation/screens/auth/registration_pages/password_setup_page.dart';
import 'package:mash_grower_mobile/presentation/screens/auth/registration_pages/profile_setup_page.dart';
import 'package:mash_grower_mobile/core/utils/validators.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('Complete authentication flow with validation', (WidgetTester tester) async {
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
      expect(find.text('MASH Grow'), findsOneWidget);

      // Wait for authentication check to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show login screen if not authenticated
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Login form validation integration', (WidgetTester tester) async {
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
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test email validation - empty email
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(find.text('Email is required'), findsOneWidget);

      // Test invalid email format
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(find.text('Please enter a valid email address'), findsOneWidget);

      // Test valid email but empty password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(find.text('Password is required'), findsOneWidget);

      // Test email normalization
      await tester.enterText(find.byType(TextFormField).first, 'PP.NAMIAS@GMAIL.COM');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Note: In a real test, you'd mock the authentication and verify the normalized email was used
    });

    testWidgets('Registration flow validation integration', (WidgetTester tester) async {
      // Test Email Page
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: MaterialApp(
            home: EmailPage(
              onNext: () {}, // Mock callback
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test empty email validation
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Email is required'), findsOneWidget);

      // Test invalid email
      await tester.enterText(find.byType(TextFormField), 'invalid-email');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Please enter a valid email address'), findsOneWidget);

      // Test valid email
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      // Should proceed to next step (in real app, this would navigate)
    });

    testWidgets('Password setup validation integration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: MaterialApp(
            home: PasswordSetupPage(
              onNext: () {}, // Mock callback
              onBack: () {}, // Mock callback
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test password requirements
      await tester.enterText(find.byType(TextFormField).first, 'weak');
      await tester.enterText(find.byType(TextFormField).last, 'weak');
      await tester.tap(find.text('Continue'));
      await tester.pump();

      // Should show password strength errors
      expect(find.textContaining('Password must be at least 8 characters'), findsOneWidget);

      // Test password mismatch
      await tester.enterText(find.byType(TextFormField).first, 'StrongPass123!');
      await tester.enterText(find.byType(TextFormField).last, 'DifferentPass123!');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);

      // Test valid passwords
      await tester.enterText(find.byType(TextFormField).first, 'StrongPass123!');
      await tester.enterText(find.byType(TextFormField).last, 'StrongPass123!');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      // Should proceed (in real app, this would navigate)
    });

    testWidgets('Profile setup validation integration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: MaterialApp(
            home: ProfileSetupPage(
              onNext: () {}, // Mock callback
              onBack: () {}, // Mock callback
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test empty name validation
      await tester.tap(find.text('Complete Registration'));
      await tester.pump();
      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);

      // Test name length validation
      await tester.enterText(find.byType(TextFormField).first, 'A');
      await tester.enterText(find.byType(TextFormField).last, 'B');
      await tester.tap(find.text('Complete Registration'));
      await tester.pump();
      expect(find.text('First name must be at least 2 characters long'), findsOneWidget);
      expect(find.text('Last name must be at least 2 characters long'), findsOneWidget);

      // Test invalid characters
      await tester.enterText(find.byType(TextFormField).first, 'John123');
      await tester.enterText(find.byType(TextFormField).last, 'Doe456');
      await tester.tap(find.text('Complete Registration'));
      await tester.pump();
      expect(find.text('First name can only contain letters, spaces, hyphens, and apostrophes'), findsOneWidget);
      expect(find.text('Last name can only contain letters, spaces, hyphens, and apostrophes'), findsOneWidget);

      // Test valid names
      await tester.enterText(find.byType(TextFormField).first, 'John-Paul');
      await tester.enterText(find.byType(TextFormField).last, "O'Connor");
      await tester.tap(find.text('Complete Registration'));
      await tester.pump();
      // Should proceed (in real app, this would complete registration)
    });

    testWidgets('Email normalization across auth flow', (WidgetTester tester) async {
      // Test that email normalization works consistently across all auth screens
      final testEmails = [
        'PP.NAMIAS@GMAIL.COM',
        'Test.User@Example.Com',
        'user@domain.com',
      ];

      final expectedNormalized = [
        'pp.namias@gmail.com',
        'test.user@example.com',
        'user@domain.com',
      ];

      for (int i = 0; i < testEmails.length; i++) {
        expect(Validators.normalizeEmail(testEmails[i]), expectedNormalized[i]);
      }

      // Test in AuthProvider context
      // Mock the email normalization in auth methods
      // In a real test, you'd mock Firebase and verify the normalized email is sent
      final normalizedEmail = Validators.normalizeEmail('MIXED.CASE@EXAMPLE.COM');
      expect(normalizedEmail, 'mixed.case@example.com');
    });
  });
}
