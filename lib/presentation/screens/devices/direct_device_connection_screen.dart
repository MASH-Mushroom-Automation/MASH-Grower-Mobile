import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/device_connection_service.dart';
import '../../../core/utils/logger.dart';
import '../../providers/device_provider.dart';

class DirectDeviceConnectionScreen extends StatefulWidget {
  const DirectDeviceConnectionScreen({super.key});

  @override
  State<DirectDeviceConnectionScreen> createState() => _DirectDeviceConnectionScreenState();
}

class _DirectDeviceConnectionScreenState extends State<DirectDeviceConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceIdController = TextEditingController();
  final _deviceNameController = TextEditingController();
  final _ipAddressController = TextEditingController();
  final _portController = TextEditingController(text: '5000');
  
  bool _isConnecting = false;
  bool _isTesting = false;
  String? _connectionStatus;

  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceNameController.dispose();
    _ipAddressController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTesting = true;
      _connectionStatus = null;
    });

    try {
      final ipAddress = _ipAddressController.text.trim();
      final port = int.parse(_portController.text.trim());

      Logger.info('Testing connection to $ipAddress:$port');

      final deviceService = DeviceConnectionService();
      final connected = await deviceService.connect(ipAddress, port);

      if (connected) {
        // Get device status to verify
        final status = await deviceService.getDeviceStatus();
        
        setState(() {
          _connectionStatus = 'Connected! Device: ${status['deviceName']}';
          _deviceIdController.text = status['deviceId'] ?? '';
          _deviceNameController.text = status['deviceName'] ?? '';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Connection successful!'),
              backgroundColor: Color(0xFF4CAF50),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() {
          _connectionStatus = 'Connection failed';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Could not connect to device'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      Logger.error('Connection test failed: $e');
      setState(() {
        _connectionStatus = 'Error: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _connectDevice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      final ipAddress = _ipAddressController.text.trim();
      final port = int.parse(_portController.text.trim());
      final deviceId = _deviceIdController.text.trim();
      final deviceName = _deviceNameController.text.trim();

      Logger.info('Connecting to device: $deviceId at $ipAddress:$port');

      // Use DeviceProvider to connect
      final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
      final connected = await deviceProvider.connectToDevice(
        deviceId: deviceId,
        deviceName: deviceName,
        ipAddress: ipAddress,
        port: port,
      );

      if (connected && mounted) {
        // Navigate back to home
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Device connected successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      } else if (mounted) {
        throw Exception('Failed to connect to device');
      }
    } catch (e) {
      Logger.error('Failed to connect device: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Connect Device'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: const Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Setup Instructions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '1. Ensure your MASH device is powered on\n'
                        '2. Connect your phone to the same WiFi network\n'
                        '3. Find your device IP address (check device display or router)\n'
                        '4. Enter the IP address below and tap "Test Connection"',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // IP Address Input
              TextFormField(
                controller: _ipAddressController,
                decoration: InputDecoration(
                  labelText: 'Device IP Address',
                  hintText: '192.168.1.100',
                  prefixIcon: const Icon(Icons.router),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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

              // Port Input
              TextFormField(
                controller: _portController,
                decoration: InputDecoration(
                  labelText: 'Port',
                  hintText: '5000',
                  prefixIcon: const Icon(Icons.settings_ethernet),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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

              const SizedBox(height: 16),

              // Test Connection Button
              ElevatedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.wifi_find),
                label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Connection Status
              if (_connectionStatus != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _connectionStatus!.contains('Connected')
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _connectionStatus!.contains('Connected')
                          ? const Color(0xFF4CAF50)
                          : Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _connectionStatus!.contains('Connected')
                            ? Icons.check_circle
                            : Icons.error,
                        color: _connectionStatus!.contains('Connected')
                            ? const Color(0xFF4CAF50)
                            : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _connectionStatus!,
                          style: TextStyle(
                            color: _connectionStatus!.contains('Connected')
                                ? const Color(0xFF2E7D32)
                                : Colors.red[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Device Details (shown after successful test)
              if (_connectionStatus?.contains('Connected') == true) ...[
                const Text(
                  'Device Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _deviceIdController,
                  decoration: InputDecoration(
                    labelText: 'Device ID',
                    prefixIcon: const Icon(Icons.fingerprint),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  readOnly: true,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _deviceNameController,
                  decoration: InputDecoration(
                    labelText: 'Device Name',
                    hintText: 'My Mushroom Chamber',
                    prefixIcon: const Icon(Icons.label),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter device name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Connect Button
                ElevatedButton.icon(
                  onPressed: _isConnecting ? null : _connectDevice,
                  icon: _isConnecting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.link),
                  label: Text(_isConnecting ? 'Connecting...' : 'Connect Device'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
