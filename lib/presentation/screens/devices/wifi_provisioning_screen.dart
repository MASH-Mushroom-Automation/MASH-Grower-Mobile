import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/utils/logger.dart';

/// WiFi Provisioning Screen
/// Allows user to configure WiFi on a newly paired IoT device via Bluetooth
class WiFiProvisioningScreen extends StatefulWidget {
  final String deviceIp;
  final String deviceName;
  
  const WiFiProvisioningScreen({
    super.key,
    required this.deviceIp,
    required this.deviceName,
  });

  @override
  State<WiFiProvisioningScreen> createState() => _WiFiProvisioningScreenState();
}

class _WiFiProvisioningScreenState extends State<WiFiProvisioningScreen> {
  final Dio _dio = Dio();
  
  bool _isScanning = false;
  bool _isConnecting = false;
  List<WiFiNetwork> _networks = [];
  WiFiNetwork? _selectedNetwork;
  
  final _passwordController = TextEditingController();
  final _manualSsidController = TextEditingController();
  final _manualPasswordController = TextEditingController();
  
  bool _showManualEntry = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _scanWiFiNetworks();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _manualSsidController.dispose();
    _manualPasswordController.dispose();
    super.dispose();
  }

  Future<void> _scanWiFiNetworks() async {
    setState(() {
      _isScanning = true;
      _networks = [];
    });

    try {
      Logger.info('Scanning for WiFi networks on device: ${widget.deviceIp}');
      
      final response = await _dio.get(
        'http://${widget.deviceIp}:5000/api/wifi/scan',
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data['success'] == true) {
        final networksData = response.data['data']['networks'] as List;
        setState(() {
          _networks = networksData
              .map((n) => WiFiNetwork.fromJson(n))
              .toList();
        });
        Logger.info('Found ${_networks.length} WiFi networks');
      } else {
        throw Exception('Failed to scan WiFi networks');
      }
    } catch (e) {
      Logger.error('WiFi scan failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan WiFi networks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _connectToWiFi(String ssid, String password) async {
    setState(() => _isConnecting = true);

    try {
      Logger.info('Connecting device to WiFi: $ssid');
      
      final response = await _dio.post(
        'http://${widget.deviceIp}:5000/api/wifi/connect',
        data: {
          'ssid': ssid,
          'password': password,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );

      if (response.data['success'] == true) {
        final ipAddress = response.data['data']['ip_address'];
        Logger.info('Device connected to WiFi successfully: $ipAddress');
        
        if (mounted) {
          _showSuccessDialog(ssid, ipAddress);
        }
      } else {
        throw Exception(response.data['error'] ?? 'Connection failed');
      }
    } catch (e) {
      Logger.error('WiFi connection failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  void _showPasswordDialog(WiFiNetwork network) {
    _passwordController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect to ${network.ssid}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wifi,
                  color: _getSignalColor(network.signal),
                ),
                const SizedBox(width: 8),
                Text('${network.signal}%'),
                const Spacer(),
                if (network.secured)
                  const Icon(Icons.lock, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
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
              Navigator.pop(context);
              _connectToWiFi(network.ssid, _passwordController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5F4C),
            ),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String ssid, String ipAddress) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('WiFi Connected!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your device is now connected to WiFi and accessible online.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Network', ssid),
            _buildInfoRow('IP Address', ipAddress),
            _buildInfoRow('Device', widget.deviceName),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can now disconnect Bluetooth and use WiFi connection.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close provisioning screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5F4C),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Continue to Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(int signal) {
    if (signal >= 70) return Colors.green;
    if (signal >= 50) return Colors.orange;
    return Colors.red;
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
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bluetooth_connected, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Connected via Bluetooth',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            widget.deviceName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select a WiFi network to connect your device to the internet.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          // Scan Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _scanWiFiNetworks,
                    icon: _isScanning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
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
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showManualEntry = !_showManualEntry;
                    });
                  },
                  icon: Icon(
                    _showManualEntry ? Icons.list : Icons.edit,
                    color: const Color(0xFF2D5F4C),
                  ),
                  tooltip: _showManualEntry ? 'Show network list' : 'Manual entry',
                ),
              ],
            ),
          ),

          // Manual Entry or Network List
          Expanded(
            child: _showManualEntry
                ? _buildManualEntry()
                : _buildNetworkList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkList() {
    if (_isScanning) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Scanning for WiFi networks...'),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Make sure WiFi is enabled on the device',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _scanWiFiNetworks,
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5F4C),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _networks.length,
      itemBuilder: (context, index) {
        final network = _networks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              Icons.wifi,
              color: _getSignalColor(network.signal),
            ),
            title: Text(
              network.ssid,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text('Signal: ${network.signal}%'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (network.secured)
                  const Icon(Icons.lock, size: 16),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: _isConnecting
                ? null
                : () {
                    if (network.secured) {
                      _showPasswordDialog(network);
                    } else {
                      _connectToWiFi(network.ssid, '');
                    }
                  },
          ),
        );
      },
    );
  }

  Widget _buildManualEntry() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Manual WiFi Configuration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isConnecting
                ? null
                : () {
                    if (_manualSsidController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter network name'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    _connectToWiFi(
                      _manualSsidController.text,
                      _manualPasswordController.text,
                    );
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Connect to WiFi'),
          ),
        ],
      ),
    );
  }
}

/// WiFi Network Model
class WiFiNetwork {
  final String ssid;
  final int signal;
  final String security;
  final bool secured;

  WiFiNetwork({
    required this.ssid,
    required this.signal,
    required this.security,
    required this.secured,
  });

  factory WiFiNetwork.fromJson(Map<String, dynamic> json) {
    return WiFiNetwork(
      ssid: json['ssid'] as String,
      signal: json['signal'] as int,
      security: json['security'] as String? ?? '',
      secured: json['secured'] as bool? ?? false,
    );
  }
}
