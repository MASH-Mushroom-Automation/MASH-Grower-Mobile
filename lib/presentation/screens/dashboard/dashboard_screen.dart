import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sensor_provider.dart';
import '../../providers/device_provider.dart';
import '../../widgets/common/loading_indicator.dart';

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
              sensorProvider.refreshSensorData();
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

          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.eco,
                  size: 64,
                  color: Colors.green,
                ),
                SizedBox(height: 16),
                Text(
                  'Welcome to M.A.S.H.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your smart mushroom growing assistant',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
