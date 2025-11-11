import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/registration_provider.dart';
import '../../../providers/address_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../auth/login_screen.dart';
import '../../../../data/models/address/create_address_request_model.dart';
import '../../../../core/utils/logger.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  bool _isSavingAddress = false;

  @override
  void initState() {
    super.initState();
    _saveAddressIfAvailable();
  }

  Future<void> _saveAddressIfAvailable() async {
    final registrationProvider = context.read<RegistrationProvider>();
    final authProvider = context.read<AuthProvider>();
    
    // Check if user has complete address data and is authenticated
    if (registrationProvider.hasCompleteAddress() && authProvider.isAuthenticated) {
      setState(() => _isSavingAddress = true);
      
      try {
        final addressData = registrationProvider.getAddressData();
        final userId = authProvider.user?.id;
        
        if (userId != null) {
          Logger.info('📍 Saving address for new user: $userId');
          
          final addressProvider = AddressProvider();
          final request = CreateAddressRequestModel(
            street: addressData['street']!,
            city: addressData['city']!,
            state: addressData['state']!,
            zipCode: addressData['zipCode']!,
            country: addressData['country']!,
            isDefault: true,
          );
          
          await addressProvider.createAddress(userId, request);
          Logger.info('✅ Address saved successfully');
        }
      } catch (e) {
        Logger.error('❌ Failed to save address', e);
        // Don't block user from continuing even if address save fails
      } finally {
        if (mounted) {
          setState(() => _isSavingAddress = false);
        }
      }
    }
  }

  void _handleComplete(BuildContext context) {
    // Reset registration provider
    context.read<RegistrationProvider>().reset();
    
    // Navigate to login screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Success Icon
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2D5F4C),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D5F4C).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative background pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _SuccessBackgroundPainter(),
                        ),
                      ),
                      // Checkmark
                      const Center(
                        child: Icon(
                          Icons.check,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Success Message
              Text(
                'Account successfully\ncreated!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D5F4C),
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Welcome to MASH Grow!\nYou can now sign in to your account.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Complete Button
              ElevatedButton(
                onPressed: () => _handleComplete(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5F4C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Great!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for decorative background
class _SuccessBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9BC4A8).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Draw decorative scalloped edge pattern
    final path = Path();
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * 3.14159 / 180;
      final x = center.dx + radius * 0.9 * (1 + 0.15 * (i % 2)) * cos(angle);
      final y = center.dy + radius * 0.9 * (1 + 0.15 * (i % 2)) * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  double cos(double angle) => angle.cos();
  double sin(double angle) => angle.sin();

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on double {
  double cos() => this;
  double sin() => this;
}
