import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sensor_provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/notification_provider.dart';
import '../devices/device_list_screen.dart';
import '../notifications/notification_list_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/common/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const DeviceListScreen(),
    const NotificationListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Initialize sensor data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      
      // TODO: Backend Integration - Load user's devices from backend API
      // Example API call:
      // deviceProvider.fetchDevicesFromBackend();
      // This should call: GET /api/users/:userId/devices
      
      // TODO: Backend Integration - Load user's notifications/alerts from backend
      // Example API call:
      // notificationProvider.fetchNotificationsFromBackend();
      // This should call: GET /api/notifications
      
      // Load initial data (currently using local/mock data)
      deviceProvider.loadDevices();
      notificationProvider.loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.device_hub_outlined),
            selectedIcon: Icon(Icons.device_hub),
            label: 'Devices',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Backend Integration - Register new IoT device
                // Example flow:
                // 1. Show device registration dialog
                // 2. Collect device info (serial number, name, etc.)
                // 3. Call: POST /api/devices with device data
                // 4. On success, add device to local state and navigate to device setup
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add device not implemented yet')),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

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
              // TODO: Refresh data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing data...')),
              );
            },
          ),
        ],
      ),
      body: Consumer<SensorProvider>(
        builder: (context, sensorProvider, child) {
          if (sensorProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (sensorProvider.error != null) {
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
                    'Error loading data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sensorProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Retry loading
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
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
