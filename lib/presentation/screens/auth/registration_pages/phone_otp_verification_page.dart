import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/registration_provider.dart';
import '../../../widgets/registration/registration_step_indicator.dart';

class PhoneOtpVerificationPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const PhoneOtpVerificationPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<PhoneOtpVerificationPage> createState() => _PhoneOtpVerificationPageState();
}

class _PhoneOtpVerificationPageState extends State<PhoneOtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _startOtpTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startOtpTimer() {
    final provider = context.read<RegistrationProvider>();
    provider.startOtpTimer();
  }

  void _resendOtp() {
    final provider = context.read<RegistrationProvider>();
    provider.resetOtpTimer();
    provider.startOtpTimer();

    // TODO: Implement actual SMS sending
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent to your phone number')),
    );
  }

  void _verifyOtp() {
    final provider = context.read<RegistrationProvider>();
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length == 6) {
      // TODO: Implement actual OTP verification
      provider.setPhoneOtpVerified(true);
      widget.onNext();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete OTP')),
      );
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-verify when all digits are entered
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Step Indicator
            RegistrationStepIndicatorWithLabels(
              currentStep: 2,
              stepLabels: ['Verify Email', 'Profile', 'Phone Verify', 'Account', 'Password'],
            ),

            const SizedBox(height: 40),

            // Title
            Text(
              'Verify Phone Number',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D5F4C),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Enter the 6-digit code sent to',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              '${provider.countryCode}${provider.contactNumber}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D5F4C),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return Container(
                  width: 52,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _otpControllers[index].text.isNotEmpty
                          ? const Color(0xFF2D5F4C)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: TextFormField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5F4C),
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    onChanged: (value) => _onOtpChanged(value, index),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Timer and Resend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Resend code in ',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  provider.otpTimer > 0 ? '${provider.otpTimer}s' : '00s',
                  style: const TextStyle(
                    color: Color(0xFF2D5F4C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Resend Button
            if (provider.otpTimer == 0)
              TextButton(
                onPressed: _resendOtp,
                child: const Text(
                  'Resend Code',
                  style: TextStyle(
                    color: Color(0xFF2D5F4C),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),

            const SizedBox(height: 40),

            // Continue Button
            ElevatedButton(
              onPressed: _verifyOtp,
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
                'Verify & Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Back Button
            OutlinedButton(
              onPressed: widget.onBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2D5F4C)),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Change Phone Number',
                style: TextStyle(
                  color: Color(0xFF2D5F4C),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Skip Option
            TextButton(
              onPressed: () {
                provider.setPhoneOtpVerified(false);
                widget.onNext();
              },
              child: Text(
                'Skip phone verification',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
