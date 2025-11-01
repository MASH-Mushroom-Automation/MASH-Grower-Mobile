import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/registration_provider.dart';
import '../../../widgets/registration/registration_step_indicator.dart';

class ReviewSubmitPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(int) onEditStep; // Navigate to specific page for editing

  const ReviewSubmitPage({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onEditStep,
  });

  @override
  State<ReviewSubmitPage> createState() => _ReviewSubmitPageState();
}

class _ReviewSubmitPageState extends State<ReviewSubmitPage> {
  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<RegistrationProvider>();
      final success = await provider.submitRegistration();

      if (!mounted) return;

      if (success) {
        // Navigate to OTP verification page
        widget.onNext();
      } else if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer<RegistrationProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Step Indicator
                const RegistrationStepIndicatorWithLabels(
                  currentStep: 4,
                  stepLabels: ['Email', 'Password', 'Profile', 'Review', 'Verify'],
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Review Your Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Please review your information before submitting',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),

                const SizedBox(height: 32),

                // Account Information Card
                _buildSectionCard(
                  title: 'Account Information',
                  icon: Icons.account_circle,
                  children: [
                    _buildInfoRow('Email', provider.email, onEdit: () => widget.onEditStep(0)),
                    _buildInfoRow('Username', provider.username, onEdit: () => widget.onEditStep(2)),
                    _buildInfoRow('Password', '••••••••', onEdit: () => widget.onEditStep(1)),
                  ],
                ),

                const SizedBox(height: 16),

                // Personal Information Card
                _buildSectionCard(
                  title: 'Personal Information',
                  icon: Icons.person,
                  children: [
                    _buildInfoRow('First Name', provider.firstName, onEdit: () => widget.onEditStep(2)),
                    if (provider.middleName.isNotEmpty)
                      _buildInfoRow('Middle Name', provider.middleName, onEdit: () => widget.onEditStep(2)),
                    _buildInfoRow('Last Name', provider.lastName, onEdit: () => widget.onEditStep(2)),
                    if (provider.suffix.isNotEmpty)
                      _buildInfoRow('Suffix', provider.suffix, onEdit: () => widget.onEditStep(2)),
                  ],
                ),

                const SizedBox(height: 16),

                // Contact Information Card
                if (provider.contactNumber.isNotEmpty)
                  _buildSectionCard(
                    title: 'Contact Information',
                    icon: Icons.phone,
                    children: [
                      _buildInfoRow('Contact Number', provider.contactNumber, onEdit: () => widget.onEditStep(2)),
                    ],
                  ),

                const SizedBox(height: 32),

                // Privacy Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'By submitting, you agree to our Terms of Service and Privacy Policy. We will send a verification code to your email.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    // Back Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : widget.onBack,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFF8B4513)),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Submit Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B4513),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Submit Registration',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF8B4513), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {VoidCallback? onEdit}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2E2E2E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onEdit != null)
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.edit,
                  size: 18,
                  color: const Color(0xFF8B4513).withOpacity(0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
