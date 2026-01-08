import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../../core/services/biometric_service.dart';
import '../../../core/services/session_manager.dart';
import '../../../core/services/offline_handler.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/change_password_screen.dart';
import '../profile/personal_information_screen.dart';
import '../settings/notifications_screen.dart';
import '../support/help_support_screen.dart';
import '../support/terms_conditions_screen.dart';
import '../support/privacy_policy_screen.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final BiometricService _biometricService = BiometricService();
  final SessionManager _sessionManager = SessionManager();
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _hasBiometricHardware = false;
  String _biometricType = '';

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    try {
      // Get all biometric status information
      final isAvailable = await _biometricService.canCheckBiometrics();
      final isEnabled = await _biometricService.isBiometricEnabled();
      final types = await _biometricService.getAvailableBiometrics();
      final hasHardware = await _biometricService.isDeviceSupported();
      
      // Debug logging
      print('🔐 Biometric Detection Debug:');
      print('  - canCheckBiometrics: $isAvailable');
      print('  - isDeviceSupported: $hasHardware');
      print('  - getAvailableBiometrics: $types');
      print('  - Currently enabled: $isEnabled');
      
      final typeDescription = types.isNotEmpty 
          ? await _biometricService.getBiometricDescription()
          : 'Biometric';
      
      // Biometrics are available if we can check them OR device supports them
      // Some Android devices return empty list from getAvailableBiometrics but still work
      final biometricsAvailable = isAvailable || hasHardware;
      
      if (mounted) {
        setState(() {
          _isBiometricAvailable = biometricsAvailable;
          _isBiometricEnabled = isEnabled;
          _biometricType = typeDescription;
          _hasBiometricHardware = hasHardware;
        });
        
        print('  - Final availability: $biometricsAvailable');
      }
    } catch (e) {
      print('❌ Error checking biometric status: $e');
      if (mounted) {
        setState(() {
          _isBiometricAvailable = false;
          _isBiometricEnabled = false;
          _biometricType = 'Biometric';
          _hasBiometricHardware = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Settings Sections
            _buildSettingsSection(
              context,
              title: 'Account Settings',
              items: [
                _SettingsItem(
                  icon: Icons.badge_outlined,
                  title: 'Personal Information',
                  subtitle: 'View your profile and devices',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PersonalInformationScreen()),
                    );
                  },
                ),
                _SettingsItem(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    );
                  },
                ),
                _SettingsItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Security Settings Section
            _buildSettingsSection(
              context,
              title: 'Security',
              items: [
                if (_isBiometricAvailable)
                  _SettingsItem(
                    icon: Icons.fingerprint,
                    title: '$_biometricType Authentication',
                    subtitle: _isBiometricEnabled ? 'Enabled' : 'Disabled',
                    trailing: Switch(
                      value: _isBiometricEnabled,
                      onChanged: (value) async {
                        if (value) {
                          // Enabling biometric authentication
                          final success = await _biometricService.enableBiometricAuth(
                            reason: 'Enable $_biometricType authentication for quick login',
                          );
                          
                          if (success) {
                            await _checkBiometricStatus();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$_biometricType authentication enabled. Login with password once to complete setup.'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          } else {
                            // Authentication failed or cancelled
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to enable $_biometricType authentication. Please make sure biometric authentication is set up on your device.'),
                                  backgroundColor: Colors.orange,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          }
                        } else {
                          // Disabling biometric authentication
                          await _biometricService.disableBiometricAuth();
                          await _checkBiometricStatus();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$_biometricType authentication disabled and credentials cleared'),
                              ),
                            );
                          }
                        }
                      },
                      activeColor: const Color(0xFF2D5F4C),
                    ),
                    onTap: null, // Disable tap since switch handles it
                  ),
                // Debug info for biometric status (only in debug mode)
                if (kDebugMode)
                  _SettingsItem(
                    icon: Icons.bug_report,
                    title: 'Biometric Debug Info',
                    subtitle: 'Tap to see detailed detection info',
                    trailing: Icon(Icons.info_outline, color: Colors.blue),
                    onTap: () async {
                      final types = await _biometricService.getAvailableBiometrics();
                      final canCheck = await _biometricService.canCheckBiometrics();
                      final supported = await _biometricService.isDeviceSupported();
                      
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Biometric Detection Info'),
                            content: Text(
                              'canCheckBiometrics: $canCheck\n'
                              'isDeviceSupported: $supported\n'
                              'getAvailableBiometrics: $types\n'
                              '\n'
                              'Available: $_isBiometricAvailable\n'
                              'Hardware: $_hasBiometricHardware\n'
                              'Enabled: $_isBiometricEnabled\n'
                              'Type: $_biometricType'
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                _SettingsItem(
                  icon: Icons.timer,
                  title: 'Session Timeout',
                  subtitle: 'Auto-logout after 30 minutes of inactivity',
                  onTap: () {
                    _showSessionTimeoutInfo(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildSettingsSection(
              context,
              title: 'Device Settings',
              items: [
                _SettingsItem(
                  icon: Icons.devices,
                  title: 'My Devices',
                  subtitle: '1 device connected',
                  onTap: () {
                    // TODO: Navigate to devices
                  },
                ),
                _SettingsItem(
                  icon: Icons.wifi,
                  title: 'WiFi Connection',
                  subtitle: 'Manage device connections',
                  onTap: () {
                    // TODO: Navigate to WiFi settings
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // App Settings
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return _buildSettingsSection(
                  context,
                  title: 'App Settings',
                  items: [
                    _SettingsItem(
                      icon: Icons.cloud_off_outlined,
                      title: 'Offline Mode',
                      subtitle: OfflineHandler().isForcedOffline 
                          ? 'Enabled (Manual)' 
                          : OfflineHandler().isOnline 
                              ? 'Online' 
                              : 'Offline (Auto)',
                      trailing: Switch(
                        value: OfflineHandler().isForcedOffline,
                        onChanged: (value) async {
                          await OfflineHandler().setForcedOfflineMode(value);
                          setState(() {}); // Trigger rebuild
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value 
                                      ? 'Offline mode enabled. App will not connect to internet.' 
                                      : 'Offline mode disabled. App will connect when available.',
                                ),
                                backgroundColor: value ? Colors.orange : Colors.green,
                              ),
                            );
                          }
                        },
                        activeColor: const Color(0xFF2D5F4C),
                      ),
                      onTap: () {
                        _showOfflineModeInfo(context);
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'Theme',
                      subtitle: _getThemeModeText(themeProvider.themeMode),
                      onTap: () {
                        _showThemeDialog(context, themeProvider);
                      },
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildSettingsSection(
              context,
              title: 'Support',
              items: [
                _SettingsItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'FAQs and contact support',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                    );
                  },
                ),
                _SettingsItem(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
                    );
                  },
                ),
                _SettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                    );
                  },
                ),
                _SettingsItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'Version 1.0.0',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => _handleLogout(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2D5F4C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/mash-logo.png',
                height: 32,
              ),
            ),
            const SizedBox(width: 12),
            const Text('About MASH Grower'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MASH Grower',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5F4C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'MASH Grower is an IoT-based mushroom cultivation monitoring and automation system. Monitor temperature, humidity, CO2 levels, and control your growing environment from anywhere.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              '© 2025 MASH Grower\nAll rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5F4C),
              ),
            ),
          ),
          const Divider(height: 1),
          ...items.map((item) => _buildSettingsItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, _SettingsItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.icon,
                color: const Color(0xFF2D5F4C),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.trailing != null)
              item.trailing!
            else
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  void _showSessionTimeoutInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.timer, color: Color(0xFF2D5F4C)),
            SizedBox(width: 12),
            Text('Session Timeout'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Management',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your session will automatically expire after 30 minutes of inactivity for security purposes.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'ll receive a warning 5 minutes before expiration',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Benefits:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Protects your account from unauthorized access'),
            _buildBulletPoint('Automatically logs you out when idle'),
            _buildBulletPoint('Can be extended with a tap'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'System default';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              subtitle: const Text('Follow device settings'),
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

  void _showOfflineModeInfo(BuildContext context) {
    final handler = OfflineHandler();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              handler.isForcedOffline ? Icons.cloud_off : Icons.cloud_queue,
              color: const Color(0xFF2D5F4C),
            ),
            const SizedBox(width: 12),
            const Text('Offline Mode'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What is Offline Mode?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Offline mode lets you use the app without an internet connection. Your device data is cached locally and will sync when you\'re back online.',
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),
              const Divider(height: 24),
              const Text(
                'Features Available Offline:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildOfflineFeature('View cached sensor data'),
              _buildOfflineFeature('Control devices locally'),
              _buildOfflineFeature('Queue actions for later sync'),
              _buildOfflineFeature('View device history'),
              const Divider(height: 24),
              const Text(
                'Manual Offline Mode:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Toggle the switch to force offline mode even when internet is available. This is useful for:\n\n• Saving mobile data\n• Working in areas with poor connectivity\n• Testing offline functionality',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data will automatically sync when connection is restored.',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (handler.isForcedOffline)
            TextButton(
              onPressed: () {
                handler.setForcedOfflineMode(false);
                setState(() {});
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Offline mode disabled'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Go Online'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
}
