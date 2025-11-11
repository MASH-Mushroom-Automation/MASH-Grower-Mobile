import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/utils/logger.dart';
import 'local_device_client.dart';
import 'mdns_discovery_service.dart';
import 'bluetooth_device_service.dart';

/// Connection type enum
enum ConnectionType {
  wifi,
  bluetooth,
  offline,
  none
}

/// Connection status model
class ConnectionStatus {
  final ConnectionType type;
  final bool isConnected;
  final String? deviceId;
  final String? deviceName;
  final String? address;
  final bool isOnlineMode;

  ConnectionStatus({
    required this.type,
    required this.isConnected,
    this.deviceId,
    this.deviceName,
    this.address,
    this.isOnlineMode = true,
  });

  bool get canAccessDevice => isConnected || type == ConnectionType.bluetooth;
  bool get hasInternet => isOnlineMode && type == ConnectionType.wifi;
}

/// Manages device connections via WiFi or Bluetooth with automatic fallback
class DeviceConnectionManager {
  final MDNSDiscoveryService _mdnsService;
  final BluetoothDeviceService _bluetoothService;
  final Connectivity _connectivity;
  
  LocalDeviceClient? _wifiClient;
  ConnectionType _currentConnectionType = ConnectionType.none;
  String? _connectedDeviceId;
  
  final StreamController<ConnectionStatus> _connectionStatusController = 
      StreamController<ConnectionStatus>.broadcast();

  DeviceConnectionManager({
    MDNSDiscoveryService? mdnsService,
    BluetoothDeviceService? bluetoothService,
    Connectivity? connectivity,
  })  : _mdnsService = mdnsService ?? MDNSDiscoveryService(),
        _bluetoothService = bluetoothService ?? BluetoothDeviceService(),
        _connectivity = connectivity ?? Connectivity();

  /// Stream of connection status changes
  Stream<ConnectionStatus> get connectionStatusStream => _connectionStatusController.stream;

  /// Current connection type
  ConnectionType get currentConnectionType => _currentConnectionType;

  /// Connected device ID
  String? get connectedDeviceId => _connectedDeviceId;

  /// Check if connected to device
  bool get isConnected => _currentConnectionType != ConnectionType.none;

  /// Get current connection status
  ConnectionStatus getConnectionStatus() {
    switch (_currentConnectionType) {
      case ConnectionType.wifi:
        return ConnectionStatus(
          type: ConnectionType.wifi,
          isConnected: true,
          deviceId: _connectedDeviceId,
          address: _wifiClient?.baseUrl,
          isOnlineMode: true,
        );
      
      case ConnectionType.bluetooth:
        final btDevice = _bluetoothService.connectedDevice;
        return ConnectionStatus(
          type: ConnectionType.bluetooth,
          isConnected: btDevice != null,
          deviceId: btDevice?.deviceId,
          deviceName: btDevice?.name,
          address: btDevice?.address,
          isOnlineMode: false,
        );
      
      case ConnectionType.offline:
        return ConnectionStatus(
          type: ConnectionType.offline,
          isConnected: false,
          isOnlineMode: false,
        );
      
      default:
        return ConnectionStatus(
          type: ConnectionType.none,
          isConnected: false,
          isOnlineMode: false,
        );
    }
  }

  /// Attempt to connect to device - tries WiFi first, then Bluetooth
  Future<bool> connectToDevice(String deviceId, {bool preferBluetooth = false}) async {
    Logger.info('Attempting to connect to device: $deviceId');

    if (preferBluetooth) {
      // Try Bluetooth first if preferred
      if (await _connectViaBluetooth(deviceId)) {
        return true;
      }
      
      // Fallback to WiFi
      if (await _connectViaWiFi(deviceId)) {
        return true;
      }
    } else {
      // Try WiFi first (default)
      if (await _connectViaWiFi(deviceId)) {
        return true;
      }
      
      // Fallback to Bluetooth
      if (await _connectViaBluetooth(deviceId)) {
        return true;
      }
    }

    Logger.error('Failed to connect to device via any method');
    _updateConnectionStatus(ConnectionType.none);
    return false;
  }

  /// Connect via WiFi/mDNS
  Future<bool> _connectViaWiFi(String deviceId) async {
    try {
      Logger.info('Attempting WiFi connection...');

      // Check network connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        Logger.warning('No network connectivity');
        return false;
      }

      // Discover devices via mDNS
      await _mdnsService.startDiscovery();
      
      // Wait a bit for discovery
      await Future.delayed(const Duration(seconds: 3));
      
      // Find device
      final device = _mdnsService.findDeviceById(deviceId);
      if (device == null) {
        Logger.warning('Device not found via mDNS');
        return false;
      }

      // Create client and test connection
      _wifiClient = LocalDeviceClient.local(device.ipAddress);
      final connected = await _wifiClient!.testConnection();
      
      if (connected) {
        _connectedDeviceId = deviceId;
        _currentConnectionType = ConnectionType.wifi;
        _updateConnectionStatus(ConnectionType.wifi);
        Logger.info('Connected via WiFi: ${device.ipAddress}');
        return true;
      }

      return false;
    } catch (e) {
      Logger.error('WiFi connection error: $e');
      return false;
    }
  }

  /// Connect via Bluetooth
  Future<bool> _connectViaBluetooth(String deviceId) async {
    try {
      Logger.info('Attempting Bluetooth connection...');

      // Check Bluetooth availability
      if (!await _bluetoothService.isBluetoothAvailable()) {
        Logger.warning('Bluetooth not available');
        return false;
      }

      // Start scanning if not already
      if (!_bluetoothService.isScanning) {
        await _bluetoothService.startScanning();
        
        // Wait for scan results
        await Future.delayed(const Duration(seconds: 5));
      }

      // Find device
      final device = _bluetoothService.discoveredDevices
          .where((d) => d.deviceId == deviceId || d.name.contains(deviceId))
          .firstOrNull;

      if (device == null) {
        Logger.warning('Device not found via Bluetooth');
        return false;
      }

      // Connect to device
      final connected = await _bluetoothService.connectToDevice(device);
      
      if (connected) {
        _connectedDeviceId = deviceId;
        _currentConnectionType = ConnectionType.bluetooth;
        _updateConnectionStatus(ConnectionType.bluetooth);
        Logger.info('Connected via Bluetooth: ${device.name}');
        return true;
      }

      return false;
    } catch (e) {
      Logger.error('Bluetooth connection error: $e');
      return false;
    }
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    Logger.info('Disconnecting from device...');

    if (_currentConnectionType == ConnectionType.wifi) {
      _wifiClient = null;
    } else if (_currentConnectionType == ConnectionType.bluetooth) {
      await _bluetoothService.disconnect();
    }

    _connectedDeviceId = null;
    _currentConnectionType = ConnectionType.none;
    _updateConnectionStatus(ConnectionType.none);
    
    Logger.info('Disconnected');
  }

  /// Get device status
  Future<Map<String, dynamic>?> getDeviceStatus() async {
    try {
      if (_currentConnectionType == ConnectionType.wifi && _wifiClient != null) {
        return await _wifiClient!.getDeviceStatus();
      } else if (_currentConnectionType == ConnectionType.bluetooth) {
        return await _bluetoothService.getDeviceStatus();
      }
      
      Logger.warning('No active connection to get device status');
      return null;
    } catch (e) {
      Logger.error('Error getting device status: $e');
      return null;
    }
  }

  /// Get sensor data
  Future<Map<String, dynamic>?> getSensorData() async {
    try {
      if (_currentConnectionType == ConnectionType.wifi && _wifiClient != null) {
        return await _wifiClient!.getSensorData();
      } else if (_currentConnectionType == ConnectionType.bluetooth) {
        return await _bluetoothService.getSensorData();
      }
      
      Logger.warning('No active connection to get sensor data');
      return null;
    } catch (e) {
      Logger.error('Error getting sensor data: $e');
      return null;
    }
  }

  /// Send command to device
  Future<Map<String, dynamic>?> sendCommand({
    required String commandType,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (_currentConnectionType == ConnectionType.wifi && _wifiClient != null) {
        return await _wifiClient!.sendCommand(commandType: commandType, data: data);
      } else if (_currentConnectionType == ConnectionType.bluetooth) {
        return await _bluetoothService.sendCommand(
          endpoint: '/commands/$commandType',
          method: 'POST',
          data: data,
        );
      }
      
      Logger.warning('No active connection to send command');
      return null;
    } catch (e) {
      Logger.error('Error sending command: $e');
      return null;
    }
  }

  /// Enable offline mode (Bluetooth only)
  Future<bool> enableOfflineMode() async {
    Logger.info('Enabling offline mode...');
    
    if (_currentConnectionType == ConnectionType.bluetooth) {
      _updateConnectionStatus(ConnectionType.offline);
      return true;
    }

    // Try to connect via Bluetooth
    if (_connectedDeviceId != null) {
      final connected = await _connectViaBluetooth(_connectedDeviceId!);
      if (connected) {
        _currentConnectionType = ConnectionType.offline;
        _updateConnectionStatus(ConnectionType.offline);
        return true;
      }
    }

    return false;
  }

  /// Update connection status and notify listeners
  void _updateConnectionStatus(ConnectionType type) {
    _currentConnectionType = type;
    _connectionStatusController.add(getConnectionStatus());
  }

  /// Dispose resources
  void dispose() {
    _mdnsService.dispose();
    _bluetoothService.dispose();
    _connectionStatusController.close();
  }
}
