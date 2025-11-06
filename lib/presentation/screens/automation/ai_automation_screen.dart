import 'package:flutter/material.dart';
import '../../../core/services/device_connection_service.dart';

class AIAutomationScreen extends StatefulWidget {
  const AIAutomationScreen({super.key});

  @override
  State<AIAutomationScreen> createState() => _AIAutomationScreenState();
}

class _AIAutomationScreenState extends State<AIAutomationScreen> {
  final DeviceConnectionService _deviceService = DeviceConnectionService();
  bool _isAutomationEnabled = false;
  bool _isLoading = true;
  Map<String, dynamic>? _automationStatus;
  Map<String, dynamic>? _actuatorStates;
  List<dynamic> _decisionHistory = [];

  @override
  void initState() {
    super.initState();
    _loadAutomationStatus();
  }

  Future<void> _loadAutomationStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final status = await _deviceService.getAutomationStatus();
      final actuators = await _deviceService.getActuatorStates();
      final history = await _deviceService.getAutomationHistory(limit: 10);
      
      if (mounted) {
        setState(() {
          _automationStatus = status;
          _isAutomationEnabled = status?['enabled'] ?? false;
          _actuatorStates = actuators;
          _decisionHistory = history ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleAutomation(bool value) async {
    setState(() => _isLoading = true);

    try {
      final success = value
          ? await _deviceService.enableAutomation()
          : await _deviceService.disableAutomation();

      if (success && mounted) {
        setState(() {
          _isAutomationEnabled = value;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? 'AI Automation Enabled' : 'AI Automation Disabled',
            ),
            backgroundColor: value ? const Color(0xFF4CAF50) : Colors.grey,
          ),
        );
        
        await _loadAutomationStatus();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to toggle automation'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2D5F4C),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Automation Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isAutomationEnabled
                    ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                    : [Colors.grey.shade300, Colors.grey.shade400],
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Automation',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Intelligent chamber control',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 1.2,
                      child: Switch(
                        value: _isAutomationEnabled,
                        onChanged: _toggleAutomation,
                        activeColor: Colors.white,
                        activeTrackColor: Colors.white.withValues(alpha: 0.5),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isAutomationEnabled
                                ? Icons.check_circle
                                : Icons.pause_circle,
                            color: _isAutomationEnabled
                                ? const Color(0xFF4CAF50)
                                : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isAutomationEnabled ? 'Active' : 'Paused',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _isAutomationEnabled
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isAutomationEnabled
                            ? 'AI is actively monitoring and controlling your chamber based on sensor data and optimal growing conditions.'
                            : 'Enable AI automation to let the system automatically manage temperature, humidity, and CO2 levels.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // AI Features Help Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'How AI Works',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5F4C),
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                onPressed: _showAIFeaturesModal,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Actuator Status Section
          const Text(
            'Actuator Status',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5F4C),
            ),
          ),

          const SizedBox(height: 16),

          if (_actuatorStates != null) ...[
            _buildActuatorStatusCard(
              'Exhaust Fan',
              Icons.air,
              _actuatorStates!['exhaust_fan'] ?? false,
            ),
            const SizedBox(height: 12),
            _buildActuatorStatusCard(
              'Humidifier',
              Icons.water_drop,
              _actuatorStates!['humidifier'] ?? false,
            ),
            const SizedBox(height: 12),
            _buildActuatorStatusCard(
              'Blower Fan',
              Icons.air_rounded,
              _actuatorStates!['blower_fan'] ?? false,
            ),
            const SizedBox(height: 12),
            _buildActuatorStatusCard(
              'LED Lights',
              Icons.light,
              _actuatorStates!['led_lights'] ?? false,
            ),
          ],

          const SizedBox(height: 24),

          // AI Decision History Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent AI Decisions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5F4C),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF2D5F4C)),
                onPressed: _loadAutomationStatus,
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (_decisionHistory.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _isAutomationEnabled
                      ? 'Waiting for AI decisions...'
                      : 'Enable AI to see decisions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            )
          else
            ...(_decisionHistory.take(5).map((decision) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDecisionCard(decision),
              );
            }).toList()),

          const SizedBox(height: 24),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF2D5F4C),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can manually override AI decisions at any time from the Chamber Detail screen.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActuatorStatusCard(String name, IconData icon, bool isOn) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOn
              ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isOn
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isOn ? const Color(0xFF4CAF50) : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isOn ? const Color(0xFF2D5F4C) : Colors.grey,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isOn
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isOn ? 'ON' : 'OFF',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isOn ? const Color(0xFF4CAF50) : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionCard(Map<String, dynamic> decision) {
    final timestamp = decision['timestamp'] ?? '';
    final mode = decision['mode'] ?? 'Unknown';
    final actions = decision['actions'] as Map<String, dynamic>? ?? {};
    final reasoning = decision['reasoning'] as List<dynamic>? ?? [];
    final sensorData = decision['sensor_data'] as Map<String, dynamic>?;

    // Parse timestamp
    String timeAgo = 'Just now';
    try {
      final dt = DateTime.parse(timestamp);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) {
        timeAgo = 'Just now';
      } else if (diff.inMinutes < 60) {
        timeAgo = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        timeAgo = '${diff.inHours}h ago';
      } else {
        timeAgo = '${diff.inDays}d ago';
      }
    } catch (e) {
      // Keep default
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: const Color(0xFF4CAF50),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mode,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5F4C),
                    ),
                  ),
                ],
              ),
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions.entries.map((entry) {
                final actuatorName = entry.key.replaceAll('_', ' ').toUpperCase();
                final isOn = entry.value as bool;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOn
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isOn
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                          : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOn ? Icons.toggle_on : Icons.toggle_off,
                        size: 16,
                        color: isOn ? const Color(0xFF4CAF50) : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$actuatorName ${isOn ? "ON" : "OFF"}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isOn ? const Color(0xFF2D5F4C) : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          if (sensorData != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sensors,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Sensor Data',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildSensorChip(
                        'CO2',
                        '${sensorData['co2'] ?? 0}ppm',
                        Icons.air,
                      ),
                      _buildSensorChip(
                        'Temp',
                        '${sensorData['temperature'] ?? 0}°C',
                        Icons.thermostat,
                      ),
                      _buildSensorChip(
                        'Humidity',
                        '${sensorData['humidity'] ?? 0}%',
                        Icons.water_drop,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (reasoning.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: reasoning.map((reason) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            reason.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSensorChip(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.orange.shade700,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: Colors.orange.shade900,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade900,
          ),
        ),
      ],
    );
  }

  void _showAIFeaturesModal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Color(0xFF4CAF50),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'AI Features',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5F4C),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildModalFeatureItem(
                icon: Icons.thermostat,
                title: 'Temperature Control',
                description:
                    'Maintains optimal temperature range based on growth phase. Automatically adjusts blower fan to cool the chamber when needed.',
              ),
              const SizedBox(height: 16),
              _buildModalFeatureItem(
                icon: Icons.water_drop,
                title: 'Humidity Management',
                description:
                    'Automatically adjusts humidity levels for ideal conditions. Turns humidifier ON/OFF to maintain 85-95% humidity.',
              ),
              const SizedBox(height: 16),
              _buildModalFeatureItem(
                icon: Icons.air,
                title: 'CO2 Optimization',
                description:
                    'Manages CO2 levels for spawning (high CO2) and fruiting (low CO2) phases. Controls exhaust fan for proper air exchange.',
              ),
              const SizedBox(height: 16),
              _buildModalFeatureItem(
                icon: Icons.settings_suggest,
                title: 'Mode-Aware Control',
                description:
                    'Adapts strategy based on spawning or fruiting mode. Each mode has different optimal ranges for all parameters.',
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFF2D5F4C),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI makes decisions every 10 seconds based on real-time sensor data',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4CAF50),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D5F4C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
