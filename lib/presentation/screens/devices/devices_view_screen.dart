import 'package:flutter/material.dart';
import '../home/chamber_detail_screen.dart';
import 'wifi_device_connection_screen.dart';

class DevicesViewScreen extends StatefulWidget {
  const DevicesViewScreen({super.key});

  @override
  State<DevicesViewScreen> createState() => _DevicesViewScreenState();
}

class _DevicesViewScreenState extends State<DevicesViewScreen> {
  // Set to empty list to test no device state
  final List<Map<String, dynamic>> _devices = [
    {
      'id': 'MASH-A1-CAL25-D5A91F',
      'name': 'Chamber 1',
      'status': 'active',
      'location': 'Main Facility',
      'lastUpdate': '2 mins ago',
      'temperature': '31°C',
      'humidity': '54%',
      'co2': '400 ppm',
      'battery': '80%',
    },
    {
      'id': 'MASH-A2-CAL25-E6B92G',
      'name': 'Chamber 2',
      'status': 'inactive',
      'location': 'Secondary Facility',
      'lastUpdate': '1 hour ago',
      'temperature': '28°C',
      'humidity': '48%',
      'co2': '400 ppm',
      'battery': '80%',
    },
        {
      'id': 'MASH-A3-CAL25-E6B92G',
      'name': 'Chamber 3',
      'status': 'inactive',
      'location': 'Secondary Facility',
      'lastUpdate': '1 hour ago',
      'temperature': '28°C',
      'humidity': '48%',
      'co2': '400 ppm',
      'battery': '80%',
    },
        {
      'id': 'MASH-A4-CAL25-E6B92G',
      'name': 'Chamber 4',
      'status': 'inactive',
      'location': 'Secondary Facility',
      'lastUpdate': '1 hour ago',
      'temperature': '28°C',
      'humidity': '48%',
      'co2': '400 ppm',
      'battery': '80%',
    },
        {
      'id': 'MASH-A5-CAL25-E6B92G',
      'name': 'Chamber 5',
      'status': 'inactive',
      'location': 'Secondary Facility',
      'lastUpdate': '1 hour ago',
      'temperature': '28°C',
      'humidity': '48%',
      'co2': '400 ppm',
      'battery': '80%',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Show empty state if no devices
    if (_devices.isEmpty) {
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF2D5F4C),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Devices',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2D5F4C),
                      Color(0xFF1E4034),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // // Stats Cards
                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildStatCard(
                //         icon: Icons.devices,
                //         label: 'Total Devices',
                //         value: '${_devices.length}',
                //         color: const Color(0xFF2D5F4C),
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     Expanded(
                //       child: _buildStatCard(
                //         icon: Icons.check_circle,
                //         label: 'Active',
                //         value: '${_devices.where((d) => d['status'] == 'active').length}',
                //         color: Colors.green,
                //       ),
                //     ),
                //   ],
                // ),

                const SizedBox(height: 8),

                // Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Devices',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5F4C),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Filter options
                      },
                      icon: const Icon(Icons.filter_list, size: 18),
                      label: const Text('Filter'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2D5F4C),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Device List
                ..._devices.map((device) => _buildDeviceCard(device)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final isActive = device['status'] == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChamberDetailScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? const Color(0xFF2D5F4C).withValues(alpha: 0.3) : Colors.grey.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Device Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF2D5F4C).withValues(alpha: 0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.sensor_door,
                        color: isActive ? const Color(0xFF2D5F4C) : Colors.grey.shade400,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Device Info
                    Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          device['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5F4C),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${device['id']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

                    // More Options
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      color: Colors.grey.shade600,
                      onPressed: () {
                        _showDeviceOptions(device);
                      },
                    ),
                  ],
                ),

          const SizedBox(height: 16),

          // Device Stats
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDeviceStatItem(
                icon: Icons.location_on,
                label: device['location'],
              ),
              _buildDeviceStatItem(
                icon: Icons.thermostat,
                label: device['temperature'],
              ),
              _buildDeviceStatItem(
                icon: Icons.water_drop,
                label: device['humidity'],
              ),
              _buildDeviceStatItem(
                icon: Icons.air,
                label: device['co2'],
              ),
              _buildDeviceStatItem(
                icon: Icons.battery_full,
                label: device['battery'],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Last Update
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                'Last update: ${device['lastUpdate']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Devices',
          style: TextStyle(
            color: Color(0xFF2D5F4C),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D5F4C).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.devices_other,
                  size: 80,
                  color: Color(0xFF2D5F4C),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'No Devices Connected',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5F4C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Connect your first MASH device to start monitoring your mushroom cultivation',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WiFiDeviceConnectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5F4C),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Connect Device',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceStatItem({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2D5F4C).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2D5F4C)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D5F4C),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeviceOptions(Map<String, dynamic> device) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D5F4C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.sensor_door,
                      color: Color(0xFF2D5F4C),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5F4C),
                          ),
                        ),
                        Text(
                          device['id'],
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
              const SizedBox(height: 24),
              
              // Options
              ListTile(
                leading: const Icon(Icons.info_outline, color: Color(0xFF2D5F4C)),
                title: const Text('Device Information'),
                subtitle: const Text('View device details and status'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeviceInfo(device);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF2D5F4C)),
                title: const Text('Edit Device'),
                subtitle: const Text('Change name and location'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDevice(device);
                },
              ),
              ListTile(
                leading: const Icon(Icons.wifi, color: Color(0xFF2D5F4C)),
                title: const Text('WiFi Settings'),
                subtitle: const Text('Reconnect or change WiFi network'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WiFiDeviceConnectionScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt, color: Color(0xFF2D5F4C)),
                title: const Text('Restart Device'),
                subtitle: const Text('Reboot the device'),
                onTap: () {
                  Navigator.pop(context);
                  _showRestartConfirmation(device);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Device', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Disconnect and remove from app'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(device);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeviceInfo(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Device Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Device ID', device['id']),
            _buildInfoRow('Name', device['name']),
            _buildInfoRow('Location', device['location']),
            _buildInfoRow('Status', device['status'] == 'active' ? 'Active' : 'Inactive'),
            _buildInfoRow('Temperature', device['temperature']),
            _buildInfoRow('Humidity', device['humidity']),
            _buildInfoRow('CO2', device['co2']),
            _buildInfoRow('Battery', device['battery']),
            _buildInfoRow('Last Update', device['lastUpdate']),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5F4C),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDevice(Map<String, dynamic> device) {
    final nameController = TextEditingController(text: device['name']);
    final locationController = TextEditingController(text: device['location']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Device Name',
                hintText: 'Enter device name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Enter location',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Device updated successfully'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5F4C),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRestartConfirmation(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.restart_alt,
                color: Colors.orange.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Restart Device?'),
          ],
        ),
        content: Text(
          'Are you sure you want to restart ${device['name']}? The device will be offline for a few seconds.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${device['name']} is restarting...'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Device?'),
        content: Text('Are you sure you want to remove ${device['name']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${device['name']} removed')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
