import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/device_provider.dart';
import '../../widgets/common/loading_indicator.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Backend Integration - Register new IoT device
              // Example flow:
              // 1. Show device registration dialog
              // 2. POST /api/devices with device info
              // 3. Refresh device list after successful registration
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add device not implemented yet')),
              );
            },
          ),
        ],
      ),
      body: Consumer<DeviceProvider>(
        builder: (context, deviceProvider, child) {
          if (deviceProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (deviceProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading devices',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deviceProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Backend Integration - Retry fetching devices
                      // This should call: GET /api/users/:userId/devices
                      deviceProvider.loadDevices();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (deviceProvider.devices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.device_hub_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No devices found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first device to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deviceProvider.devices.length,
            itemBuilder: (context, index) {
              final device = deviceProvider.devices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: device.isOnline 
                        ? Colors.green 
                        : Colors.grey,
                    child: const Icon(
                      Icons.device_hub,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(device.name),
                  subtitle: Text(device.deviceTypeDisplayName),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        device.statusDisplayName,
                        style: TextStyle(
                          color: device.isOnline ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (device.lastSeen != null)
                        Text(
                          'Last seen: ${_formatTimeAgo(device.lastSeen!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Navigate to device detail
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Device ${device.name} details not implemented yet')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
