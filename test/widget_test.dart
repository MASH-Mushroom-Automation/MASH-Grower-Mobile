import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mash_grower_mobile/main.dart';
import 'package:mash_grower_mobile/presentation/providers/auth_provider.dart';
import 'package:mash_grower_mobile/presentation/providers/sensor_provider.dart';
import 'package:mash_grower_mobile/presentation/providers/device_provider.dart';
import 'package:mash_grower_mobile/presentation/providers/notification_provider.dart';
import 'package:mash_grower_mobile/presentation/providers/theme_provider.dart';

void main() {
  group('MASH Grower App Widget Tests', () {
    testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
      // Build our app and trigger a frame.
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

      // Verify that the splash screen is shown
      expect(find.text('M.A.S.H. Grower'), findsOneWidget);
      expect(find.text('Smart Mushroom Growing'), findsOneWidget);
    });

    testWidgets('Login screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Welcome Back'),
                const Text('Sign in to your M.A.S.H. account'),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                  ),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  ),
                  obscureText: true,
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify login form elements
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to your M.A.S.H. account'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Home screen navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Center(child: Text('Dashboard')),
            bottomNavigationBar: NavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.device_hub_outlined),
                  selectedIcon: Icon(Icons.device_hub),
                  label: 'Devices',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_outlined),
                  selectedIcon: Icon(Icons.notifications),
                  label: 'Alerts',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outlined),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      // Verify navigation elements
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.byIcon(Icons.device_hub_outlined), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
    });
  });
}