import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/registration_provider.dart';
import 'registration_pages/email_page.dart';
import 'registration_pages/password_setup_page.dart';
import 'registration_pages/profile_setup_page.dart';
import 'registration_pages/account_setup_page.dart';
import 'registration_pages/review_submit_page.dart';
import 'registration_pages/otp_verification_page.dart';
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
    if (_currentPage < 6) { // Changed from 5 to 6 (7 pages total: 0-6)
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

  void _goToSpecificPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex <= 6) {
      setState(() {
        _currentPage = pageIndex;
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
        canPop: _currentPage == 0 || _currentPage == 6, // Changed from 5 to 6 (success page)
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _currentPage > 0 && _currentPage < 6) {
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

                //First page after email collection must be otp_verification_page.dart
                //OtpVerificationPage(
                 // onNext: _goToNextPage,
                 // onBack: _goToPreviousPage,
               // ),

                // Page 0: Email Collection
                EmailPage(onNext: _goToNextPage),
                
                // Page 1: Profile Setup
                  ProfileSetupPage(
                  onNext: _goToNextPage,
                  onBack: _goToPreviousPage,
                ),
                
                // Page 2: Account Setup (includes username)
              AccountSetupPage(
                  onNext: _goToNextPage,
                  onBack: _goToPreviousPage,
                ),
                
                // Page 3: Password Setup (address, etc.)
                 PasswordSetupPage(
                  onNext: _goToNextPage,
                  onBack: _goToPreviousPage,
                ),
                
                // Page 4: Review & Submit (NEW - sends data to backend)
                ReviewSubmitPage(
                  onNext: _goToNextPage,
                  onBack: _goToPreviousPage,
                  onEditStep: _goToSpecificPage,
                ),
                
                // Page 5: Email Verification (6-digit code)
                OtpVerificationPage(
                  onNext: _goToNextPage,
                  onBack: _goToPreviousPage,
                ),
                
                // Page 6: Success
                const SuccessPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
