import 'dart:async';
import 'package:flutter/foundation.dart';
import 'local_device_client.dart';
import 'mdns_discovery_service.dart';
import '../core/utils/logger.dart';
import '../data/datasources/remote/device_remote_datasource.dart';
import '../data/models/device_model.dart';

/// Provisioning state
enum ProvisioningState {
  idle,
  scanningDevices,
  connectingToDevice,
  scanningWiFi,
  configuringWiFi,
  waitingForConnection,
  registeringDevice,
  completed,
  error,
}

/// Device provisioning service
/// Handles the complete flow of provisioning a MASH IoT device
class DeviceProvisioningService extends ChangeNotifier {
  final MDNSDiscoveryService _mdnsService = MDNSDiscoveryService();
  final DeviceRemoteDataSource _remoteDataSource = DeviceRemoteDataSource();
  
  LocalDeviceClient? _localClient;
  ProvisioningState _state = ProvisioningState.idle;
  String? _errorMessage;
  String? _selectedDeviceId;
  ProvisioningInfo? _provisioningInfo;
  List<WiFiNetworkInfo> _availableNetworks = [];
  DiscoveredDevice? _discoveredDevice;
  
  // Getters
  ProvisioningState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get selectedDeviceId => _selectedDeviceId;
  ProvisioningInfo? get provisioningInfo => _provisioningInfo;
  List<WiFiNetworkInfo> get availableNetworks => _availableNetworks;
  DiscoveredDevice? get discoveredDevice => _discoveredDevice;
  bool get isProvisioning => _state != ProvisioningState.idle && 
                             _state != ProvisioningState.completed &&
                             _state != ProvisioningState.error;

  /// Start provisioning flow
  /// Step 1: Scan for devices in provisioning mode (SoftAP)
  Future<List<String>> scanForProvisioningDevices() async {
    try {
      _setState(ProvisioningState.scanningDevices);
      _errorMessage = null;

      Logger.info('Scanning for devices in provisioning mode...');

      // In provisioning mode, devices create their own WiFi access point
      // The mobile app needs to be connected to this access point
      // We'll try to connect to the default provisioning IP
      
      final deviceIds = <String>[];
      
      // Try connecting to default provisioning IP
      _localClient = LocalDeviceClient.provisioning();
      
      try {
        final connected = await _localClient!.testConnection();
        
        if (connected) {
          // Get provisioning info to get device ID
          _provisioningInfo = await _localClient!.getProvisioningInfo();
          deviceIds.add(_provisioningInfo!.deviceId);
          Logger.info('Found device in provisioning mode: ${_provisioningInfo!.deviceId}');
        }
      } catch (e) {
        Logger.debug('No device found at default provisioning IP: $e');
      }

      _setState(ProvisioningState.idle);
      return deviceIds;
      
    } catch (e) {
      _setError('Failed to scan for devices: $e');
      return [];
    }
  }

  /// Step 2: Connect to device's provisioning WiFi
  /// (This is typically done manually by the user going to WiFi settings)
  Future<bool> verifyProvisioningConnection() async {
    try {
      _setState(ProvisioningState.connectingToDevice);
      _errorMessage = null;

      Logger.info('Verifying connection to device...');

      _localClient = LocalDeviceClient.provisioning();
      
      final connected = await _localClient!.testConnection();
      
      if (connected) {
        _provisioningInfo = await _localClient!.getProvisioningInfo();
        _selectedDeviceId = _provisioningInfo!.deviceId;
        Logger.info('Connected to device: $_selectedDeviceId');
        _setState(ProvisioningState.idle);
        return true;
      } else {
        _setError('Could not connect to device');
        return false;
      }
      
    } catch (e) {
      _setError('Failed to verify connection: $e');
      return false;
    }
  }

  /// Step 3: Scan for available WiFi networks
  Future<List<WiFiNetworkInfo>> scanWiFiNetworks() async {
    try {
      _setState(ProvisioningState.scanningWiFi);
      _errorMessage = null;

      if (_localClient == null) {
        throw Exception('Not connected to device');
      }

      Logger.info('Scanning for WiFi networks...');

      _availableNetworks = await _localClient!.scanWiFiNetworks();
      
      Logger.info('Found ${_availableNetworks.length} WiFi networks');
      _setState(ProvisioningState.idle);
      
      return _availableNetworks;
      
    } catch (e) {
      _setError('Failed to scan WiFi networks: $e');
      return [];
    }
  }

  /// Step 4: Configure device to connect to home WiFi
  Future<bool> configureWiFi({
    required String ssid,
    String password = '',
  }) async {
    try {
      _setState(ProvisioningState.configuringWiFi);
      _errorMessage = null;

      if (_localClient == null) {
        throw Exception('Not connected to device');
      }

      Logger.info('Configuring WiFi: $ssid');

      // Send WiFi configuration to device
      final success = await _localClient!.configureWiFi(
        ssid: ssid,
        password: password,
      );

      if (!success) {
        throw Exception('WiFi configuration failed');
      }

      Logger.info('WiFi configured successfully');
      
      // Wait for device to connect to WiFi
      await _waitForDeviceConnection(ssid);
      
      return true;
      
    } catch (e) {
      _setError('Failed to configure WiFi: $e');
      return false;
    }
  }

  /// Step 5: Wait for device to connect to WiFi and become discoverable
  Future<bool> _waitForDeviceConnection(String ssid) async {
    try {
      _setState(ProvisioningState.waitingForConnection);
      Logger.info('Waiting for device to connect to WiFi...');

      // Wait a bit for device to restart and connect
      await Future.delayed(const Duration(seconds: 5));

      // Start mDNS discovery to find the device on the network
      await _mdnsService.startDiscovery();

      // Wait for the device to be discovered
      final completer = Completer<bool>();
      
      final subscription = _mdnsService.devicesStream.listen((devices) {
        if (devices.isNotEmpty && !completer.isCompleted) {
          // Found device on network
          _discoveredDevice = devices.first;
          Logger.info('Device discovered on network: ${_discoveredDevice!.ipAddress}');
          completer.complete(true);
        }
      });

      // Timeout after 30 seconds
      final result = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          Logger.warning('Timeout waiting for device discovery');
          return false;
        },
      );

      await subscription.cancel();
      await _mdnsService.stopDiscovery();

      if (result && _discoveredDevice != null) {
        // Create new local client for the device's IP on home network
        _localClient = LocalDeviceClient.local(_discoveredDevice!.ipAddress);
        
        // Verify connection
        final connected = await _localClient!.testConnection();
        if (connected) {
          Logger.info('Successfully connected to device on home network');
          return true;
        }
      }

      return false;
      
    } catch (e) {
      Logger.error('Error waiting for device connection: $e');
      return false;
    }
  }

  /// Step 6: Register device with backend
  Future<DeviceModel?> registerDevice({
    required String userId,
    required String deviceName,
  }) async {
    try {
      _setState(ProvisioningState.registeringDevice);
      _errorMessage = null;

      if (_selectedDeviceId == null || _discoveredDevice == null) {
        throw Exception('Device not properly configured');
      }

      Logger.info('Registering device with backend...');

      // Create device model
      final device = DeviceModel(
        id: _selectedDeviceId!,
        userId: userId,
        name: deviceName,
        deviceType: 'grow_chamber',
        status: 'online',
        configuration: {
          'ip_address': _discoveredDevice!.ipAddress,
          'port': _discoveredDevice!.port,
        },
        createdAt: DateTime.now(),
      );

      // Register with backend
      final registeredDevice = await _remoteDataSource.createDevice(device);

      Logger.info('Device registered successfully');
      _setState(ProvisioningState.completed);
      
      return registeredDevice;
      
    } catch (e) {
      _setError('Failed to register device: $e');
      return null;
    }
  }

  /// Complete provisioning flow
  Future<DeviceModel?> provisionDevice({
    required String ssid,
    required String password,
    required String userId,
    required String deviceName,
  }) async {
    try {
      // Verify connection to device
      final connected = await verifyProvisioningConnection();
      if (!connected) {
        return null;
      }

      // Configure WiFi
      final wifiConfigured = await configureWiFi(
        ssid: ssid,
        password: password,
      );
      if (!wifiConfigured) {
        return null;
      }

      // Register with backend
      return await registerDevice(
        userId: userId,
        deviceName: deviceName,
      );
      
    } catch (e) {
      _setError('Provisioning failed: $e');
      return null;
    }
  }

  /// Discover devices on local network (already provisioned)
  Future<List<DiscoveredDevice>> discoverLocalDevices() async {
    try {
      Logger.info('Discovering devices on local network...');
      
      await _mdnsService.startDiscovery();
      
      // Wait a bit for discovery
      await Future.delayed(const Duration(seconds: 5));
      
      final devices = _mdnsService.discoveredDevices;
      Logger.info('Discovered ${devices.length} devices');
      
      return devices;
      
    } catch (e) {
      Logger.error('Failed to discover devices: $e');
      return [];
    } finally {
      await _mdnsService.stopDiscovery();
    }
  }

  /// Connect to discovered device
  Future<LocalDeviceClient?> connectToDevice(DiscoveredDevice device) async {
    try {
      final client = LocalDeviceClient.local(device.ipAddress);
      
      final connected = await client.testConnection();
      if (connected) {
        _localClient = client;
        _discoveredDevice = device;
        return client;
      }
      
      return null;
      
    } catch (e) {
      Logger.error('Failed to connect to device: $e');
      return null;
    }
  }

  /// Reset provisioning state
  void reset() {
    _setState(ProvisioningState.idle);
    _errorMessage = null;
    _selectedDeviceId = null;
    _provisioningInfo = null;
    _availableNetworks = [];
    _discoveredDevice = null;
    _localClient = null;
  }

  void _setState(ProvisioningState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = ProvisioningState.error;
    Logger.error(message);
    notifyListeners();
  }

  @override
  void dispose() {
    _mdnsService.dispose();
    super.dispose();
  }
}
