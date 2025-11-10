import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingScreen({super.key, required this.onCompleted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _showInteractive = false; // show the in-page onboarding component
  int _stepIndex = 0; // 0..3

  // Removed direct complete helper; interactive flow will handle completion.

  @override
  Widget build(BuildContext context) {
    final textColor = const Color(0xFF2D5F4C);

    // topGroup: part1 (small text), part2 (logo/image), part3 (subtitle)
    final Widget topGroup = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Part 1 - small text
        Text(
          'Welcome to',
          style: TextStyle(
            fontSize: 14,
            color: textColor.withOpacity(0.85),
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        // Part 2 - logo image (use local logo if available)
        // Fall back to the design image if you prefer: assets/designs/Onboarding/Onboard1.png
        Center(
          child: Image.asset(
            'assets/images/mash-logo.png',
            width: MediaQuery.of(context).size.width * 0.5,
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 10),

        
      ],
    );

    // Show either the initial page or the interactive onboarding 'screen' inline
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: _showInteractive
              ? // Interactive onboarding shown as a full screen component (not modal)
              Column(
                  children: [
                    // PROGRESS BAR POSITION
                    // Adjust these margins to control top spacing
                    const SizedBox(height: 16),
                    
                    // Progress bar with connecting lines
                    SizedBox(
                      height: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Base horizontal line
                          Positioned(
                            left: 60,
                            right: 60,
                            child: Container(
                              height: 2,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          // Progress line overlay
                          Positioned(
                            left: 60,
                            right: 60,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: _stepIndex,
                                  child: Container(
                                    height: 2,
                                    color: const Color(0xFF1E4D2B),
                                  ),
                                ),
                                if (_stepIndex < 3)
                                  Expanded(
                                    flex: 3 - _stepIndex,
                                    child: Container(),
                                  ),
                              ],
                            ),
                          ),
                          // Progress circles
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (i) {
                              final bool active = i == _stepIndex;
                              final bool completed = i < _stepIndex;
                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: active ? 18 : 16,
                                    backgroundColor: completed || active 
                                        ? const Color(0xFF1E4D2B) 
                                        : Colors.grey.shade300,
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        color: completed || active 
                                            ? Colors.white 
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (i < 3) const SizedBox(width: 40),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Animated step content
                    Expanded(
                      child: Center(
                        child: _interactiveOnboardingCard(context, textColor),
                      ),
                    ),

                    // BUTTONS POSITION
                    // Adjust bottom spacing with this SizedBox
                    const SizedBox(height: 32),
                  ],
                )
              : // Initial non-interactive content (Start button shows interactive screen)
              Column(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: topGroup,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Your mushroom growing companion.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Take a quick look on our app!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                                setState(() {
                                  _showInteractive = true;
                                  _stepIndex = 0;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: textColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Start Onboarding',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
                
        ),
      ),
    );
  }

  // Interactive onboarding card widget
  Widget _interactiveOnboardingCard(BuildContext context, Color textColor) {
    // adjust container vertical alignment and padding here
    final double cardWidth = MediaQuery.of(context).size.width * 0.92;

    // step titles & descriptions
    const List<String> titles = [
      'Welcome to M.A.S.H.',
      'Monitor Your Farm',
      'Automate and Save',
      'Sell and Grow',
    ];

    const List<String> descriptions = [
      'Start smart farming. Track, control, and optimize your mushroom growth—right from your device.',
      'See real-time temperature, humidity, and pH data. Receive instant alerts for issues, including contamination risks.',
      'Let AI and IoT automate your farm. Save energy, reduce labor, and keep your harvest healthy.',
      'Use our e-commerce tools to sell mushrooms or order new cultivation kits. Grow from small to large-scale farming.',
    ];

    return Material(
      color: Colors.transparent,
      // use Material shape instead of Container decoration
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cardWidth),
        child: Padding(
          // adjust padding here (replaces Container padding)
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  // Fade + slide animation when moving between steps
                  final offsetAnim = Tween<Offset>(
                    begin: const Offset(0.2, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: offsetAnim,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Column(
                  key: ValueKey<int>(_stepIndex),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Content spacing and positioning can be adjusted here
                    const SizedBox(height: 32),
                    
                    Text(
                      titles[_stepIndex],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1E4D2B),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description: smaller gray text, centered below the title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        descriptions[_stepIndex],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

              const SizedBox(height: 24),

              // BUTTON SIZE & RADIUS
            // Adjust button height, width, and corner radius in the button styles below
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Left: Skip/Back (outlined)
                  Expanded(
                    child: SizedBox(
                      height: 48, // Standard button height
                      child: OutlinedButton(
                        onPressed: () async {
                          if (_stepIndex == 0) {
                            // Skip directly to login page
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('onboarding_completed', true);
                            widget.onCompleted();
                            return;
                          }
                          setState(() {
                            _stepIndex = (_stepIndex - 1).clamp(0, 3);
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFF1E4D2B), width: 1.5),
                        ),
                        child: Text(
                          _stepIndex == 0 ? 'Skip' : 'Back',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16), // Consistent spacing between buttons

                  // Right: Next/Register (filled green)
                  Expanded(
                    child: SizedBox(
                      height: 48, // Standard button height
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_stepIndex < 3) {
                            setState(() {
                              _stepIndex = (_stepIndex + 1).clamp(0, 3);
                            });
                          } else {
                            // Register: persist and proceed to registration/main app
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('onboarding_completed', true);
                            setState(() {
                              _showInteractive = false;
                            });
                            widget.onCompleted();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E4D2B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          _stepIndex < 3 ? 'Next' : 'Register',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // modify button width or spacing between them using margin or flex gap
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

