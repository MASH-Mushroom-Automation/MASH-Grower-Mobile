import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sensor_provider.dart';
import '../../providers/device_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../core/config/theme_config.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Backend Integration - Refresh sensor data and device status
              // Example API calls:
              // 1. GET /api/sensors/data/:deviceId/latest - Get latest sensor readings
              // 2. GET /api/devices/:id/status - Get device status
              // 3. Update local state with fresh data
              
              final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
              final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
              
              // Refresh data (currently using local/mock data)
              sensorProvider.loadLatestReadings('demo-device-1');
              deviceProvider.loadDevices();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing data...')),
              );
            },
          ),
        ],
      ),
      body: Consumer2<SensorProvider, DeviceProvider>(
        builder: (context, sensorProvider, deviceProvider, child) {
          if (sensorProvider.isLoading || deviceProvider.isLoading) {
            return const LoadingIndicator();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.eco,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to M.A.S.H.',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your smart mushroom growing assistant',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sensor Status Overview
                Text(
                  'Sensor Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildSensorCard(
                      context,
                      'Temperature',
                      '24.5°C',
                      Icons.thermostat,
                      ThemeConfig.sensorGood,
                    ),
                    _buildSensorCard(
                      context,
                      'Humidity',
                      '65%',
                      Icons.water_drop,
                      ThemeConfig.sensorGood,
                    ),
                    _buildSensorCard(
                      context,
                      'CO2',
                      '400 ppm',
                      Icons.air,
                      ThemeConfig.sensorGood,
                    ),
                    _buildSensorCard(
                      context,
                      'Light',
                      'Good',
                      Icons.lightbulb,
                      ThemeConfig.sensorGood,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Device Status
                Text(
                  'Device Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.device_hub, color: Colors.green),
                          title: const Text('Main Controller'),
                          subtitle: const Text('Online - All systems operational'),
                          trailing: const Icon(Icons.check_circle, color: Colors.green),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.sensors, color: Colors.green),
                          title: const Text('Sensor Array'),
                          subtitle: const Text('4 sensors active'),
                          trailing: const Icon(Icons.check_circle, color: Colors.green),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.air, color: Colors.orange),
                          title: const Text('Ventilation System'),
                          subtitle: const Text('Running at 60% capacity'),
                          trailing: const Icon(Icons.sync, color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Manual control not implemented yet')),
                          );
                        },
                        icon: const Icon(Icons.settings),
                        label: const Text('Manual Control'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reports not implemented yet')),
                          );
                        },
                        icon: const Icon(Icons.analytics),
                        label: const Text('Reports'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSensorCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color statusColor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: statusColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
