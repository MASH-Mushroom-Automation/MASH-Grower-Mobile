import 'package:flutter/material.dart';

class ChamberDetailScreen extends StatefulWidget {
  const ChamberDetailScreen({super.key});

  @override
  State<ChamberDetailScreen> createState() => _ChamberDetailScreenState();
}

class _ChamberDetailScreenState extends State<ChamberDetailScreen> {
  bool _tempSensorOn = true;
  bool _humiditySensorOn = true;
  bool _co2SensorOn = true;
  bool _fanOn = true;
  bool _humidifierOn = true;
  bool _blowerFanOn = true;
  bool _ledOn = true;
  
  // Mode selection
  String _selectedMode = 'Spawning Phase';
  final List<String> _modes = ['Spawning Phase', 'Fruiting Phase'];
  
  // Mock CO2 sensor reading (in ppm)
  double _currentCO2 = 5000.0;
  
  // Get mode-specific settings
  Map<String, dynamic> get _modeSettings {
    if (_selectedMode == 'Spawning Phase') {
      return {
        'fanEnabled': false,
        'co2Target': 5000.0,
        'co2Min': 5000.0,
        'co2Max': 5000.0,
        'description': 'Fan disabled to allow CO2 accumulation',
        'color': const Color(0xFF9C27B0), // Purple
      };
    } else {
      return {
        'fanEnabled': true,
        'co2Target': 550.0,
        'co2Min': 300.0,
        'co2Max': 800.0,
        'description': 'Fan enabled for proper air circulation',
        'color': const Color(0xFF4CAF50), // Green
      };
    }
  }
  
  // Check if CO2 is in acceptable range
  String get _co2Status {
    final settings = _modeSettings;
    if (_selectedMode == 'Spawning Phase') {
      // Alert if below 5000 ppm
      if (_currentCO2 < settings['co2Min']) {
        return 'ALERT: CO2 below target (${_currentCO2.toInt()} ppm)';
      }
      return 'Optimal: ${_currentCO2.toInt()} ppm (limit)';
    } else {
      // Fruiting phase: 300-800 ppm
      if (_currentCO2 > settings['co2Max']) {
        return 'ALERT: CO2 too high (${_currentCO2.toInt()} ppm)';
      } else if (_currentCO2 < settings['co2Min']) {
        return 'WARNING: CO2 too low (${_currentCO2.toInt()} ppm)';
      }
      return 'Optimal: ${_currentCO2.toInt()} ppm';
    }
  }
  
  Color get _co2StatusColor {
    if (_co2Status.startsWith('ALERT')) return Colors.red;
    if (_co2Status.startsWith('WARNING')) return Colors.orange;
    return Colors.green;
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chamber 1',
              style: TextStyle(
                color: Color(0xFF2D5F4C),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Manage your Environment controls',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF2D5F4C)),
            onPressed: _showEditOptions,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF2D5F4C)),
            onPressed: _showSettingsOptions,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF2D5F4C)),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Selector Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _modeSettings['color'],
                    _modeSettings['color'].withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.settings_suggest,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Chamber Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMode,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: _modeSettings['color']),
                        items: _modes.map((mode) {
                          return DropdownMenuItem(
                            value: mode,
                            child: Text(
                              mode,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _modeSettings['color'],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMode = value!;
                            // Update fan state based on mode
                            _fanOn = _modeSettings['fanEnabled'];
                          });
                          _showModeChangeConfirmation(value!);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        _modeSettings['fanEnabled'] ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _modeSettings['description'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // CO2 Status Indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.air,
                              color: _co2StatusColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'CO2 Level',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _co2Status,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: _co2StatusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Testing controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _currentCO2 = _selectedMode == 'Spawning Phase' 
                                        ? 4999.0 // Below threshold
                                        : 850.0; // Above threshold
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade100,
                                  foregroundColor: Colors.red.shade700,
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  minimumSize: const Size(0, 28),
                                ),
                                child: const Text('Alert', style: TextStyle(fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _currentCO2 = _selectedMode == 'Spawning Phase'
                                        ? 5000.0 // At limit
                                        : 550.0; // Optimal
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade100,
                                  foregroundColor: Colors.green.shade700,
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  minimumSize: const Size(0, 28),
                                ),
                                child: const Text('Normal', style: TextStyle(fontSize: 11)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // // Status Cards Grid
            // GridView.count(
            //   crossAxisCount: 2,
            //   shrinkWrap: true,
            //   physics: const NeverScrollableScrollPhysics(),
            //   mainAxisSpacing: 16,
            //   crossAxisSpacing: 16,
            //   childAspectRatio: 1.5,
            //   children: [
            //     _buildStatusCard(
            //       icon: Icons.thermostat,
            //       label: 'Chamber',
            //       value: '31°C',
            //       color: const Color(0xFF2D5F4C),
            //     ),
            //     _buildStatusCard(
            //       icon: Icons.thermostat_outlined,
            //       label: 'Current',
            //       value: '20°C',
            //       color: const Color(0xFF2D5F4C),
            //     ),
            //     _buildStatusCard(
            //       icon: Icons.water_drop,
            //       label: 'Humidity',
            //       value: '54%',
            //       color: const Color(0xFF2D5F4C),
            //     ),
            //     _buildStatusCard(
            //       icon: Icons.battery_charging_full,
            //       label: 'Battery',
            //       value: '80%',
            //       color: const Color(0xFF2D5F4C),
            //     ),
            //   ],
            // ),
            
            const SizedBox(height: 24),
            
            // Sensors Tab
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Sensors',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D5F4C),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sensor Control Cards - responsive grid
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxis = width < 600 ? 2 : 3;
                final spacing = 12 * (crossAxis - 1);
                final itemWidth = (width - spacing) / crossAxis;
                // reduce target height by ~20% to make cards smaller
                const itemHeight = 112.0; // 140 * 0.8
                final childAspectRatio = (itemWidth / itemHeight).clamp(0.5, 2.0);

                return GridView.count(
                  crossAxisCount: crossAxis,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildSensorControlCard(
                      icon: Icons.thermostat,
                      label: 'Temperature',
                      value: '23°C',
                      isOn: _tempSensorOn,
                    ),
                    _buildSensorControlCard(
                      icon: Icons.thermostat,
                      label: 'Temperature',
                      value: '23°C',
                      isOn: _tempSensorOn,
                    ),
                    _buildSensorControlCard(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '54%',
                      isOn: _humiditySensorOn,
                    ),
                    _buildSensorControlCard(
                      icon: Icons.air,
                      label: 'CO2',
                      value: 'Current: ${_currentCO2.toInt()}ppm',
                      isOn: _co2SensorOn,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Actuator Tab
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Actuators',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D5F4C),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Actuator Control Cards - responsive grid
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxis = width < 600 ? 2 : 3;
                final spacing = 1 * (crossAxis - 1);
                final itemWidth = (width - spacing) / crossAxis;
                // reduced by ~20%, now make actuators 10% smaller further
                const itemHeight = 180.0; // 120 * 0.9
                final childAspectRatio = (itemWidth / itemHeight).clamp(0.5, 2.0);

                return GridView.count(
                  crossAxisCount: crossAxis,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildActuatorControlCard(
                      icon: Icons.air,
                      label: 'Fans',
                      isOn: _fanOn,
                      onToggle: (value) {
                        setState(() {
                          _fanOn = value;
                        });
                      },
                    ),
                    _buildActuatorControlCard(
                      icon: Icons.water_drop,
                      label: 'Humidifier',
                      isOn: _humidifierOn,
                      onToggle: (value) {
                        setState(() {
                          _humidifierOn = value;
                        });
                      },
                    ),
                    _buildActuatorControlCard(
                      icon: Icons.air_rounded,
                      label: 'Blower Fan',
                      isOn: _blowerFanOn,
                      onToggle: (value) {
                        setState(() {
                          _blowerFanOn = value;
                        });
                      },
                    ),
                    _buildActuatorControlCard(
                      icon: Icons.light,
                      label: 'LED',
                      isOn: _ledOn,
                      onToggle: (value) {
                        setState(() {
                          _ledOn = value;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            // 
          ],
        ),
      ),
    );
  }

  // Note: _buildStatusCard was removed because it's not currently used.

  Widget _buildSensorControlCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isOn,
    bool isDisabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12), // reduced ~20%
      decoration: BoxDecoration(
        color: isDisabled
            ? Colors.grey.shade200
            : const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDisabled ? Colors.grey : const Color(0xFF2D5F4C),
              size: 26, // reduced from 32
            ),
          ),

          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12, // reduced ~20%
              fontWeight: FontWeight.w600,
              color: isDisabled ? Colors.grey : const Color(0xFF2D5F4C),
            ),
          ),

          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10, // reduced ~20%
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActuatorControlCard({
    required IconData icon,
    required String label,
    required bool isOn,
    required Function(bool)? onToggle,
    bool isDisabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12), // reduced ~20%
      decoration: BoxDecoration(
        color: isDisabled
            ? Colors.grey.shade200
            : const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDisabled ? Colors.grey : const Color(0xFF2D5F4C),
              size: 22, // smaller
            ),
          ),

          const SizedBox(height: 6),

          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11, // reduced
              fontWeight: FontWeight.w600,
              color: isDisabled ? Colors.grey : const Color(0xFF2D5F4C),
            ),
          ),

          const SizedBox(height: 6),

          Column(
            children: [
              Text(
                isDisabled ? 'DISABLED' : (isOn ? 'ACTIVE' : 'INACTIVE'),
                style: TextStyle(
                  fontSize: 9, // slightly smaller
                  fontWeight: FontWeight.bold,
                  color: isDisabled
                      ? Colors.grey
                      : (isOn ? const Color(0xFF4CAF50) : Colors.grey),
                ),
              ),
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: isOn,
                  onChanged: isDisabled ? null : onToggle,
                  activeTrackColor: const Color(0xFF4CAF50),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showEditOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Chamber'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Chamber Name',
                hintText: 'Enter chamber name',
              ),
              controller: TextEditingController(text: 'Chamber 1'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Enter location',
              ),
              controller: TextEditingController(text: 'Main Facility'),
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
                const SnackBar(content: Text('Chamber updated successfully')),
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

  void _showSettingsOptions() {
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
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5F4C),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.thermostat, color: Color(0xFF2D5F4C)),
                title: const Text('Temperature Settings'),
                subtitle: const Text('Configure temperature thresholds'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to temperature settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.water_drop, color: Color(0xFF2D5F4C)),
                title: const Text('Humidity Settings'),
                subtitle: const Text('Configure humidity levels'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to humidity settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications, color: Color(0xFF2D5F4C)),
                title: const Text('Notification Settings'),
                subtitle: const Text('Manage alerts and notifications'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to notification settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.schedule, color: Color(0xFF2D5F4C)),
                title: const Text('Schedule Settings'),
                subtitle: const Text('Set automation schedules'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to schedule settings
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMoreOptions() {
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
            children: [
              ListTile(
                leading: const Icon(Icons.info, color: Color(0xFF2D5F4C)),
                title: const Text('Device Information'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeviceInfo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Color(0xFF2D5F4C)),
                title: const Text('Activity History'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to history
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Color(0xFF2D5F4C)),
                title: const Text('Share Access'),
                onTap: () {
                  Navigator.pop(context);
                  // Share access
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Chamber', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeviceInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Device Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Device ID', 'MASH-A1-CAL25-D5A91F'),
            _buildInfoRow('Name', 'Chamber 1'),
            _buildInfoRow('Location', 'Main Facility'),
            _buildInfoRow('Status', 'Active'),
            _buildInfoRow('Last Update', '2 mins ago'),
            _buildInfoRow('Firmware', 'v2.1.0'),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Chamber?'),
        content: const Text(
          'Are you sure you want to remove this chamber? This action cannot be undone and all data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to home
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chamber removed'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showModeChangeConfirmation(String newMode) {
    final settings = _modeSettings;
    final color = settings['color'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.settings_suggest,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Mode Changed',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chamber mode switched to:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color, width: 2),
              ),
              child: Text(
                newMode,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildModeInfo(
              'Fan Status',
              settings['fanEnabled'] ? 'Enabled' : 'Disabled',
              settings['fanEnabled'] ? Icons.check_circle : Icons.cancel,
              settings['fanEnabled'] ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildModeInfo(
              'CO2 Target',
              newMode == 'Spawning Phase' 
                  ? '5000 ppm (limit)' 
                  : '300-800 ppm',
              Icons.air,
              const Color(0xFF2D5F4C),
            ),
            const SizedBox(height: 8),
            _buildModeInfo(
              'Alert Trigger',
              newMode == 'Spawning Phase'
                  ? 'CO2 < 5000 ppm'
                  : 'CO2 > 800 ppm',
              Icons.warning_amber,
              Colors.red,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildModeInfo(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
