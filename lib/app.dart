import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/registration_flow_screen.dart';
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
  bool _showRegistrationAfterOnboarding = false;

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
    final skipToLogin = prefs.getBool('skip_to_login') ?? false;
    
    setState(() {
      _onboardingCompleted = completed;
      _onboardingChecked = true;
      _showRegistrationAfterOnboarding = completed && !skipToLogin;
    });
    
    // Clear the skip_to_login flag after use
    if (skipToLogin) {
      await prefs.remove('skip_to_login');
    }
  }

  void _completeOnboarding() {
    setState(() {
      _onboardingCompleted = true;
      _showRegistrationAfterOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_onboardingChecked) {
      return const SplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show splash screen while checking authentication
        if (authProvider.isLoading) {
          return const SplashScreen();
        }

        if (!_onboardingCompleted) {
          return OnboardingScreen(onCompleted: _completeOnboarding);
        }

        // Show registration screen after onboarding completion
        if (_showRegistrationAfterOnboarding && !authProvider.isAuthenticated) {
          return RegistrationFlowScreen(
            onNavigateToLogin: () {
              setState(() {
                _showRegistrationAfterOnboarding = false;
              });
            },
          );
        }

        // Show login screen if not authenticated
        if (!authProvider.isAuthenticated) {
          return LoginScreen(
            onNavigateToRegistration: () {
              setState(() {
                _showRegistrationAfterOnboarding = true;
              });
            },
          );
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
