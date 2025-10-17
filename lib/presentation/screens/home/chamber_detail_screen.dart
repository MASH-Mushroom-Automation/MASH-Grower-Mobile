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
            icon: const Icon(Icons.settings, color: Color(0xFF2D5F4C)),
            onPressed: () {
              // TODO: Navigate to chamber settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Cards Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatusCard(
                  icon: Icons.thermostat,
                  label: 'Chamber',
                  value: '31°C',
                  color: const Color(0xFF2D5F4C),
                ),
                _buildStatusCard(
                  icon: Icons.thermostat_outlined,
                  label: 'Current',
                  value: '20°C',
                  color: const Color(0xFF2D5F4C),
                ),
                _buildStatusCard(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: '54%',
                  color: const Color(0xFF2D5F4C),
                ),
                _buildStatusCard(
                  icon: Icons.battery_charging_full,
                  label: 'Battery',
                  value: '80%',
                  color: const Color(0xFF2D5F4C),
                ),
              ],
            ),
            
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
            
            // Sensor Control Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _buildSensorControlCard(
                  icon: Icons.thermostat,
                  label: 'Temperature Sensor',
                  value: '23°C',
                  isOn: _tempSensorOn,
                  onToggle: (value) {
                    setState(() {
                      _tempSensorOn = value;
                    });
                  },
                ),
                _buildSensorControlCard(
                  icon: Icons.water_drop,
                  label: 'Humidity Sensor',
                  value: '54%',
                  isOn: _humiditySensorOn,
                  onToggle: (value) {
                    setState(() {
                      _humiditySensorOn = value;
                    });
                  },
                ),
                _buildSensorControlCard(
                  icon: Icons.air,
                  label: 'CO2 Sensor',
                  value: 'Current: 1200ppm',
                  isOn: _co2SensorOn,
                  onToggle: (value) {
                    setState(() {
                      _co2SensorOn = value;
                    });
                  },
                ),
                _buildSensorControlCard(
                  icon: Icons.mode_fan_off,
                  label: 'Fan',
                  value: 'Spinning',
                  isOn: _fanOn,
                  onToggle: (value) {
                    setState(() {
                      _fanOn = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorControlCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isOn,
    required Function(bool) onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2D5F4C), size: 32),
          ),
          
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5F4C),
            ),
          ),
          
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOn ? 'ON' : 'OFF',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isOn ? const Color(0xFF4CAF50) : Colors.grey,
                ),
              ),
              Switch(
                value: isOn,
                onChanged: onToggle,
                activeTrackColor: const Color(0xFF4CAF50),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
