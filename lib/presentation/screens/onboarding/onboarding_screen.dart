import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/registration_flow_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Welcome to\nM.A.S.H. Grower',
      subtitle: 'Your Smart Mushroom\nFarming Companion',
      description: 'Transform your mushroom cultivation with cutting-edge technology and expert guidance.',
      backgroundColor: const Color(0xFFE8F5E8),
      textColor: const Color(0xFF2E7D32),
      showLogo: true,
      showImage: false,
    ),
    OnboardingPageData(
      title: 'Smart Monitoring',
      subtitle: 'Real-time Environmental Control',
      description: 'Monitor temperature, humidity, and CO₂ levels with precision sensors and automated alerts.',
      backgroundColor: const Color(0xFFFFF3E0),
      textColor: const Color(0xFFEF6C00),
      showLogo: false,
      showImage: true,
      imagePath: 'assets/designs/Onboarding/Onboard1.png',
    ),
    OnboardingPageData(
      title: 'Automated Systems',
      subtitle: 'Intelligent Growing Environment',
      description: 'Let our AI-powered system optimize conditions for maximum yield and quality.',
      backgroundColor: const Color(0xFFE3F2FD),
      textColor: const Color(0xFF1976D2),
      showLogo: false,
      showImage: true,
      imagePath: 'assets/designs/Onboarding/Onboard2.png',
    ),
    OnboardingPageData(
      title: 'Data Analytics',
      subtitle: 'Growth Insights & Reports',
      description: 'Track performance, analyze trends, and make data-driven decisions for better results.',
      backgroundColor: const Color(0xFFF3E5F5),
      textColor: const Color(0xFF7B1FA2),
      showLogo: false,
      showImage: true,
      imagePath: 'assets/designs/Onboarding/Onboard3.png',
    ),
    OnboardingPageData(
      title: 'Expert Support',
      subtitle: '24/7 Guidance & Community',
      description: 'Access expert advice, connect with fellow growers, and get support whenever you need it.',
      backgroundColor: const Color(0xFFFFEBEE),
      textColor: const Color(0xFFC62828),
      showLogo: false,
      showImage: true,
      imagePath: 'assets/designs/Onboarding/Onboard4.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegistrationFlowScreen()),
      );
    }
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegistrationFlowScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                data: _pages[index],
                pageIndex: index,
                totalPages: _pages.length,
              );
            },
          ),
          // Skip button (only show after first page)
          if (_currentPage > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 24,
              child: TextButton(
                onPressed: _skipOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: _pages[_currentPage].textColor,
                  backgroundColor: _pages[_currentPage].textColor.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigation(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page indicators
          _buildPageIndicators(),
          const SizedBox(height: 32),
          // Action button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _currentPage == _pages.length - 1
                  ? _completeOnboarding
                  : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _pages[_currentPage].textColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentPage
                ? _pages[_currentPage].textColor
                : _pages[_currentPage].textColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final int pageIndex;
  final int totalPages;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.pageIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: data.backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo for first page
              if (data.showLogo) ...[
                Image.asset(
                  'assets/images/mash-logo.png',
                  height: 80,
                  color: data.textColor,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.eco,
                      size: 80,
                      color: data.textColor,
                    );
                  },
                ),
                const SizedBox(height: 48),
              ],
              // Image for other pages
              if (data.showImage && data.imagePath != null) ...[
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Image.asset(
                      data.imagePath!,
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height * 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ] else ...[
                const Spacer(flex: 2),
              ],
              // Title
              Text(
                data.title,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: data.textColor,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                data.subtitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: data.textColor.withValues(alpha: 0.8),
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                data.description,
                style: TextStyle(
                  fontSize: 16,
                  color: data.textColor.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String description;
  final Color backgroundColor;
  final Color textColor;
  final bool showLogo;
  final bool showImage;
  final String? imagePath;

  OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.backgroundColor,
    required this.textColor,
    required this.showLogo,
    required this.showImage,
    this.imagePath,
  });
}
