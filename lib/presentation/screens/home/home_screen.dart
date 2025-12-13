import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/device_provider.dart';
import '../../widgets/home/user_header.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import 'chamber_detail_screen.dart';
import '../notifications/notifications_screen.dart';
import 'user_settings_screen.dart';
import '../devices/hybrid_device_connection_screen.dart';
import '../profile/profile_screen.dart';
import '../automation/ai_automation_screen.dart';
import '../analytics/analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  
  // Mock data - replace with actual data from backend
  bool _isConnecting = false;
  bool _isDeviceOn = true; // Device power state

  void _handleConnect() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HybridDeviceConnectionScreen()),
    );

    // Refresh UI after connection
    if (mounted) {
      setState(() {});
    }
  }

  void _handleAddNewDevice() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HybridDeviceConnectionScreen()),
    );
  }

  Future<void> _toggleDevice(bool turnOn) async {
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    final deviceId = deviceProvider.connectedDevice?.id;
    
    if (deviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No device connected'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      final success = await deviceProvider.toggleDeviceActivation(deviceId);
      
      if (success) {
        setState(() {
          _isDeviceOn = turnOn;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(turnOn ? 'Device turned on' : 'Device turned off'),
            backgroundColor: turnOn ? Colors.green : Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to toggle device'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _showDeviceToggleConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Turn Off Device?',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to turn off this device? This will stop all monitoring and control functions.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _toggleDevice(false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Turn Off'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // User Header
            Consumer<DeviceProvider>(
            builder: (context, deviceProvider, child) {
              return UserHeader(
                userName: user != null ? '${user.firstName} ${user.lastName}' : 'Guest',
                subtitle: deviceProvider.isConnected
                    ? 'You have 1 device actively monitoring'
                    : 'Please connect your device first.',
                avatarUrl: user?.profileImageUrl,
                onNotificationTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              );
            },
          ),
          
          // Main Content
          Expanded(
            child: Consumer<DeviceProvider>(
              builder: (context, deviceProvider, child) {
                final hasDevice = deviceProvider.isConnected;
                return _currentNavIndex == 0
                    ? (hasDevice ? _buildDashboard() : _buildNoDeviceState())
                    : _currentNavIndex == 1
                        ? (hasDevice ? const AIAutomationScreen() : _buildNoDeviceMessage('Automation'))
                        : _currentNavIndex == 2
                            ? (hasDevice ? const AnalyticsScreen() : _buildNoDeviceMessage('Analytics'))
                            : const UserSettingsScreen();
              },
            ),
          ),
        ],
        ),
      ),
      bottomNavigationBar: Consumer<DeviceProvider>(
        builder: (context, deviceProvider, child) {
          return BottomNavBar(
            currentIndex: _currentNavIndex,
            isDeviceConnected: deviceProvider.isConnected,
            onTap: (index) {
              setState(() {
                _currentNavIndex = index;
              });
            },
          );
        },
      ),
    );
  }

  // No Device State
  Widget _buildNoDeviceState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration (placeholder - you can add actual image)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.devices,
                size: 100,
                color: Color(0xFF2D5F4C),
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Start growing!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5F4C),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Please connect your Chamber.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isConnecting ? null : _handleConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5F4C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isConnecting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Connect',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dashboard State
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chamber Status Overview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D5F4C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bolt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Chamber Status Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5F4C),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    // Device Stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Device Status',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Color(0xFF4CAF50),
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Online',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D5F4C),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Active Sensors',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '3 Sensors\n4 Actuators',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D5F4C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status Icon
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 45,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Sensor Status Grid - responsive layout to avoid overflow
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Choose 2 columns on narrow widths, otherwise 3
                    final width = constraints.maxWidth;
                    final crossAxis = width < 600 ? 2 : 3;

                    // Estimate item size and compute a childAspectRatio that
                    // keeps cards a bit taller to avoid vertical overflow.
                    // use slightly smaller gaps to match design and calculate
                    // a compact card size
                    final spacing = 12 * (crossAxis - 1);
                    final itemWidth = (width - spacing) / crossAxis;
                    // target item height (approx) - increase to give room for 2-line subHeader
                    const itemHeight = 140.0;
                    final childAspectRatio = itemWidth / itemHeight;

                    return GridView.count(
                      crossAxisCount: crossAxis,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      // allow taller cards on narrow screens by lowering the clamp
                      childAspectRatio: childAspectRatio.clamp(0.5, 2.0),
                      children: [
                        _buildSensorStatusCard(
                          icon: Icons.thermostat,
                          label: 'Chamber Sensor',
                          subHeader: 'Temp. • Humidity • CO2',
                          status: '1 Sensor active',
                        ),
                        _buildSensorStatusCard(
                          icon: Icons.water_drop,
                          label: 'Humidifier',
                          status: '1 Sensor active',
                        ),
                        _buildSensorStatusCard(
                          icon: Icons.air,
                          label: 'Exhaust Fan',
                          status: '1 Sensor active',
                        ),
                        _buildSensorStatusCard(
                          icon: Icons.blur_on,
                          label: 'Blower Fan',
                          status: '1 Device active',
                        ),
                        // _buildSensorStatusCard(
                        //   icon: Icons.opacity,
                        //   label: 'Irrigation',
                        //   status: '1 Sensor active',
                        // ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Add Device Button
          OutlinedButton.icon(
            onPressed: _handleAddNewDevice,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2D5F4C),
              side: const BorderSide(color: Color(0xFF2D5F4C)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              minimumSize: const Size(double.infinity, 48),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Device'),
          ),
          
          const SizedBox(height: 16),
          
          // Chamber Card
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChamberDetailScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D5F4C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.device_hub,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Consumer<DeviceProvider>(
                          builder: (context, deviceProvider, child) {
                            final device = deviceProvider.connectedDevice;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device?.name ?? 'Chamber 1',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D5F4C),
                                  ),
                                ),
                                Text(
                                  'ID: ${device?.id ?? 'MASH-A1-CAL25-D5A91F'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Switch(
                        value: _isDeviceOn,
                        onChanged: _isConnecting ? null : (value) {
                          if (!value) {
                            _showDeviceToggleConfirmation();
                          } else {
                            _toggleDevice(true);
                          }
                        },
                        activeTrackColor: const Color(0xFF4CAF50),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isDeviceOn ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _isDeviceOn ? const Color(0xFF2D5F4C) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorStatusCard({
    required IconData icon,
    required String label,
    String? subHeader,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FBF3), // very light green background
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6F4EA)),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      // Let the content size naturally; reduce vertical padding and spacing
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2D5F4C), size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D5F4C),
            ),
          ),
            if (subHeader != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  subHeader,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          const SizedBox(height: 6),
          Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // No Device Message
  Widget _buildNoDeviceMessage(String feature) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.devices,
                size: 100,
                color: Color(0xFF2D5F4C),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Start growing!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5F4C),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please connect your Chamber.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isConnecting ? null : _handleConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5F4C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isConnecting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Connect',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Devices View
  Widget _buildDevicesView() {
    return const Center(
      child: Text('Devices View - Coming Soon'),
    );
  }

}
