import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../../core/services/session_service.dart';
import '../address/address_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings not implemented yet')),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final user = authProvider.user!;

          return FutureBuilder<Map<String, dynamic>?>(
            future: _getRegistrationData(),
            builder: (context, snapshot) {
              final registrationData = snapshot.data;
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                // Profile Header - Horizontal Layout
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Avatar on the left
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF2D5F4C),
                          backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                              ? NetworkImage(user.profileImageUrl!)
                              : null,
                          onBackgroundImageError: user.profileImageUrl != null
                              ? (exception, stackTrace) {
                                  // Silently handle image load errors
                                }
                              : null,
                          child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        // Name and email in the middle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E2E2E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Edit button on the right
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade400, width: 1.5),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Colors.grey.shade700,
                              size: 20,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Edit profile not implemented yet')),
                              );
                            },
                            tooltip: 'Edit Profile',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Detailed Registration Information
                if (registrationData != null) ...[
                  // Debug information
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Debug: ${registrationData.toString()}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registration Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(context, 'Full Name', registrationData['firstName'] != null 
                            ? '${registrationData['prefix'] ?? ''} ${registrationData['firstName']} ${registrationData['middleName'] ?? ''} ${registrationData['lastName']} ${registrationData['suffix'] ?? ''}'.replaceAll(RegExp(r'\s+'), ' ').trim()
                            : 'Not provided'),
                          _buildInfoRow(context, 'Prefix', (registrationData['prefix'] ?? '').toString().isNotEmpty
                            ? registrationData['prefix']
                            : 'Not provided'),
                          _buildInfoRow(context, 'Suffix', (registrationData['suffix'] ?? '').toString().isNotEmpty
                            ? registrationData['suffix']
                            : 'Not provided'),
                          _buildInfoRow(context, 'Contact', (registrationData['contactNumber'] != null && registrationData['contactNumber'].toString().isNotEmpty)
                            ? '${registrationData['countryCode'] ?? '+63'}${registrationData['contactNumber']}'
                            : 'Not provided'),
                          _buildInfoRow(context, 'Username', registrationData['username'] ?? 'Not provided'),
                          _buildInfoRow(context, 'Region', registrationData['region'] ?? 'Not provided'),
                          _buildInfoRow(context, 'Province', registrationData['province'] ?? 'Not provided'),
                          _buildInfoRow(context, 'City', registrationData['city'] ?? 'Not provided'),
                          _buildInfoRow(context, 'Barangay', registrationData['barangay'] ?? 'Not provided'),
                          _buildInfoRow(context, 'Street', registrationData['streetAddress'] ?? 'Not provided'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Profile Options
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Edit Profile'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Edit profile
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit profile not implemented yet')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: const Text('My Addresses'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddressListScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.security_outlined),
                        title: const Text('Security'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Security settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Security settings not implemented yet')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined),
                        title: const Text('Notifications'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Notification settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notification settings not implemented yet')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Help & support
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Help & support not implemented yet')),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Theme Settings
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.dark_mode_outlined),
                            title: const Text('Theme'),
                            subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              _showThemeDialog(context, themeProvider);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Sign Out Button
                CustomButton(
                  text: 'Sign Out',
                  onPressed: () {
                    _showSignOutDialog(context, authProvider);
                  },
                  backgroundColor: Theme.of(context).colorScheme.error,
                  textColor: Colors.white,
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _getRegistrationData() async {
    final sessionService = SessionService();
    await sessionService.initialize();
    final data = await sessionService.getRegistrationData();
    print('🔍 Profile Screen - Retrieved registration data: $data');
    return data;
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              authProvider.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
