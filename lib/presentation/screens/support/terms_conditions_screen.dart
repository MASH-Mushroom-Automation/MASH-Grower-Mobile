import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D5F4C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            color: Color(0xFF2D5F4C),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D5F4C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description,
                    color: Color(0xFF2D5F4C),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last Updated',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'October 21, 2025',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using the MASH Grower mobile application, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these Terms & Conditions, please do not use our services.',
            ),

            _buildSection(
              '2. Use License',
              'Permission is granted to temporarily use the MASH Grower application for personal, non-commercial use only. This license shall automatically terminate if you violate any of these restrictions and may be terminated by MASH Grower at any time.',
            ),

            _buildSection(
              '3. User Account',
              'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account. You must notify us immediately of any unauthorized use of your account.',
            ),

            _buildSection(
              '4. Device Connection',
              'The MASH Grower app allows you to connect and monitor IoT devices. You are responsible for:\n\n• Proper installation and setup of devices\n• Maintaining secure WiFi connections\n• Regular device maintenance\n• Ensuring devices are used according to manufacturer guidelines',
            ),

            _buildSection(
              '5. Data Collection and Usage',
              'We collect and process data from your connected devices including temperature, humidity, CO2 levels, and other sensor readings. This data is used to:\n\n• Provide monitoring and control features\n• Generate analytics and insights\n• Improve our services\n• Send relevant notifications and alerts',
            ),

            _buildSection(
              '6. Service Availability',
              'We strive to provide continuous service availability but do not guarantee uninterrupted access. We reserve the right to modify, suspend, or discontinue any part of the service with or without notice.',
            ),

            _buildSection(
              '7. Limitations of Liability',
              'MASH Grower shall not be liable for any damages arising from:\n\n• Device malfunction or failure\n• Loss of data or connectivity\n• Crop loss or damage\n• Inaccurate sensor readings\n• Service interruptions',
            ),

            _buildSection(
              '8. User Conduct',
              'You agree not to:\n\n• Use the service for any illegal purpose\n• Attempt to gain unauthorized access to our systems\n• Interfere with the proper working of the service\n• Upload malicious code or viruses\n• Violate any applicable laws or regulations',
            ),

            _buildSection(
              '9. Intellectual Property',
              'The service and its original content, features, and functionality are owned by MASH Grower and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.',
            ),

            _buildSection(
              '10. Termination',
              'We may terminate or suspend your account and access to the service immediately, without prior notice, for conduct that we believe violates these Terms & Conditions or is harmful to other users, us, or third parties.',
            ),

            _buildSection(
              '11. Changes to Terms',
              'We reserve the right to modify these terms at any time. We will notify users of any material changes via email or through the app. Your continued use of the service after such modifications constitutes acceptance of the updated terms.',
            ),

            _buildSection(
              '12. Governing Law',
              'These Terms shall be governed by and construed in accordance with the laws of the Republic of the Philippines, without regard to its conflict of law provisions.',
            ),

            _buildSection(
              '13. Contact Information',
              'If you have any questions about these Terms & Conditions, please contact us at:\n\nEmail: legal@mashgrower.com\nPhone: +63 123 456 7890',
            ),

            const SizedBox(height: 24),

            // Acceptance Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2D5F4C)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By using MASH Grower, you acknowledge that you have read and understood these terms and conditions.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5F4C),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
