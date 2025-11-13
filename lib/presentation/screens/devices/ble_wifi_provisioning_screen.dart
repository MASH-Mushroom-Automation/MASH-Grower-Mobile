import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart' as http;
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/logger.dart';
import '../../../services/bluetooth_device_service.dart';

/// BLE WiFi Provisioning Screen
/// Uses phone's WiFi scan and sends credentials to Pi via HTTP over Bluetooth network
class BLEWiFiProvisioningScreen extends StatefulWidget {
  final BluetoothDevice device;
  final String deviceName;
  
  const BLEWiFiProvisioningScreen({
    super.key,
    required this.device,
    required this.deviceName,
  });

  @override
  State<BLEWiFiProvisioningScreen> createState() => _BLEWiFiProvisioningScreenState();
}

class _BLEWiFiProvisioningScreenState extends State<BLEWiFiProvisioningScreen> {
  bool _isScanning = false;
  bool _isConnecting = false;
  List<WiFiAccessPoint> _networks = [];
  WiFiAccessPoint? _selectedNetwork;
  
  final _passwordController = TextEditingController();
  final _manualSsidController = TextEditingController();
  final _manualPasswordController = TextEditingController();
  
  bool _showManualEntry = false;
  bool _obscurePassword = true;
  
  // BLE connection state
  bool _isBleConnected = false;
  
  // Pi's Bluetooth network IP (when connected via Bluetooth)
  static const String PI_BLUETOOTH_IP = '192.168.44.1';
  static const int PI_HTTP_PORT = 5000;

  @override
  void initState() {
    super.initState();
    _connectToBLE();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _manualSsidController.dispose();
    _manualPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _connectToBLE() async {
    try {
      Logger.info('Checking Bluetooth connection to: ${widget.deviceName}');
      
      // Check if already connected
      final connectionState = await widget.device.connectionState.first;
      if (connectionState == BluetoothConnectionState.connected) {
        Logger.info('Already connected via Bluetooth');
        setState(() => _isBleConnected = true);
        _scanPhoneWiFi();
        return;
      }
      
      // Connect to device (for Bluetooth network)
      await widget.device.connect(timeout: const Duration(seconds: 15));
      Logger.info('Connected via Bluetooth');
      
      setState(() => _isBleConnected = true);
      
      // Start WiFi scan on phone
      _scanPhoneWiFi();
      
    } catch (e) {
      Logger.error('Bluetooth connection failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendWiFiCredentialsBLE(String ssid, String password) async {
    if (!_isBleConnected) {
      throw Exception('Not connected via Bluetooth');
    }
    
    setState(() => _isConnecting = true);

    try {
      Logger.info('Sending WiFi credentials via HTTP: $ssid');
      Logger.info('Connecting to http://$PI_BLUETOOTH_IP:$PI_HTTP_PORT/api/wifi/connect');
      
      // Send HTTP POST to Pi's WiFi API
      final response = await http.post(
        Uri.parse('http://$PI_BLUETOOTH_IP:$PI_HTTP_PORT/api/wifi/connect'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ssid': ssid,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));
      
      Logger.info('HTTP response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        Logger.info('Response body: $result');
        
        if (result['success'] == true) {
          Logger.info('WiFi connection successful!');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('WiFi configured successfully!'),
                backgroundColor: Color(0xFF4CAF50),
                duration: Duration(seconds: 3),
              ),
            );
            
            // Wait a bit then go back
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.pop(context, true);
            }
          }
        } else {
          throw Exception(result['message'] ?? 'Failed to connect to WiFi');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      
    } catch (e) {
      Logger.error('Failed to configure WiFi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to configure WiFi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  Future<void> _scanPhoneWiFi() async {
    setState(() {
      _isScanning = true;
      _networks = [];
    });

    try {
      Logger.info('Scanning WiFi networks on phone...');
      
      // Request location permission (required for WiFi scan on Android)
      final locationStatus = await Permission.location.request();
      if (!locationStatus.isGranted) {
        throw Exception('Location permission required for WiFi scan');
      }
      
      // Check if WiFi scan is available
      final canScan = await WiFiScan.instance.canGetScannedResults();
      if (canScan != CanGetScannedResults.yes) {
        throw Exception('WiFi scanning not available');
      }
      
      // Start scan
      await WiFiScan.instance.startScan();
      
      // Wait a bit for scan to complete
      await Future.delayed(const Duration(seconds: 2));
      
      // Get results
      final results = await WiFiScan.instance.getScannedResults();
      
      setState(() {
        _networks = results;
        _networks.sort((a, b) => (b.level).compareTo(a.level)); // Sort by signal strength
      });
      
      Logger.info('Found ${_networks.length} WiFi networks on phone');
      
    } catch (e) {
      Logger.error('WiFi scan failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan WiFi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => _isScanning = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure WiFi'),
        backgroundColor: const Color(0xFF2D5F4C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Connection Status
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFE3F2FD),
            child: Row(
              children: [
                Icon(
                  _isBleConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching,
                  color: _isBleConnected ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Connected via Bluetooth',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        widget.deviceName,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select a WiFi network from your phone to connect your device to the internet.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          
          // Scan Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _scanPhoneWiFi,
                    icon: _isScanning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(_isScanning ? 'Scanning...' : 'Scan WiFi Networks'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5F4C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    setState(() => _showManualEntry = !_showManualEntry);
                  },
                  icon: const Icon(Icons.edit),
                  tooltip: 'Manual entry',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // WiFi Networks List or Manual Entry
          Expanded(
            child: _showManualEntry
                ? _buildManualEntry()
                : _buildNetworksList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNetworksList() {
    if (_isScanning && _networks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Scanning for WiFi networks on your phone...'),
          ],
        ),
      );
    }
    
    if (_networks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No WiFi networks found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap Scan to search for networks',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _networks.length,
      itemBuilder: (context, index) {
        final network = _networks[index];
        return _buildNetworkCard(network);
      },
    );
  }
  
  Widget _buildNetworkCard(WiFiAccessPoint network) {
    final signalStrength = network.level;
    final isSecure = network.capabilities.contains('WPA') || 
                     network.capabilities.contains('WEP');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          isSecure ? Icons.wifi_lock : Icons.wifi,
          color: signalStrength > -60 ? Colors.green : 
                 signalStrength > -70 ? Colors.orange : Colors.red,
        ),
        title: Text(
          network.ssid,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Signal: $signalStrength dBm${isSecure ? ' • Secured' : ''}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showPasswordDialog(network.ssid),
      ),
    );
  }
  
  Widget _buildManualEntry() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manual WiFi Configuration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter WiFi credentials manually if your network is hidden or not in the list.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          TextField(
            controller: _manualSsidController,
            decoration: const InputDecoration(
              labelText: 'Network Name (SSID)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.wifi),
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _manualPasswordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isConnecting
                  ? null
                  : () {
                      final ssid = _manualSsidController.text.trim();
                      final password = _manualPasswordController.text;
                      
                      if (ssid.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter network name'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      
                      _sendWiFiCredentialsBLE(ssid, password);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5F4C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isConnecting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Connect to WiFi'),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showPasswordDialog(String ssid) {
    _passwordController.clear();
    bool obscurePassword = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Connect to $ssid'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setDialogState(() => obscurePassword = !obscurePassword);
                    },
                  ),
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
                final password = _passwordController.text;
                Navigator.pop(context);
                _sendWiFiCredentialsBLE(ssid, password);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5F4C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }
}
