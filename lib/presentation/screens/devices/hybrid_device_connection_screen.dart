import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/device_connection_service.dart';
import '../../../core/utils/logger.dart';
import '../../../services/bluetooth_device_service.dart';
import '../../providers/device_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import 'ble_wifi_provisioning_screen.dart';

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
  
  // Local Network
  final DeviceConnectionService _localService = DeviceConnectionService();
  List<Map<String, dynamic>> _localDevices = [];
  bool _isScanningLocal = false;
  
  // WiFi Networks (for testing without Pi)
  List<WiFiAccessPoint> _wifiNetworks = [];
  bool _isScanningWiFi = false;
  
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
  List<BluetoothMashDevice> _pairedDevices = [];
  bool _isScanningBluetooth = false;
  bool _loadingPairedDevices = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupBluetoothListener();
    
    // Auto-scan on load
    _scanLocalDevices();
    _loadPairedDevices();
    _scanWiFiNetworks(); // Also scan WiFi networks for testing
  }
  
  Future<void> _loadPairedDevices() async {
    setState(() => _loadingPairedDevices = true);
    
    try {
      final paired = await _bluetoothService.getPairedDevices();
      if (mounted) {
        setState(() {
          _pairedDevices = paired;
          _loadingPairedDevices = false;
        });
        Logger.info('Loaded ${paired.length} paired devices');
      }
    } catch (e) {
      Logger.error('Error loading paired devices: $e');
      if (mounted) {
        setState(() => _loadingPairedDevices = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ipController.dispose();
    _portController.dispose();
    _bluetoothService.dispose();
    super.dispose();
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

  // ============ CLOUD DEVICES - REMOVED ============
  // Cloud functionality removed to simplify and avoid backend dependency
  // Devices are now discovered via:
  // 1. Local Network (mDNS discovery)
  // 2. Bluetooth (BLE scanning)

  // Cloud device connection function removed

  // ============ OPEN SYSTEM SETTINGS ============
  
  Future<void> _openWiFiSettings() async {
    try {
      if (Platform.isAndroid) {
        // Android: Open WiFi settings using intent
        final uri = Uri.parse('android.settings.WIFI_SETTINGS');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          // Fallback: Open general settings
          await openAppSettings();
        }
      } else {
        // iOS: Open app settings (iOS doesn't allow direct WiFi settings)
        await openAppSettings();
      }
    } catch (e) {
      Logger.error('Failed to open WiFi settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WiFi settings. Please enable WiFi manually.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
  
  Future<void> _openBluetoothSettings() async {
    try {
      if (Platform.isAndroid) {
        // Android: Open Bluetooth settings using intent
        final uri = Uri.parse('android.settings.BLUETOOTH_SETTINGS');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          // Fallback: Open general settings
          await openAppSettings();
        }
      } else {
        // iOS: Open app settings (iOS doesn't allow direct Bluetooth settings)
        await openAppSettings();
      }
    } catch (e) {
      Logger.error('Failed to open Bluetooth settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Bluetooth settings. Please enable Bluetooth manually.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // ============ WIFI NETWORKS (For Testing Without Pi) ============
  
  Future<void> _scanWiFiNetworks() async {
    setState(() {
      _isScanningWiFi = true;
      _wifiNetworks = [];
    });

    try {
      Logger.info('Scanning WiFi networks on phone...');
      
      // Request location permission (required for WiFi scan on Android)
      final locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        final requested = await Permission.location.request();
        if (!requested.isGranted) {
          Logger.warning('Location permission denied - WiFi scan may not work');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission required for WiFi scanning'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }
      
      // Check if WiFi scan is available
      final canScan = await WiFiScan.instance.canGetScannedResults();
      if (canScan != CanGetScannedResults.yes) {
        Logger.warning('WiFi scanning not available: $canScan');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WiFi scanning not available. Please enable WiFi in Settings and grant location permission.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }
      
      // Start scan
      await WiFiScan.instance.startScan();
      
      // Wait a bit for scan to complete
      await Future.delayed(const Duration(seconds: 2));
      
      // Get results
      final results = await WiFiScan.instance.getScannedResults();
      
      setState(() {
        _wifiNetworks = results;
        _wifiNetworks.sort((a, b) => (b.level).compareTo(a.level)); // Sort by signal strength
      });
      
      Logger.info('Found ${_wifiNetworks.length} WiFi networks');
    } catch (e) {
      Logger.error('WiFi network scan failed: $e');
      // Don't show error to user - this is just for testing
    } finally {
      setState(() => _isScanningWiFi = false);
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
              Tab(icon: Icon(Icons.wifi), text: 'Local Network'),
              Tab(icon: Icon(Icons.bluetooth), text: 'Bluetooth'),
              Tab(icon: Icon(Icons.settings_ethernet), text: 'Manual IP'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLocalTab(),
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

  // ============ CLOUD TAB - REMOVED ============
  // Cloud functionality removed for simplicity

  // ============ LOCAL TAB ============
  
  Widget _buildLocalTab() {
    return Column(
      children: [
        _buildInfoBanner(
          icon: Icons.wifi,
          title: 'Local Network (Auto-Discovery)',
          description: 'Devices on same WiFi network',
          color: Colors.blue,
        ),
        
        // WiFi status info with button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'WiFi must be enabled to scan networks.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _openWiFiSettings,
                icon: const Icon(Icons.settings, size: 16),
                label: const Text('Open Settings'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
        ),
        
        // Refresh button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _localDevices.isEmpty 
                      ? 'No MASH devices found' 
                      : '${_localDevices.length} MASH device(s) found',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isScanningLocal ? null : _scanLocalDevices,
                icon: _isScanningLocal
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(_isScanningLocal ? 'Scanning...' : 'Scan Devices'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // MASH Devices Section
              if (_localDevices.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.devices, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'MASH Devices (${_localDevices.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._localDevices.map((device) => _buildDeviceCard(
                  device: device,
                  onTap: () => _connectToLocalDevice(
                    device['ipAddress'],
                    device['port'],
                  ),
                )),
                const SizedBox(height: 24),
              ],
              
              // WiFi Networks Section (for testing)
              Row(
                children: [
                  const Icon(Icons.wifi, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Available WiFi Networks (${_wifiNetworks.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  if (_isScanningWiFi)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18),
                      onPressed: _scanWiFiNetworks,
                      tooltip: 'Refresh WiFi networks',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (_wifiNetworks.isEmpty && !_isScanningWiFi)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.wifi_off, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No WiFi networks found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _scanWiFiNetworks,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Scan Again'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._wifiNetworks.take(20).map((network) => _buildWiFiNetworkCard(network)),
              
              // Empty State for MASH devices
              if (_localDevices.isEmpty && !_isScanningLocal) ...[
                const SizedBox(height: 24),
                _buildEmptyState(
                  icon: Icons.devices_other,
                  message: 'No MASH devices found',
                  subtitle: 'Make sure your Raspberry Pi is:\n• On the same WiFi network\n• Running mDNS service\n• Or use Manual IP tab',
                  onRefresh: _scanLocalDevices,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildWiFiNetworkCard(WiFiAccessPoint network) {
    final signalStrength = network.level;
    final signalColor = signalStrength > -50 
        ? Colors.green 
        : signalStrength > -70 
            ? Colors.orange 
            : Colors.red;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              network.capabilities.contains('WPA') || network.capabilities.contains('WEP')
                  ? Icons.lock
                  : Icons.lock_open,
              size: 20,
              color: signalColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    network.ssid.isEmpty ? '(Hidden Network)' : network.ssid,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.signal_cellular_alt,
                        size: 14,
                        color: signalColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${signalStrength} dBm',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        network.capabilities,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
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
    );
  }

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Bluetooth is disabled. Please enable it in Settings.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Open Settings',
                textColor: Colors.white,
                onPressed: _openBluetoothSettings,
              ),
            ),
          );
        }
        throw Exception('Bluetooth not available. Please enable Bluetooth in phone settings.');
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
    // Show WiFi provisioning dialog first
    final shouldProvision = await _showWiFiProvisioningDialog();
    
    if (shouldProvision != true) {
      Logger.info('User skipped WiFi provisioning for ${device.name}');
      return;
    }
    
    setState(() {
      _isConnecting = true;
      _selectedDeviceId = device.deviceId;
    });

    try {
      Logger.info('Opening BLE WiFi provisioning for: ${device.name}');
      
      // Check if BLE device is available
      if (device.device == null) {
        throw Exception('BLE device not available. Please scan again.');
      }
      
      // Navigate to BLE WiFi provisioning screen
      // This screen will:
      // 1. Connect to device via BLE
      // 2. Scan WiFi networks on phone
      // 3. Send credentials to Pi via BLE GATT
      final success = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BLEWiFiProvisioningScreen(
            device: device.device!,
            deviceName: device.name,
          ),
        ),
      );
      
      if (success == true && mounted) {
        Logger.info('WiFi provisioning completed successfully');
        
        // Save to device provider
        final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
        await deviceProvider.connectToDevice(
          deviceId: device.deviceId,
          deviceName: device.name,
          ipAddress: device.address,
          port: 0,
        );
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Device connected successfully!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
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

  // Note: _showPairingDialog removed - pairing is handled by system
  // Users can pair devices in phone settings if needed

  Future<bool?> _showWiFiProvisioningDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi, color: Color(0xFF2D5F4C)),
            SizedBox(width: 12),
            Text('Configure WiFi?'),
          ],
        ),
        content: const Text(
          'Would you like to configure WiFi on this device? '
          'This will allow the device to connect to your network and be accessible online.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5F4C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Configure WiFi'),
          ),
        ],
      ),
    );
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
        
        // Bluetooth status check
        FutureBuilder<bool>(
          future: _bluetoothService.isBluetoothAvailable(),
          builder: (context, snapshot) {
            if (snapshot.hasData && !snapshot.data!) {
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bluetooth_disabled, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bluetooth is disabled',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Please enable Bluetooth to scan for devices.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openBluetoothSettings,
                        icon: const Icon(Icons.bluetooth, size: 18),
                        label: const Text('Open Bluetooth Settings'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        
        // Refresh button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _bluetoothDevices.isEmpty 
                      ? 'No devices found' 
                      : '${_bluetoothDevices.length} device(s) found',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isScanningBluetooth ? null : _scanBluetoothDevices,
                icon: _isScanningBluetooth
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(_isScanningBluetooth ? 'Scanning...' : 'Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Paired Devices Section
              if (_pairedDevices.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.link, size: 20, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      'Paired Devices (${_pairedDevices.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._pairedDevices.map((device) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildBluetoothDeviceCard(
                    device: device,
                    onTap: () => _connectToBluetoothDevice(device),
                    isPaired: true,
                  ),
                )),
                const SizedBox(height: 24),
              ],
              
              // Available Devices Section
              if (_bluetoothDevices.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.bluetooth_searching, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Available Devices (${_bluetoothDevices.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._bluetoothDevices.map((device) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildBluetoothDeviceCard(
                    device: device,
                    onTap: () => _connectToBluetoothDevice(device),
                    isPaired: false,
                  ),
                )),
              ],
              
              // Empty State
              if (_pairedDevices.isEmpty && _bluetoothDevices.isEmpty && !_isScanningBluetooth)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No Bluetooth devices found',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pair device in phone settings first,\nthen tap Scan to find it',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              
              // Scanning Indicator
              if (_isScanningBluetooth)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Scanning for Bluetooth devices...'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBluetoothDeviceCard({
    required BluetoothMashDevice device,
    required VoidCallback onTap,
    bool isPaired = false,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            device.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isPaired)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple, width: 1),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.link, size: 12, color: Colors.purple),
                                SizedBox(width: 4),
                                Text(
                                  'Paired',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
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
