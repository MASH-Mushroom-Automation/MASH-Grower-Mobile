import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../../../widgets/common/validated_text_field.dart';
import '../../../providers/registration_provider.dart';
import '../../../widgets/registration/registration_step_indicator.dart';

class ProfileSetupPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ProfileSetupPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    // Load existing data from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RegistrationProvider>();
      _firstNameController.text = provider.firstName;
      _lastNameController.text = provider.lastName;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<RegistrationProvider>();
    provider.setFirstName(_firstNameController.text.trim());
    provider.setLastName(_lastNameController.text.trim());

    widget.onNext();
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
                currentStep: 1,
                stepLabels: ['Email', 'Profile', 'Account', 'Password', 'Review'],
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

 

              // First Name
              ValidatedTextField(
                key: const Key('registration_firstname_field'),
                controller: _firstNameController,
                label: 'First Name',
                hintText: 'Enter your first name',
                validator: (value) => Validators.validateName(value, 'First name'),
                prefixIcon: const Icon(Icons.person_outline),
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 20),

              // Last Name
              ValidatedTextField(
                key: const Key('registration_lastname_field'),
                controller: _lastNameController,
                label: 'Last Name',
                hintText: 'Enter your last name',
                validator: (value) => Validators.validateName(value, 'Last name'),
                prefixIcon: const Icon(Icons.person_outline),
                textCapitalization: TextCapitalization.words,
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.3),

              // Navigation Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onBack,
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
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5F4C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
