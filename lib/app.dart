import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'core/utils/logger.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  bool _onboardingCompleted = false;
  bool _onboardingChecked = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _listenToConnectivityChanges();
    _checkOnboardingStatus();
  }

  void _checkConnectivity() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    setState(() {
      _isOnline = !connectivityResults.contains(ConnectivityResult.none);
    });
  }

  void _listenToConnectivityChanges() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      setState(() {
        _isOnline = !results.contains(ConnectivityResult.none);
      });
      Logger.info('Connectivity changed: ${results.map((r) => r.name).join(', ')}');
    });
  }

  void _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;
    setState(() {
      _onboardingCompleted = completed;
      _onboardingChecked = true;
    });
  }

  void _completeOnboarding() {
    setState(() {
      _onboardingCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only show splash screen during initial loading (onboarding check)
    if (!_onboardingChecked) {
      return const SplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Don't show splash screen during login attempts
        // Only show it during initial auth check
        // (isLoading will be true briefly during login, but we don't want splash then)

        if (!_onboardingCompleted) {
          return OnboardingScreen(onCompleted: _completeOnboarding);
        }

        // Show login screen if not authenticated
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Show main app with offline indicator
        return Stack(
          children: [
            const HomeScreen(),
            if (!_isOnline)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Offline Mode',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
