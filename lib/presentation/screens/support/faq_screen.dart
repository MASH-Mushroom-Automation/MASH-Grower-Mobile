import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Getting Started',
    'Device Setup',
    'Troubleshooting',
    'Account',
    'Features',
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'category': 'Getting Started',
      'question': 'How do I connect my MASH device?',
      'answer': 'To connect your MASH device:\n\n1. Power on the device and wait for the WiFi indicator to blink\n2. Open the MASH Grower app and tap "Connect Device"\n3. Select your device from the list\n4. Choose your home WiFi network and enter the password\n5. Wait for the connection to complete\n\nThe device will automatically connect to your WiFi and you can start monitoring!',
    },
    {
      'category': 'Getting Started',
      'question': 'What do I need to get started?',
      'answer': 'To get started with MASH Grower, you need:\n\n• A MASH IoT device\n• A smartphone or tablet\n• WiFi connection (2.4GHz recommended)\n• The MASH Grower mobile app\n• A registered account',
    },
    {
      'category': 'Device Setup',
      'question': 'Why can\'t I find my device during setup?',
      'answer': 'If you can\'t find your device:\n\n1. Make sure the device is powered on\n2. Check if the WiFi indicator is blinking (setup mode)\n3. Ensure you\'re within range of the device\n4. Try restarting the device by unplugging and plugging it back in\n5. Make sure your phone\'s WiFi is enabled\n\nIf the problem persists, contact support.',
    },
    {
      'category': 'Device Setup',
      'question': 'Can I connect multiple devices?',
      'answer': 'Yes! You can connect multiple MASH devices to your account. Each device will appear in your "My Devices" section and you can monitor them all from a single dashboard.',
    },
    {
      'category': 'Troubleshooting',
      'question': 'My device shows as offline, what should I do?',
      'answer': 'If your device appears offline:\n\n1. Check if the device has power\n2. Verify your WiFi router is working\n3. Make sure the device is within WiFi range\n4. Try restarting the device\n5. Check if your WiFi password has changed\n\nYou can reconnect the device through Settings > WiFi Connection.',
    },
    {
      'category': 'Troubleshooting',
      'question': 'The sensor readings seem incorrect',
      'answer': 'If sensor readings appear incorrect:\n\n1. Wait a few minutes for sensors to stabilize\n2. Check if sensors are properly positioned\n3. Ensure sensors are clean and unobstructed\n4. Try restarting the device\n5. Calibrate sensors in device settings\n\nIf issues persist, the sensor may need replacement.',
    },
    {
      'category': 'Account',
      'question': 'How do I reset my password?',
      'answer': 'To reset your password:\n\n1. Go to the login screen\n2. Tap "Forgot Password?"\n3. Enter your registered email\n4. Check your email for the reset code\n5. Enter the code and create a new password\n\nMake sure to use a strong password with at least 8 characters.',
    },
    {
      'category': 'Account',
      'question': 'Can I use one account on multiple devices?',
      'answer': 'Yes! You can log in to your MASH Grower account on multiple phones or tablets. Your data and connected devices will sync across all devices.',
    },
    {
      'category': 'Features',
      'question': 'What is Chamber Mode?',
      'answer': 'Chamber Mode allows you to optimize conditions for different mushroom growth phases:\n\n• Spawning Phase: Maintains high CO2 levels (up to 5000ppm) with fans disabled\n• Fruiting Phase: Maintains optimal CO2 (300-800ppm) with active air circulation\n\nThe system automatically adjusts settings when you switch modes.',
    },
    {
      'category': 'Features',
      'question': 'How do I set up alerts?',
      'answer': 'Alerts are automatically configured based on your Chamber Mode:\n\n• Temperature alerts when outside optimal range\n• Humidity alerts for dry or too moist conditions\n• CO2 alerts based on current phase requirements\n• Battery alerts when power is low\n\nYou can customize alert thresholds in device settings.',
    },
    {
      'category': 'Features',
      'question': 'Can I control devices remotely?',
      'answer': 'Yes! As long as your device is connected to WiFi and online, you can:\n\n• Monitor real-time sensor data\n• Switch between chamber modes\n• Control actuators (fans, humidifier, LED)\n• View historical data and analytics\n\nAll from anywhere with internet connection.',
    },
  ];

  List<Map<String, dynamic>> get _filteredFAQs {
    if (_selectedCategory == 'All') {
      return _faqs;
    }
    return _faqs.where((faq) => faq['category'] == _selectedCategory).toList();
  }

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
          'Frequently Asked Questions',
          style: TextStyle(
            color: Color(0xFF2D5F4C),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: const Color(0xFF2D5F4C),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF2D5F4C),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // FAQ List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredFAQs.length,
              itemBuilder: (context, index) {
                final faq = _filteredFAQs[index];
                return _buildFAQCard(faq);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQCard(Map<String, dynamic> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D5F4C).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.help_outline,
              color: Color(0xFF2D5F4C),
              size: 20,
            ),
          ),
          title: Text(
            faq['question'],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5F4C),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              faq['category'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          children: [
            Text(
              faq['answer'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
