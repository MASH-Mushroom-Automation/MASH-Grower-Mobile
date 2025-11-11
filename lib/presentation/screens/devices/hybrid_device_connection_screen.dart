import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multicast_dns/multicast_dns.dart';
import '../../../core/services/websocket_device_service.dart';
import '../../../core/services/device_connection_service.dart';
import '../../../core/services/mock_device_service.dart';
import '../../../core/utils/logger.dart';
import '../../../services/bluetooth_device_service.dart';
import '../../../services/device_connection_manager.dart';
import '../../providers/auth_provider.dart';
import '../../providers/device_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';

/// Hybrid device connection screen supporting:
/// 1. WebSocket connection (via backend)
/// 2. Direct IP connection (local network fallback)
/// 3. Auto-discovery via mDNS (local network)
class HybridDeviceConnectionScreen extends StatefulWidget {
  const HybridDeviceConnectionScreen({super.key});

  @override
  State<HybridDeviceConnectionScreen> createState() => _HybridDeviceConnectionScreenState();
}

class _HybridDeviceConnectionScreenState extends State<HybridDeviceConnectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // WebSocket
  final WebSocketDeviceService _wsService = WebSocketDeviceService();
  List<Map<String, dynamic>> _cloudDevices = [];
  bool _isScanningCloud = false;
  
  // Local Network
  final DeviceConnectionService _localService = DeviceConnectionService();
  List<Map<String, dynamic>> _localDevices = [];
  bool _isScanningLocal = false;
  
  // Mock Device
  final MockDeviceService _mockService = MockDeviceService();
  
  // Manual IP
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: '5000');
  bool _isConnectingManual = false;
  
  String? _selectedDeviceId;
  bool _isConnecting = false;

  // Bluetooth
  final BluetoothDeviceService _bluetoothService = BluetoothDeviceService();
  List<BluetoothMashDevice> _bluetoothDevices = [];
  bool _isScanningBluetooth = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupWebSocketCallbacks();
    _setupBluetoothListener();
    
    // Auto-scan on load
    _scanCloudDevices();
    _scanLocalDevices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ipController.dispose();
    _portController.dispose();
    _wsService.disconnect();
    _bluetoothService.dispose();
    super.dispose();
  }

  void _setupWebSocketCallbacks() {
    _wsService.onConnected = () {
      if (mounted) {
        setState(() => _isConnecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connected via WebSocket!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context);
      }
    };
    
    _wsService.onError = (error) {
      if (mounted) {
        setState(() => _isConnecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    };
  }

  void _setupBluetoothListener() {
    _bluetoothService.devicesStream.listen((devices) {
      if (mounted) {
        setState(() {
          _bluetoothDevices = devices;
        });
      }
    });
  }

  // ============ CLOUD DEVICES (WebSocket) ============
  
  Future<void> _scanCloudDevices() async {
    setState(() {
      _isScanningCloud = true;
      _cloudDevices = [];
    });

    try {
      // TODO: Call backend API to get list of devices
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _cloudDevices = [
          {
            'deviceId': 'mock-chamber-1',
            'deviceName': 'Mock Chamber 1',
            'status': 'online',
            'mode': 'FRUITING',
            'connectionType': 'mock',
            'lastSeen': DateTime.now().subtract(const Duration(minutes: 2)),
          },
          {
            'deviceId': 'chamber-001',
            'deviceName': 'Chamber 1',
            'status': 'online',
            'mode': 'FRUITING',
            'connectionType': 'cloud',
            'lastSeen': DateTime.now().subtract(const Duration(minutes: 2)),
          },
        ];
      });
    } catch (e) {
      Logger.error('Failed to scan cloud devices: $e');
    } finally {
      setState(() => _isScanningCloud = false);
    }
  }

  Future<void> _connectToCloudDevice(String deviceId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isConnecting = true;
      _selectedDeviceId = deviceId;
    });

    try {
      if (deviceId == 'mock-chamber-1') {
        final connected = await _mockService.connectToDevice(
          deviceId: deviceId,
          deviceName: 'Mock Chamber 1',
        );
        
        if (connected && mounted) {
          final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
          await deviceProvider.connectToMockDevice(
            deviceId: deviceId,
            deviceName: 'Mock Chamber 1',
          );
          
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connected to Mock Chamber 1!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        } else {
          throw Exception('Failed to connect to mock device');
        }
      } else {
        const wsUrl = 'ws://localhost:8080/ws/device';
        const token = 'your-jwt-token';
        
        final connected = await _wsService.connect(
          wsUrl: wsUrl,
          deviceId: deviceId,
          userId: authProvider.user!.id,
          token: token,
        );

        if (!connected) {
          throw Exception('Failed to establish WebSocket connection');
        }
      }
    } catch (e) {
      Logger.error('Cloud connection failed: $e');
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _selectedDeviceId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ============ LOCAL DEVICES (mDNS Auto-Discovery) ============
  
  Future<void> _scanLocalDevices() async {
    setState(() {
      _isScanningLocal = true;
      _localDevices = [];
    });

    try {
      Logger.info('Starting mDNS scan for local devices...');
      final MDnsClient client = MDnsClient(rawDatagramSocketFactory: (dynamic host, int port,
          {bool? reuseAddress, bool? reusePort, int? ttl}) {
        return RawDatagramSocket.bind(host, port,
            reuseAddress: true, reusePort: false, ttl: ttl ?? 1);
      });
      await client.start();

      // Look for _mash-iot._tcp service (matches MDNSDiscoveryService)
      await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer('_mash-iot._tcp'),
      ).timeout(const Duration(seconds: 10), onTimeout: (sink) {
        Logger.info('mDNS scan timeout - no devices found');
        sink.close();
      })) {
        Logger.debug('Found PTR record: ${ptr.domainName}');
        
        await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(ptr.domainName),
        ).timeout(const Duration(seconds: 5), onTimeout: (sink) => sink.close())) {
          Logger.debug('Found SRV record: ${srv.target}:${srv.port}');
          
          // Get IP address
          await for (final IPAddressResourceRecord ip in client.lookup<IPAddressResourceRecord>(
            ResourceRecordQuery.addressIPv4(srv.target),
          ).timeout(const Duration(seconds: 5), onTimeout: (sink) => sink.close())) {
            final ipAddress = ip.address.address;
            Logger.info('Discovered device: ${ptr.domainName} at $ipAddress:${srv.port}');
            
            setState(() {
              _localDevices.add({
                'deviceId': ptr.domainName,
                'deviceName': ptr.domainName.split('.').first,
                'ipAddress': ipAddress,
                'port': srv.port,
                'status': 'online',
                'connectionType': 'local',
              });
            });
          }
        }
      }

      client.stop();
      
      // Log results
      if (_localDevices.isEmpty) {
        Logger.info('No local devices found via mDNS');
      } else {
        Logger.info('Found ${_localDevices.length} local device(s)');
      }
    } catch (e) {
      Logger.error('mDNS scan failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() => _isScanningLocal = false);
    }
  }

  Future<void> _connectToLocalDevice(String ipAddress, int port) async {
    setState(() => _isConnecting = true);

    try {
      final connected = await _localService.connect(ipAddress, port);
      
      if (connected && mounted) {
        final status = await _localService.getDeviceStatus();
        
        // Save to device provider
        final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
        await deviceProvider.connectToDevice(
          deviceId: status['deviceId'] ?? 'unknown',
          deviceName: status['deviceName'] ?? 'Chamber',
          ipAddress: ipAddress,
          port: port,
        );
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connected via local network!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      } else {
        throw Exception('Failed to connect');
      }
    } catch (e) {
      Logger.error('Local connection failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  // ============ TUTORIAL MODAL ============
  
  void _showTutorial() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Connection Guide',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5F4C),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Cloud Connection
              _buildTutorialSection(
                icon: Icons.cloud,
                title: 'Cloud Connection',
                color: const Color(0xFF2D5F4C),
                tips: [
                  'Connect from anywhere with internet',
                  'No IP address needed',
                  'Devices auto-discovered via backend',
                  'Best for remote monitoring',
                ],
                troubleshooting: [
                  'Ensure device is online and connected to internet',
                  'Check if backend server is running',
                  'Verify your login credentials',
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Local Network
              _buildTutorialSection(
                icon: Icons.wifi,
                title: 'Local Network',
                color: Colors.blue,
                tips: [
                  'Automatic device discovery on same WiFi',
                  'Faster connection speed',
                  'No internet required',
                  'Best for local control',
                ],
                troubleshooting: [
                  'Make sure phone and device are on same WiFi network',
                  'Check if device WiFi is configured correctly',
                  'Try refreshing the scan',
                  'Ensure mDNS is enabled on your router',
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Bluetooth
              _buildTutorialSection(
                icon: Icons.bluetooth,
                title: 'Bluetooth Connection',
                color: Colors.purple,
                tips: [
                  'Direct device-to-device connection',
                  'Works offline without WiFi',
                  'Good for remote locations',
                  'Range: ~10 meters (30 feet)',
                ],
                troubleshooting: [
                  'Enable Bluetooth on both phone and device',
                  'Grant location permissions (required for BT scan)',
                  'Make sure device is in discoverable mode',
                  'Move closer to device if not found',
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Manual IP
              _buildTutorialSection(
                icon: Icons.settings_ethernet,
                title: 'Manual IP Connection',
                color: Colors.orange,
                tips: [
                  'Direct connection using IP address',
                  'Good for testing and development',
                  'Works as fallback method',
                  'Find IP on device display or router',
                ],
                troubleshooting: [
                  'Check device IP address (usually shown on display)',
                  'Verify port number (default: 5000)',
                  'Ensure phone and device are on same network',
                  'Try pinging the IP address first',
                ],
              ),
              
              const SizedBox(height: 24),
              
              // General Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'General Tips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTipItem('Ensure device is powered on'),
                    _buildTipItem('Check WiFi signal strength'),
                    _buildTipItem('Try restarting device if connection fails'),
                    _buildTipItem('Use Manual IP as last resort'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Close Button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5F4C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Got it!', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTutorialSection({
    required IconData icon,
    required String title,
    required Color color,
    required List<String> tips,
    required List<String> troubleshooting,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Tips
          const Text(
            'How to use:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: color)),
                Expanded(child: Text(tip, style: const TextStyle(fontSize: 13))),
              ],
            ),
          )),
          
          const SizedBox(height: 12),
          
          // Troubleshooting
          const Text(
            'Troubleshooting:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...troubleshooting.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.arrow_right, size: 16, color: color),
                const SizedBox(width: 4),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✓ ', style: TextStyle(color: Colors.green)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  // ============ MANUAL IP CONNECTION ============
  
  Future<void> _connectManualIP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isConnectingManual = true);

    try {
      final ipAddress = _ipController.text.trim();
      final port = int.parse(_portController.text.trim());

      await _connectToLocalDevice(ipAddress, port);
    } catch (e) {
      Logger.error('Manual connection failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isConnectingManual = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          automaticallyImplyLeading: true,
          title: const Text('Connect to Chamber'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: _showTutorial,
              tooltip: 'Tutorial & Tips',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: const [
              Tab(icon: Icon(Icons.cloud), text: 'Cloud'),
              // Tab(icon: Icon(Icons.wifi), text: 'Local'),
              Tab(icon: Icon(Icons.bluetooth), text: 'Bluetooth'),
              Tab(icon: Icon(Icons.settings_ethernet), text: 'Manual IP'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCloudTab(),
          // _buildLocalTab(),
          _buildBluetoothTab(),
          _buildManualTab(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
        isDeviceConnected: false,
      ),
    );
  }

  // ============ CLOUD TAB ============
  
  Widget _buildCloudTab() {
    return Column(
      children: [
        _buildInfoBanner(
          icon: Icons.cloud,
          title: 'Cloud Connection (WebSocket)',
          description: 'Connect from anywhere via internet',
          color: const Color(0xFF2D5F4C),
        ),
        
        if (_isScanningCloud)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_cloudDevices.isEmpty)
          _buildEmptyState(
            icon: Icons.cloud_off,
            message: 'No cloud devices found',
            onRefresh: _scanCloudDevices,
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cloudDevices.length,
              itemBuilder: (context, index) {
                final device = _cloudDevices[index];
                return _buildDeviceCard(
                  device: device,
                  onTap: () => _connectToCloudDevice(device['deviceId']),
                );
              },
            ),
          ),
      ],
    );
  }

  // ============ LOCAL TAB ============
  
  // Widget _buildLocalTab() {
  //   return Column(
  //     children: [
  //       _buildInfoBanner(
  //         icon: Icons.wifi,
  //         title: 'Local Network (Auto-Discovery)',
  //         description: 'Devices on same WiFi network',
  //         color: Colors.blue,
  //       ),
        
  //       if (_isScanningLocal)
  //         const Expanded(
  //           child: Center(child: CircularProgressIndicator()),
  //         )
  //       else if (_localDevices.isEmpty)
  //         _buildEmptyState(
  //           icon: Icons.wifi_off,
  //           message: 'No local devices found',
  //           subtitle: 'Make sure device is on same WiFi',
  //           onRefresh: _scanLocalDevices,
  //         )
  //       else
  //         Expanded(
  //           child: ListView.builder(
  //             padding: const EdgeInsets.all(16),
  //             itemCount: _localDevices.length,
  //             itemBuilder: (context, index) {
  //               final device = _localDevices[index];
  //               return _buildDeviceCard(
  //                 device: device,
  //                 onTap: () => _connectToLocalDevice(
  //                   device['ipAddress'],
  //                   device['port'],
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //     ],
  //   );
  // }

  // ============ BLUETOOTH TAB ============
  
  Future<void> _scanBluetoothDevices() async {
    setState(() {
      _isScanningBluetooth = true;
      _bluetoothDevices = [];
    });

    try {
      Logger.info('Starting Bluetooth scan...');
      
      // Check if Bluetooth is available
      final available = await _bluetoothService.isBluetoothAvailable();
      if (!available) {
        throw Exception('Bluetooth not available. Please enable Bluetooth.');
      }

      // Start scanning
      final started = await _bluetoothService.startScanning();
      if (!started) {
        throw Exception('Failed to start Bluetooth scan');
      }

      Logger.info('Bluetooth scan started');
    } catch (e) {
      Logger.error('Bluetooth scan failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // Scanning will auto-stop after duration
      Future.delayed(const Duration(seconds: 16), () {
        if (mounted) {
          setState(() => _isScanningBluetooth = false);
        }
      });
    }
  }

  Future<void> _connectToBluetoothDevice(BluetoothMashDevice device) async {
    setState(() {
      _isConnecting = true;
      _selectedDeviceId = device.deviceId;
    });

    try {
      Logger.info('Connecting to Bluetooth device: ${device.name}');
      
      final connected = await _bluetoothService.connectToDevice(device);
      
      if (connected && mounted) {
        // Save to device provider
        final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
        await deviceProvider.connectToDevice(
          deviceId: device.deviceId,
          deviceName: device.name,
          ipAddress: device.address,
          port: 0,
        );
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connected via Bluetooth!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      } else {
        throw Exception('Failed to connect');
      }
    } catch (e) {
      Logger.error('Bluetooth connection failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isConnecting = false;
        _selectedDeviceId = null;
      });
    }
  }

  Widget _buildBluetoothTab() {
    return Column(
      children: [
        _buildInfoBanner(
          icon: Icons.bluetooth,
          title: 'Bluetooth Connection',
          description: 'Direct connection via Bluetooth',
          color: Colors.purple,
        ),
        
        if (_isScanningBluetooth)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Scanning for Bluetooth devices...'),
                ],
              ),
            ),
          )
        else if (_bluetoothDevices.isEmpty)
          _buildEmptyState(
            icon: Icons.bluetooth_disabled,
            message: 'No Bluetooth devices found',
            subtitle: 'Make sure device Bluetooth is enabled',
            onRefresh: _scanBluetoothDevices,
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bluetoothDevices.length,
              itemBuilder: (context, index) {
                final device = _bluetoothDevices[index];
                return _buildBluetoothDeviceCard(
                  device: device,
                  onTap: () => _connectToBluetoothDevice(device),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBluetoothDeviceCard({
    required BluetoothMashDevice device,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedDeviceId == device.deviceId;
    final isConnecting = _isConnecting && isSelected;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.purple : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isConnecting ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bluetooth,
                  color: Colors.purple,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Address: ${device.address}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.signal_cellular_alt,
                          size: 14,
                          color: device.rssi > -70 ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Signal: ${device.rssi} dBm',
                          style: TextStyle(
                            fontSize: 12,
                            color: device.rssi > -70 ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isConnecting)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.chevron_right, color: Colors.purple),
            ],
          ),
        ),
      ),
    );
  }

  // ============ MANUAL TAB ============
  
  Widget _buildManualTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBanner(
              icon: Icons.settings_ethernet,
              title: 'Manual IP Connection',
              description: 'Enter device IP address manually',
              color: Colors.orange,
            ),
            
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP Address',
                hintText: '192.168.1.100',
                prefixIcon: Icon(Icons.computer),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter IP address';
                }
                // Basic IP validation
                final parts = value.split('.');
                if (parts.length != 4) {
                  return 'Invalid IP address format';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '5000',
                prefixIcon: Icon(Icons.settings_input_component),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter port';
                }
                final port = int.tryParse(value);
                if (port == null || port < 1 || port > 65535) {
                  return 'Invalid port number';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _isConnectingManual ? null : _connectManualIP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isConnectingManual
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Connect', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  // ============ HELPER WIDGETS ============
  
  Widget _buildInfoBanner({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: color.withOpacity(0.1),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? subtitle,
    required VoidCallback onRefresh,
  }) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard({
    required Map<String, dynamic> device,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedDeviceId == device['deviceId'];
    final isConnecting = _isConnecting && isSelected;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF2D5F4C) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isConnecting ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D5F4C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  device['connectionType'] == 'cloud' ? Icons.cloud : Icons.wifi,
                  color: const Color(0xFF2D5F4C),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device['deviceName'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device['connectionType'] == 'local'
                          ? 'IP: ${device['ipAddress']}:${device['port']}'
                          : 'ID: ${device['deviceId']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ONLINE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isConnecting)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.chevron_right, color: Color(0xFF2D5F4C)),
            ],
          ),
        ),
      ),
    );
  }
}
