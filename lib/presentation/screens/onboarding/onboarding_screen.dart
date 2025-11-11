import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingScreen({super.key, required this.onCompleted});

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
      description:
          'Transform your mushroom cultivation with cutting-edge technology and expert guidance.',
      backgroundColor: const Color(0xFFE8F5E8),
      textColor: const Color(0xFF2E7D32),
      showLogo: true,
      showImage: false,
    ),
    OnboardingPageData(
      title: 'Smart Monitoring',
      subtitle: 'Real-time Environmental Control',
      description:
          'Monitor temperature, humidity, and CO₂ levels with precision sensors and automated alerts.',
      backgroundColor: const Color(0xFFFFF3E0),
      textColor: const Color(0xFFEF6C00),
      showLogo: false,
      showImage: true,
      // imagePath: 'images/placeholders/800@2x.png',
    ),
    OnboardingPageData(
      title: 'Automated Systems',
      subtitle: 'Intelligent Growing Environment',
      description:
          'Let our AI-powered system optimize conditions for maximum yield and quality.',
      backgroundColor: const Color(0xFFE3F2FD),
      textColor: const Color(0xFF1976D2),
      showLogo: false,
      showImage: true,
      // imagePath: 'images/placeholders/800@2x.png',
    ),
    OnboardingPageData(
      title: 'Data Analytics',
      subtitle: 'Growth Insights & Reports',
      description:
          'Track performance, analyze trends, and make data-driven decisions for better results.',
      backgroundColor: const Color(0xFFF3E5F5),
      textColor: const Color(0xFF7B1FA2),
      showLogo: false,
      showImage: true,
      // imagePath: 'images/placeholders/800@2x.png',
    ),
    OnboardingPageData(
      title: 'Expert Support',
      subtitle: '24/7 Guidance & Community',
      description:
          'Access expert advice, connect with fellow growers, and get support whenever you need it.',
      backgroundColor: const Color(0xFFFFEBEE),
      textColor: const Color(0xFFC62828),
      showLogo: false,
      showImage: true,
      // imagePath: 'images/placeholders/800@2x.png',
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

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    widget.onCompleted();
  }

  void _skipToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    await prefs.setBool('skip_to_login', true);
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pages[_currentPage].backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    data: _pages[index],
                    currentPage: index,
                    totalPages: _pages.length,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "Already have an account?" link (only on last page)
                  if (_currentPage == _pages.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextButton(
                        onPressed: _skipToLogin,
                        child: Text(
                          'Already have an account? Login',
                          style: TextStyle(
                            color: _pages[_currentPage].textColor.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Opacity(
                        opacity: _currentPage > 0 ? 1.0 : 0.0,
                        child: TextButton(
                          key: const Key('skip_onboarding_button'),
                          onPressed: _completeOnboarding,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color:
                                  _pages[_currentPage].textColor.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? _pages[_currentPage].textColor
                                  : _pages[_currentPage]
                                      .textColor
                                      .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                      FloatingActionButton(
                        key: const Key('next_onboarding_button'),
                        onPressed: _currentPage == _pages.length - 1
                            ? _completeOnboarding
                            : _nextPage,
                        backgroundColor: _pages[_currentPage].textColor,
                        elevation: 0,
                        child: Icon(
                          _currentPage == _pages.length - 1
                              ? Icons.check
                              : Icons.arrow_forward_ios,
                          color: _pages[_currentPage].backgroundColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
    this.showLogo = false,
    this.showImage = false,
    this.imagePath,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final int currentPage;
  final int totalPages;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.showLogo)
            Center(
              child: Image.asset(
                'assets/images/mash-logo.png',
                height: 150,
              ),
            ),
          if (data.showImage && data.imagePath != null)
            Center(
              child: Image.asset(
                data.imagePath!,
                height: 250,
              ),
            ),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: data.textColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: data.textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: TextStyle(
              fontSize: 16,
              color: data.textColor.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
