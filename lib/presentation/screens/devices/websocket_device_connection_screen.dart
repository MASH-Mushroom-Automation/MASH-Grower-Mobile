import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/websocket_device_service.dart';
import '../../../core/utils/logger.dart';
import '../../providers/auth_provider.dart';
import '../../providers/device_provider.dart';

/// WebSocket-based device connection screen
/// User-friendly alternative to manual IP entry
class WebSocketDeviceConnectionScreen extends StatefulWidget {
  const WebSocketDeviceConnectionScreen({super.key});

  @override
  State<WebSocketDeviceConnectionScreen> createState() => _WebSocketDeviceConnectionScreenState();
}

class _WebSocketDeviceConnectionScreenState extends State<WebSocketDeviceConnectionScreen> {
  final WebSocketDeviceService _wsService = WebSocketDeviceService();
  
  bool _isScanning = false;
  bool _isConnecting = false;
  List<Map<String, dynamic>> _availableDevices = [];
  String? _selectedDeviceId;
  
  // WebSocket server URL - Update this with your backend URL
  static const String _wsServerUrl = 'ws://localhost:8080/ws/device';
  // For production: 'wss://your-backend.com/ws/device'

  @override
  void initState() {
    super.initState();
    _setupWebSocketCallbacks();
    _scanForDevices();
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }

  void _setupWebSocketCallbacks() {
    _wsService.onConnected = () {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connected to device!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        
        // Navigate back to home
        Navigator.pop(context);
      }
    };
    
    _wsService.onError = (error) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    };
    
    _wsService.onDisconnected = () {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    };
  }

  Future<void> _scanForDevices() async {
    setState(() {
      _isScanning = true;
      _availableDevices = [];
    });

    try {
      // TODO: Call backend API to get list of available devices
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _availableDevices = [
          {
            'deviceId': 'chamber-001',
            'deviceName': 'Chamber 1',
            'status': 'online',
            'mode': 'FRUITING',
            'lastSeen': DateTime.now().subtract(const Duration(minutes: 2)),
          },
          {
            'deviceId': 'chamber-002',
            'deviceName': 'Chamber 2',
            'status': 'online',
            'mode': 'SPAWNING',
            'lastSeen': DateTime.now().subtract(const Duration(minutes: 5)),
          },
        ];
      });
      
    } catch (e) {
      Logger.error('Failed to scan for devices: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _connectToDevice(String deviceId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isConnecting = true;
      _selectedDeviceId = deviceId;
    });

    try {
      // TODO: Get JWT token from secure storage
      final token = 'your-jwt-token'; // Replace with actual token
      
      final connected = await _wsService.connect(
        wsUrl: _wsServerUrl,
        deviceId: deviceId,
        userId: authProvider.user!.id,
        token: token,
      );

      if (!connected) {
        throw Exception('Failed to establish WebSocket connection');
      }
      
    } catch (e) {
      Logger.error('Connection failed: $e');
      setState(() {
        _isConnecting = false;
        _selectedDeviceId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Chamber'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _scanForDevices,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2D5F4C).withOpacity(0.1),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF2D5F4C),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WebSocket Connection',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5F4C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No IP address needed! Devices are auto-discovered.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Scanning Indicator
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Scanning for devices...'),
                ],
              ),
            ),
          
          // Device List
          if (!_isScanning && _availableDevices.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.devices_other,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No devices found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Make sure your chamber is online',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _scanForDevices,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Scan Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5F4C),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (!_isScanning && _availableDevices.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _availableDevices.length,
                itemBuilder: (context, index) {
                  final device = _availableDevices[index];
                  final isSelected = _selectedDeviceId == device['deviceId'];
                  final isConnecting = _isConnecting && isSelected;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isSelected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected 
                            ? const Color(0xFF2D5F4C) 
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: isConnecting 
                          ? null 
                          : () => _connectToDevice(device['deviceId']),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Device Icon
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D5F4C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.device_hub,
                                color: Color(0xFF2D5F4C),
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Device Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device['deviceName'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: ${device['deviceId']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: device['status'] == 'online'
                                              ? Colors.green
                                              : Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        device['status'].toString().toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: device['status'] == 'online'
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Mode: ${device['mode']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Connect Button
                            if (isConnecting)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF2D5F4C),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
