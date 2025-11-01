import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../../../widgets/common/validated_text_field.dart';
import '../../../providers/registration_provider.dart';
import '../../../widgets/registration/registration_step_indicator.dart';

class PasswordSetupPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const PasswordSetupPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<PasswordSetupPage> createState() => _PasswordSetupPageState();
}

class _PasswordSetupPageState extends State<PasswordSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Password requirements
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordRequirements);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordRequirements);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordRequirements() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<RegistrationProvider>();
    provider.setPassword(_passwordController.text);
    provider.setConfirmPassword(_confirmPasswordController.text);

    // Complete registration
    final success = await provider.completeRegistration();
    if (success && mounted) {
      widget.onNext();
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Step Indicator
              const RegistrationStepIndicatorWithLabels(
                currentStep: 3,
                stepLabels: ['Verify', 'Profile', 'Account', 'Password'],
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Create New Account',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D5F4C),
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Fill in your details to register your account',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Password
              Text(
                'Password',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
              ),
              const SizedBox(height: 8),
              // Password
              ValidatedTextField(
                key: const Key('registration_password_field'),
                controller: _passwordController,
                label: 'Password',
                hintText: 'Enter Password',
                obscureText: _obscurePassword,
                validator: Validators.validatePassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Confirm Password
              Text(
                'Confirm Password',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
              ),
              const SizedBox(height: 8),
              // Confirm Password
              ValidatedTextField(
                key: const Key('registration_confirm_password_field'),
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hintText: 'Enter Password',
                obscureText: _obscureConfirmPassword,
                validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Password Requirements
              _buildRequirement('At least 8 characters', _hasMinLength),
              const SizedBox(height: 8),
              _buildRequirement('At least one uppercase letter', _hasUppercase),
              const SizedBox(height: 8),
              _buildRequirement('At least one number', _hasNumber),

              const SizedBox(height: 32),

              // Terms and Conditions
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                  children: [
                    const TextSpan(text: 'By proceeding, you confirm that you have read and agreed to our '),
                    TextSpan(
                      text: 'Terms and Policies',
                      style: TextStyle(
                        color: const Color(0xFF2D5F4C),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.1),

              // Navigation Buttons
              Consumer<RegistrationProvider>(
                builder: (context, provider, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: provider.isLoading ? null : widget.onBack,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 56),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _handleNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D5F4C),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          size: 20,
          color: isMet ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isMet ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
