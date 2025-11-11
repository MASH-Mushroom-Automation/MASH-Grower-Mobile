import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/device_provisioning_service.dart';
import '../../../services/local_device_client.dart';
import '../../../core/utils/logger.dart';

class WiFiDeviceConnectionScreen extends StatefulWidget {
  const WiFiDeviceConnectionScreen({super.key});

  @override
  State<WiFiDeviceConnectionScreen> createState() => _WiFiDeviceConnectionScreenState();
}

class _WiFiDeviceConnectionScreenState extends State<WiFiDeviceConnectionScreen> {
  int _currentStep = 0;
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _selectedDevice;
  String? _selectedWiFi;
  final _wifiPasswordController = TextEditingController();
  final _deviceNameController = TextEditingController();

  // Device provisioning service
  late DeviceProvisioningService _provisioningService;
  
  List<WiFiNetworkInfo> _availableWiFi = [];

  @override
  void initState() {
    super.initState();
    _provisioningService = DeviceProvisioningService();
    _provisioningService.addListener(_onProvisioningStateChanged);
    _deviceNameController.text = 'My MASH Chamber';
  }

  @override
  void dispose() {
    _wifiPasswordController.dispose();
    _deviceNameController.dispose();
    _provisioningService.removeListener(_onProvisioningStateChanged);
    _provisioningService.dispose();
    super.dispose();
  }

  void _onProvisioningStateChanged() {
    if (!mounted) return;
    
    // Handle state changes
    if (_provisioningService.state == ProvisioningState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_provisioningService.errorMessage ?? 'An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scanForDevices() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Verify connection to provisioning device
      final connected = await _provisioningService.verifyProvisioningConnection();
      
      if (connected && _provisioningService.provisioningInfo != null) {
        setState(() {
          _selectedDevice = _provisioningService.provisioningInfo!.deviceId;
          _currentStep = 1;
        });
        
        // Automatically scan WiFi networks
        _scanWiFiNetworks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please connect to the device WiFi network in your phone settings'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      Logger.error('Failed to scan for devices: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to device: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _scanWiFiNetworks() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final networks = await _provisioningService.scanWiFiNetworks();
      setState(() {
        _availableWiFi = networks;
      });
    } catch (e) {
      Logger.error('Failed to scan WiFi networks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to scan WiFi networks: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _selectWiFi(String ssid) {
    setState(() {
      _selectedWiFi = ssid;
    });
  }

  void _connectDeviceToWiFi() async {
    if (_selectedWiFi == null) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      // Get user ID from auth provider
      // TODO: Replace with actual auth provider
      final userId = 'user_123';
      final deviceName = _deviceNameController.text.trim();
      if (deviceName.isEmpty) {
        throw Exception('Please enter a device name');
      }

      // Provision device
      final device = await _provisioningService.provisionDevice(
        ssid: _selectedWiFi!,
        password: _wifiPasswordController.text,
        userId: userId,
        deviceName: deviceName,
      );

      if (device != null && mounted) {
        // Success
        Navigator.pop(context, device);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device provisioned successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      } else if (mounted) {
        throw Exception('Failed to provision device');
      }
    } catch (e) {
      Logger.error('Failed to connect device to WiFi: $e');
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D5F4C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Connect Device',
          style: TextStyle(
            color: Color(0xFF2D5F4C),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildStepContent(),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1ConnectToDeviceWiFi();
      case 1:
        return _buildStep2SelectHomeWiFi();
      default:
        return _buildStep1ConnectToDeviceWiFi();
    }
  }

  // Step 1: Connect to Device's WiFi
  Widget _buildStep1ConnectToDeviceWiFi() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step Indicator
          _buildStepIndicator(1, 2),

          const SizedBox(height: 32),

          // Instruction Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2D5F4C).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2D5F4C), width: 2),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF2D5F4C),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Setup Instructions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5F4C),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '1. Power on your MASH device\n'
                  '2. Wait for the WiFi indicator to blink\n'
                  '3. The device will create its own WiFi network\n'
                  '4. Tap "Scan for Devices" below',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Scan Button
          ElevatedButton(
            onPressed: _isScanning ? null : _scanForDevices,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5F4C),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isScanning
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Scan for Devices',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),

          const SizedBox(height: 24),

          // Status message
          if (_selectedDevice != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4CAF50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Connected to device: $_selectedDevice',
                      style: const TextStyle(
                        color: Color(0xFF2D5F4C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_isScanning)
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D5F4C)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scanning for devices...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Step 2: Connect Device to Home WiFi
  Widget _buildStep2SelectHomeWiFi() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step Indicator
          _buildStepIndicator(2, 2),

          const SizedBox(height: 32),

          // Device Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D5F4C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.router,
                    color: Color(0xFF2D5F4C),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Connected to Device',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedDevice ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5F4C),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Select Your WiFi Network',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5F4C),
            ),
          ),

          const SizedBox(height: 12),

          // WiFi Networks List
          ..._availableWiFi.map((wifi) => _buildWiFiCard(wifi)),

          const SizedBox(height: 24),

          // Device Name Field
          TextField(
            controller: _deviceNameController,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Device Name',
              hintText: 'Enter a name for your device',
              prefixIcon: const Icon(Icons.label, color: Color(0xFF2D5F4C)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2D5F4C), width: 2),
              ),
              labelStyle: const TextStyle(color: Colors.black),
              hintStyle: const TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: 16),

          // WiFi Password Field
          if (_selectedWiFi != null) ...[
            TextField(
              controller: _wifiPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'WiFi Password',
                hintText: 'Enter password for $_selectedWiFi',
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF2D5F4C)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D5F4C), width: 2),
                ),
                labelStyle: const TextStyle(color: Colors.black),
                hintStyle: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Connect Button
          ElevatedButton(
            onPressed: (_selectedWiFi != null && !_isConnecting)
                ? _connectDeviceToWiFi
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5F4C),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                : const Text(
                    'Connect Device to WiFi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),

          if (_isConnecting) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Connecting device to WiFi...\nThis may take a few moments',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int current, int total) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index < current;
        final isCurrent = index == current - 1;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < total - 1 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isActive || isCurrent
                  ? const Color(0xFF2D5F4C)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }


  Widget _buildWiFiCard(WiFiNetworkInfo wifi) {
    final isSelected = _selectedWiFi == wifi.ssid;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected ? const Color(0xFF2D5F4C).withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _selectWiFi(wifi.ssid),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF2D5F4C) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.wifi,
                  color: isSelected ? const Color(0xFF2D5F4C) : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    wifi.ssid,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF2D5F4C) : Colors.black87,
                    ),
                  ),
                ),
                // Signal strength
                Row(
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.only(left: 2),
                      width: 4,
                      height: 8.0 + (index * 4),
                      decoration: BoxDecoration(
                        color: index < wifi.signalBars
                            ? const Color(0xFF2D5F4C)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                if (wifi.isSecured)
                  const Icon(Icons.lock, size: 16, color: Colors.grey),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
