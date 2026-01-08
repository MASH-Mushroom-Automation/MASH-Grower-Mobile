import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/registration_flow_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/widgets/offline_indicator.dart';
import 'core/services/offline_handler.dart';
import 'core/utils/logger.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _onboardingCompleted = false;
  bool _onboardingChecked = false;
  bool _showRegistrationAfterOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initializeOfflineHandler();
    _checkOnboardingStatus();
  }

  /// Initialize offline handler service
  Future<void> _initializeOfflineHandler() async {
    await OfflineHandler().initialize();
    Logger.info('Offline handler initialized');
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
        return const Column(
          children: [
            OfflineIndicator(),
            Expanded(child: HomeScreen()),
          ],
        );
      },
    );
  }
}
