import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Notification preferences
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;

  // Alert types
  bool _temperatureAlerts = true;
  bool _humidityAlerts = true;
  bool _co2Alerts = true;
  bool _deviceConnectionAlerts = true;
  bool _systemUpdates = true;
  bool _maintenanceReminders = false;

  // Sound and vibration
  bool _notificationSound = true;
  bool _notificationVibration = true;
  String _soundVolume = 'Medium';

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
          'Notification Settings',
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
            // General Settings Section
            const Text(
              'General Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5F4C),
              ),
            ),
            const SizedBox(height: 12),

            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                subtitle: 'Receive notifications on your device',
                value: _pushNotificationsEnabled,
                onChanged: (value) => setState(() => _pushNotificationsEnabled = value),
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.email,
                title: 'Email Notifications',
                subtitle: 'Receive alerts via email',
                value: _emailNotificationsEnabled,
                onChanged: (value) => setState(() => _emailNotificationsEnabled = value),
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.sms,
                title: 'SMS Notifications',
                subtitle: 'Receive critical alerts via SMS',
                value: _smsNotificationsEnabled,
                onChanged: (value) => setState(() => _smsNotificationsEnabled = value),
              ),
            ]),

            const SizedBox(height: 24),

            // Alert Types Section
            const Text(
              'Alert Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5F4C),
              ),
            ),
            const SizedBox(height: 12),

            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.thermostat,
                title: 'Temperature Alerts',
                subtitle: 'Notifications for temperature changes',
                value: _temperatureAlerts,
                onChanged: (value) => setState(() => _temperatureAlerts = value),
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.water_drop,
                title: 'Humidity Alerts',
                subtitle: 'Notifications for humidity changes',
                value: _humidityAlerts,
                onChanged: (value) => setState(() => _humidityAlerts = value),
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.cloud,
                title: 'CO2 Level Alerts',
                subtitle: 'Notifications for CO2 level changes',
                value: _co2Alerts,
                onChanged: (value) => setState(() => _co2Alerts = value),
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.wifi,
                title: 'Device Connection',
                subtitle: 'Notifications for device connectivity',
                value: _deviceConnectionAlerts,
                onChanged: (value) => setState(() => _deviceConnectionAlerts = value),
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.system_update,
                title: 'System Updates',
                subtitle: 'Notifications for firmware updates',
                value: _systemUpdates,
                onChanged: (value) => setState(() => _systemUpdates = value),
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.build,
                title: 'Maintenance Reminders',
                subtitle: 'Regular maintenance notifications',
                value: _maintenanceReminders,
                onChanged: (value) => setState(() => _maintenanceReminders = value),
              ),
            ]),

            const SizedBox(height: 24),

            // Sound & Vibration Section
            const Text(
              'Sound & Vibration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5F4C),
              ),
            ),
            const SizedBox(height: 12),

            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.volume_up,
                title: 'Notification Sound',
                subtitle: 'Play sound for notifications',
                value: _notificationSound,
                onChanged: (value) => setState(() => _notificationSound = value),
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.vibration,
                title: 'Vibration',
                subtitle: 'Vibrate for notifications',
                value: _notificationVibration,
                onChanged: (value) => setState(() => _notificationVibration = value),
              ),
              const Divider(height: 1),
              _buildDropdownTile(
                icon: Icons.volume_down,
                title: 'Sound Volume',
                value: _soundVolume,
                options: ['Low', 'Medium', 'High'],
                onChanged: (value) => setState(() => _soundVolume = value!),
              ),
            ]),

            const SizedBox(height: 24),

            // Quiet Hours Section
            const Text(
              'Quiet Hours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5F4C),
              ),
            ),
            const SizedBox(height: 12),

            _buildSettingsCard([
              _buildTimeTile(
                icon: Icons.schedule,
                title: 'Do Not Disturb',
                subtitle: 'Set quiet hours for notifications',
                onTap: () => _showQuietHoursDialog(),
              ),
            ]),

            const SizedBox(height: 24),

            // Test Notification
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _sendTestNotification,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2D5F4C)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Send Test Notification',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D5F4C),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2D5F4C).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF2D5F4C), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: const Color(0xFF2D5F4C),
        activeColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2D5F4C).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF2D5F4C), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildTimeTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2D5F4C).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF2D5F4C), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showQuietHoursDialog() {
    TimeOfDay startTime = const TimeOfDay(hour: 22, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 8, minute: 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Quiet Hours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(startTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: startTime,
                );
                if (time != null) {
                  setState(() => startTime = time);
                }
              },
            ),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(endTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: endTime,
                );
                if (time != null) {
                  setState(() => endTime = time);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5F4C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _sendTestNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }
}
