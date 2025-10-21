import 'package:flutter/material.dart';

import '../../../core/services/session_service.dart';
import '../../widgets/home/user_header.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import 'chamber_detail_screen.dart';
import 'user_settings_screen.dart';
import '../devices/wifi_device_connection_screen.dart';
import '../devices/devices_view_screen.dart';
import '../analytics/analytics_view_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  bool _hasDevice = false; // Toggle this to test different states
  bool _isConnecting = false;
  bool _isDeviceOn = true; // Device power state
  final SessionService _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _checkDeviceStatus();
  }

  void _checkDeviceStatus() {
    // TODO: Backend Integration - Check if user has connected devices
    // final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    // setState(() {
    //   _hasDevice = deviceProvider.devices.isNotEmpty;
    // });
  }

  void _handleConnect() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WiFiDeviceConnectionScreen()),
    );

    // After returning from connection screen, check if device was added
    setState(() {
      _hasDevice = true; // TODO: Check actual device status from backend
    });
  }

  void _handleAddNewDevice() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WiFiDeviceConnectionScreen()),
    );
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
              setState(() {
                _isDeviceOn = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Device turned off'),
                  backgroundColor: Colors.orange,
                ),
              );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // User Header
          UserHeader(
            userName: _sessionService.currentSession?.fullName ?? 'Guest',
            subtitle: _hasDevice
                ? 'You have 1 device actively monitoring'
                : 'Please connect your device first.',
            avatarUrl: _sessionService.currentSession?.profileImagePath,
            onNotificationTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          
          // Main Content
          Expanded(
            child: _currentNavIndex == 0
                ? (_hasDevice ? _buildDashboard() : _buildNoDeviceState())
                : _currentNavIndex == 1
                    ? _buildDevicesView()
                    : _currentNavIndex == 2
                        ? _buildAnalyticsView()
                        : const UserSettingsScreen(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chamber Status Overview Card
          Container(
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
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    // Energy Stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Energy Used',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '165 kWh',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D5F4C),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Energy Efficiency Target',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Reduce usage\nto 300 kWh',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D5F4C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Circular Progress
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: 0.45,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                          const Text(
                            '45%',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D5F4C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Sensor Status Grid - Improved UX with larger cards
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                  children: [
                    _buildSensorStatusCard(
                      icon: Icons.thermostat,
                      label: 'Temperature',
                      status: '1 Sensor active',
                    ),
                    _buildSensorStatusCard(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      status: '1 Sensor active',
                    ),
                    _buildSensorStatusCard(
                      icon: Icons.air,
                      label: 'Fan',
                      status: '1 Sensor active',
                    ),
                    // _buildSensorStatusCard(
                    //   icon: Icons.opacity,
                    //   label: 'Irrigation',
                    //   status: '1 Sensor active',
                    // ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Search Bar and Add New Button
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(Icons.search, color: Colors.grey.shade400),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Color(0xFF2D5F4C)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _handleAddNewDevice,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D5F4C),
                  side: const BorderSide(color: Color(0xFF2D5F4C)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add New'),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chamber 1',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D5F4C),
                              ),
                            ),
                            Text(
                              'ID: MASH-A1-CAL25-D5A91F',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isDeviceOn,
                        onChanged: (value) {
                          if (!value) {
                            _showDeviceToggleConfirmation();
                          } else {
                            setState(() {
                              _isDeviceOn = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Device turned on'),
                                backgroundColor: Colors.green,
                              ),
                            );
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
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF2D5F4C), size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5F4C),
            ),
          ),
          const SizedBox(height: 4),
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

  // Devices View
  Widget _buildDevicesView() {
    return const DevicesViewScreen();
  }

  // Analytics View
  Widget _buildAnalyticsView() {
    return const AnalyticsViewScreen();
  }
}
