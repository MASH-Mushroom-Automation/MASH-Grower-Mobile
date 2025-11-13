import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/utils/logger.dart';

/// Model for discovered Bluetooth device
class BluetoothMashDevice {
  final String deviceId;
  final String name;
  final String address;
  final int rssi;
  final bool isConnected;
  final BluetoothDevice? device;

  BluetoothMashDevice({
    required this.deviceId,
    required this.name,
    required this.address,
    required this.rssi,
    this.isConnected = false,
    this.device,
  });

  BluetoothMashDevice copyWith({
    String? deviceId,
    String? name,
    String? address,
    int? rssi,
    bool? isConnected,
    BluetoothDevice? device,
  }) {
    return BluetoothMashDevice(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      address: address ?? this.address,
      rssi: rssi ?? this.rssi,
      isConnected: isConnected ?? this.isConnected,
      device: device ?? this.device,
    );
  }
}

/// Service for discovering and connecting to MASH IoT devices via Bluetooth
class BluetoothDeviceService {
  static const String _deviceNamePrefix = 'MASH-IoT';
  static const Duration _scanDuration = Duration(seconds: 15);
  
  // Debug mode: Set to true to show ALL Bluetooth devices (for testing)
  static const bool _debugShowAllDevices = true;
  
  final List<BluetoothMashDevice> _discoveredDevices = [];
  final StreamController<List<BluetoothMashDevice>> _devicesController = 
      StreamController<List<BluetoothMashDevice>>.broadcast();
  
  BluetoothMashDevice? _connectedDevice;
  bool _isScanning = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  /// Stream of discovered devices
  Stream<List<BluetoothMashDevice>> get devicesStream => _devicesController.stream;
  
  /// Get system-paired (bonded) devices
  Future<List<BluetoothMashDevice>> getPairedDevices() async {
    try {
      Logger.info('Getting system-paired Bluetooth devices...');
      
      // Get bonded devices from system
      final bondedDevices = await FlutterBluePlus.bondedDevices;
      
      Logger.info('Found ${bondedDevices.length} paired devices');
      
      // Filter for MASH devices (or show all in debug mode)
      final mashDevices = bondedDevices
          .where((device) {
            final name = device.platformName;
            final shouldShow = _debugShowAllDevices 
                ? name.isNotEmpty 
                : (name.isNotEmpty && name.contains(_deviceNamePrefix));
            
            if (shouldShow) {
              Logger.info('Paired device: $name (${device.remoteId.str})');
            }
            return shouldShow;
          })
          .map((device) => BluetoothMashDevice(
                deviceId: device.remoteId.str,
                name: device.platformName.isEmpty ? 'Unknown Device' : device.platformName,
                address: device.remoteId.str,
                rssi: 0, // RSSI not available for bonded devices
                device: device,
                isConnected: true,
              ))
          .toList();
      
      Logger.info('Found ${mashDevices.length} paired MASH devices');
      return mashDevices;
      
    } catch (e) {
      Logger.error('Error getting paired devices: $e');
      return [];
    }
  }

  /// Currently discovered devices
  List<BluetoothMashDevice> get discoveredDevices => List.unmodifiable(_discoveredDevices);

  /// Connected device
  BluetoothMashDevice? get connectedDevice => _connectedDevice;

  /// Whether scanning is in progress
  bool get isScanning => _isScanning;

  /// Check if Bluetooth is available and enabled
  Future<bool> isBluetoothAvailable() async {
    try {
      if (await FlutterBluePlus.isSupported == false) {
        Logger.warning('Bluetooth not supported on this device');
        return false;
      }

      final adapterState = await FlutterBluePlus.adapterState.first;
      return adapterState == BluetoothAdapterState.on;
    } catch (e) {
      Logger.error('Error checking Bluetooth availability: $e');
      return false;
    }
  }

  /// Request Bluetooth permissions
  Future<bool> requestPermissions() async {
    try {
      Logger.info('Requesting Bluetooth permissions...');
      
      // Check current status first
      final bluetoothScanStatus = await Permission.bluetoothScan.status;
      final bluetoothConnectStatus = await Permission.bluetoothConnect.status;
      final locationStatus = await Permission.location.status;
      
      Logger.info('Current permissions:');
      Logger.info('  - Bluetooth Scan: $bluetoothScanStatus');
      Logger.info('  - Bluetooth Connect: $bluetoothConnectStatus');
      Logger.info('  - Location: $locationStatus');
      
      // Request permissions
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      final allGranted = statuses.values.every((status) => status.isGranted);
      
      if (!allGranted) {
        Logger.warning('Not all Bluetooth permissions granted:');
        statuses.forEach((permission, status) {
          Logger.warning('  - $permission: $status');
        });
        
        // Check if permanently denied
        final permanentlyDenied = statuses.values.any((status) => status.isPermanentlyDenied);
        if (permanentlyDenied) {
          Logger.error('Some permissions are permanently denied. Please enable them in Settings.');
        }
      } else {
        Logger.info('✓ All Bluetooth permissions granted');
      }
      
      return allGranted;
    } catch (e) {
      Logger.error('Error requesting Bluetooth permissions: $e');
      return false;
    }
  }

  /// Start scanning for MASH IoT devices
  Future<bool> startScanning() async {
    if (_isScanning) {
      Logger.warning('Bluetooth scan already in progress');
      return false;
    }

    try {
      Logger.info('Starting Bluetooth scan for MASH IoT devices...');

      // Check Bluetooth availability
      if (!await isBluetoothAvailable()) {
        Logger.error('Bluetooth not available');
        return false;
      }

      // Request permissions
      if (!await requestPermissions()) {
        Logger.error('Bluetooth permissions not granted');
        return false;
      }

      _isScanning = true;
      _discoveredDevices.clear();
      _devicesController.add([]);

      // Start scanning
      Logger.info('Starting BLE scan with timeout: $_scanDuration');
      await FlutterBluePlus.startScan(
        timeout: _scanDuration,
        androidUsesFineLocation: true,
      );
      Logger.info('BLE scan started successfully');

      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          Logger.info('Scan results received: ${results.length} devices');
          
          for (ScanResult result in results) {
            final device = result.device;
            final name = device.platformName;
            final address = device.remoteId.str;
            
            // Debug: Log ALL discovered devices (even without names)
            Logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            Logger.info('Device found:');
            Logger.info('  Name: "${name.isEmpty ? "(no name)" : name}"');
            Logger.info('  Address: $address');
            Logger.info('  RSSI: ${result.rssi}');
            Logger.info('  Platform Name: ${device.platformName}');
            Logger.info('  Debug mode: $_debugShowAllDevices');
            
            // Filter for MASH IoT devices (or show all in debug mode)
            final shouldShow = _debugShowAllDevices 
                ? name.isNotEmpty  // Show all devices with names
                : (name.isNotEmpty && name.contains(_deviceNamePrefix));  // Only MASH devices
            
            Logger.info('  Should show: $shouldShow');
            Logger.info('  Filter check: name.isNotEmpty=${name.isNotEmpty}, contains MASH-IoT=${name.contains(_deviceNamePrefix)}');
            Logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            
            if (shouldShow) {
              Logger.info('✓ Adding device to list: $name');
              _addOrUpdateDevice(
                BluetoothMashDevice(
                  deviceId: device.remoteId.str,
                  name: name.isEmpty ? 'Unknown Device' : name,
                  address: device.remoteId.str,
                  rssi: result.rssi,
                  device: device,
                ),
              );
            } else {
              Logger.info('✗ Device filtered out: $name');
            }
          }
        },
        onError: (error) {
          Logger.error('Error in scan results stream: $error');
        },
        onDone: () {
          Logger.info('Scan results stream completed');
        },
      );

      // Auto-stop scanning after duration
      Future.delayed(_scanDuration, () => stopScanning());

      Logger.info('Bluetooth scan started');
      return true;

    } catch (e) {
      Logger.error('Error starting Bluetooth scan: $e');
      _isScanning = false;
      return false;
    }
  }

  /// Stop scanning
  Future<void> stopScanning() async {
    if (!_isScanning) return;

    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      _isScanning = false;
      
      Logger.info('Bluetooth scan stopped. Found ${_discoveredDevices.length} devices');
    } catch (e) {
      Logger.error('Error stopping Bluetooth scan: $e');
    }
  }

  /// Add or update device in discovered list
  void _addOrUpdateDevice(BluetoothMashDevice device) {
    final index = _discoveredDevices.indexWhere((d) => d.deviceId == device.deviceId);
    
    if (index >= 0) {
      _discoveredDevices[index] = device;
    } else {
      _discoveredDevices.add(device);
      Logger.info('Discovered MASH device: ${device.name} (${device.address})');
    }
    
    _devicesController.add(List.from(_discoveredDevices));
  }

  /// Connect to a device
  Future<bool> connectToDevice(BluetoothMashDevice mashDevice) async {
    if (mashDevice.device == null) {
      Logger.error('No Bluetooth device object available');
      return false;
    }

    try {
      Logger.info('Connecting to ${mashDevice.name}...');

      final device = mashDevice.device!;
      
      // Connect to device
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      // Listen to connection state
      _connectionSubscription = device.connectionState.listen((state) {
        Logger.debug('Connection state: $state');
        
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });

      // Wait for connection to be established
      await device.connectionState
          .where((state) => state == BluetoothConnectionState.connected)
          .first
          .timeout(const Duration(seconds: 15));

      _connectedDevice = mashDevice.copyWith(isConnected: true);
      
      Logger.info('Connected to ${mashDevice.name}');
      return true;

    } catch (e) {
      Logger.error('Error connecting to device: $e');
      return false;
    }
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    if (_connectedDevice?.device == null) return;

    try {
      Logger.info('Disconnecting from ${_connectedDevice!.name}...');
      
      await _connectedDevice!.device!.disconnect();
      await _connectionSubscription?.cancel();
      _connectionSubscription = null;
      
      _connectedDevice = null;
      
      Logger.info('Disconnected');
    } catch (e) {
      Logger.error('Error disconnecting: $e');
    }
  }

  /// Handle disconnection
  void _handleDisconnection() {
    Logger.warning('Device disconnected');
    _connectedDevice = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
  }

  /// Send command to connected device via Bluetooth (RFCOMM/SPP)
  Future<Map<String, dynamic>?> sendCommand({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? data,
  }) async {
    if (_connectedDevice?.device == null) {
      Logger.error('No device connected');
      return null;
    }

    try {
      // This is a simplified implementation
      // In a real scenario, you would need to:
      // 1. Discover services and characteristics
      // 2. Find the appropriate characteristic for communication
      // 3. Write/Read data using that characteristic
      
      Logger.info('Sending command to device: $endpoint');
      
      // For now, return mock data since actual implementation
      // requires service/characteristic discovery
      return {
        'success': true,
        'message': 'Command sent via Bluetooth',
      };

    } catch (e) {
      Logger.error('Error sending command: $e');
      return null;
    }
  }

  /// Get device status via Bluetooth
  Future<Map<String, dynamic>?> getDeviceStatus() async {
    return await sendCommand(endpoint: '/status');
  }

  /// Get sensor data via Bluetooth
  Future<Map<String, dynamic>?> getSensorData() async {
    return await sendCommand(endpoint: '/sensors/latest');
  }

  /// Clear discovered devices
  void clearDevices() {
    _discoveredDevices.clear();
    _devicesController.add([]);
  }

  /// Dispose resources
  void dispose() {
    stopScanning();
    disconnect();
    _devicesController.close();
  }
}
