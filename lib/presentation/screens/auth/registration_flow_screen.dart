import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/registration_provider.dart';
import 'registration_pages/email_page.dart';
import 'registration_pages/otp_verification_page.dart';
import 'registration_pages/profile_setup_page.dart';
import 'registration_pages/account_setup_page.dart';
import 'registration_pages/password_setup_page.dart';
import 'registration_pages/success_page.dart';

class RegistrationFlowScreen extends StatefulWidget {
  const RegistrationFlowScreen({super.key});

  @override
  State<RegistrationFlowScreen> createState() => _RegistrationFlowScreenState();
}

class _RegistrationFlowScreenState extends State<RegistrationFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < 5) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegistrationProvider(),
      child: PopScope(
        canPop: _currentPage == 0 || _currentPage == 5,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _currentPage > 0 && _currentPage < 5) {
            _goToPreviousPage();
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                EmailPage(onNext: _goToNextPage),
                OtpVerificationPage(
                  onNext: _goToNextPage,
                  onBack: _goToPreviousPage,
                ),
                ProfileSetupPage(
                  onNext: _goToNextPage,
                  onBack: _goToPreviousPage,
                ),
                AccountSetupPage(
                  onNext: _goToNextPage,
                  onBack: _goToPreviousPage,
                ),
                PasswordSetupPage(
                  onNext: _goToNextPage,
                  onBack: _goToPreviousPage,
                ),
                const SuccessPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
