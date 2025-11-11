import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
                    Icons.privacy_tip,
                    color: Color(0xFF2D5F4C),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Privacy Matters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5F4C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last updated: January 21, 2025',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
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
              '1. Information We Collect',
              'We collect several types of information:\n\n**Personal Information:**\n• Name and contact details\n• Email address and phone number\n• Account credentials\n• Profile information\n\n**Device Data:**\n• Sensor readings (temperature, humidity, CO2)\n• Device status and performance metrics\n• Connection logs and timestamps\n• Device location and configuration\n\n**Usage Data:**\n• App interaction patterns\n• Feature usage statistics\n• Error logs and crash reports',
            ),

            _buildSection(
              '2. How We Use Your Information',
              'We use collected information to:\n\n• Provide and maintain our services\n• Monitor and control your IoT devices\n• Generate analytics and insights\n• Send notifications and alerts\n• Improve user experience\n• Provide customer support\n• Detect and prevent fraud\n• Comply with legal obligations',
            ),

            _buildSection(
              '3. Data Storage and Security',
              'We implement industry-standard security measures to protect your data:\n\n• Encrypted data transmission (SSL/TLS)\n• Secure cloud storage\n• Regular security audits\n• Access controls and authentication\n• Automated backups\n\nHowever, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.',
            ),

            _buildSection(
              '4. Data Sharing',
              'We do not sell your personal information. We may share data with:\n\n• Service providers who assist our operations\n• Analytics partners (anonymized data)\n• Legal authorities when required by law\n• Third parties with your explicit consent\n\nAll third parties are contractually obligated to protect your data.',
            ),

            _buildSection(
              '5. Your Rights',
              'You have the right to:\n\n• Access your personal data\n• Correct inaccurate information\n• Request data deletion\n• Export your data\n• Opt-out of marketing communications\n• Withdraw consent at any time\n\nTo exercise these rights, contact us at privacy@mashgrower.com',
            ),

            _buildSection(
              '6. Data Retention',
              'We retain your data for as long as:\n\n• Your account is active\n• Needed to provide services\n• Required by law\n• Necessary for legitimate business purposes\n\nWhen data is no longer needed, we securely delete or anonymize it.',
            ),

            _buildSection(
              '7. Cookies and Tracking',
              'We use cookies and similar technologies to:\n\n• Remember your preferences\n• Analyze app usage\n• Improve performance\n• Provide personalized content\n\nYou can control cookie settings through your device settings.',
            ),

            _buildSection(
              '8. Children\'s Privacy',
              'Our service is not intended for children under 13. We do not knowingly collect personal information from children. If you believe we have collected data from a child, please contact us immediately.',
            ),

            _buildSection(
              '9. International Data Transfers',
              'Your data may be transferred to and processed in countries other than the Philippines. We ensure appropriate safeguards are in place to protect your data in accordance with this privacy policy.',
            ),

            _buildSection(
              '10. Changes to Privacy Policy',
              'We may update this privacy policy periodically. We will notify you of significant changes via:\n\n• Email notification\n• In-app announcement\n• Updated "Last Modified" date\n\nContinued use after changes constitutes acceptance.',
            ),

            _buildSection(
              '11. Third-Party Services',
              'Our app may contain links to third-party services. We are not responsible for their privacy practices. We encourage you to review their privacy policies.',
            ),

            _buildSection(
              '12. Contact Us',
              'For privacy-related questions or concerns:\n\nEmail: privacy@mashgrower.com\nPhone: +63 966 775 1474\nAddress: Caloocan, Philippines',
            ),

            const SizedBox(height: 24),

            // Commitment Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D5F4C), Color(0xFF1E4034)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.shield,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'We are committed to protecting your privacy and ensuring the security of your personal information.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
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
      margin: const EdgeInsets.only(bottom: 16),
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
