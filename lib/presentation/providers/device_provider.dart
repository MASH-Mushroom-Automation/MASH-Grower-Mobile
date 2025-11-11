import 'package:flutter/material.dart';

import '../../core/utils/logger.dart';
import '../../core/services/device_connection_service.dart';
import '../../core/services/mock_device_service.dart';
import '../../data/models/device_model.dart';
import '../../data/datasources/remote/device_remote_datasource.dart';
import '../../data/datasources/local/device_local_datasource.dart';

class DeviceProvider extends ChangeNotifier {
  final DeviceRemoteDataSource _deviceRemoteDataSource = DeviceRemoteDataSource();
  final DeviceLocalDataSource _deviceLocalDataSource = DeviceLocalDataSource();
  final DeviceConnectionService _connectionService = DeviceConnectionService();
  final MockDeviceService _mockService = MockDeviceService();

  List<DeviceModel> _devices = [];
  DeviceModel? _connectedDevice;
  bool _isLoading = false;
  String? _error;
  bool _isMockDevice = false;

  List<DeviceModel> get devices => _devices;
  DeviceModel? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectedDevice != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDevices() async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implement device loading
      // For now, return empty list
      _devices = [];
      Logger.info('Loaded ${_devices.length} devices');
    } catch (e) {
      Logger.error('Failed to load devices: $e');
      _setError('Failed to load devices');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addDevice(DeviceModel device) async {
    try {
      // TODO: Implement device addition
      _devices.add(device);
      notifyListeners();
      Logger.info('Added device: ${device.name}');
    } catch (e) {
      Logger.error('Failed to add device: $e');
      _setError('Failed to add device');
    }
  }

  /// Connect to a device by IP address
  Future<bool> connectToDevice({
    required String deviceId,
    required String deviceName,
    required String ipAddress,
    int port = 5000,
  }) async {
    try {
      Logger.info('Connecting to device: $deviceId at $ipAddress:$port');
      
      final success = await _connectionService.connectToDevice(
        deviceId: deviceId,
        ipAddress: ipAddress,
        port: port,
      );

      if (success) {
        // Create device model for connected device
        _connectedDevice = DeviceModel(
          id: deviceId,
          name: deviceName,
          deviceType: 'MUSHROOM_CHAMBER',
          status: 'ONLINE',
          userId: '', // Will be set from auth
          configuration: {
            'ipAddress': ipAddress,
            'port': port,
          },
          createdAt: DateTime.now(),
        );
        
        notifyListeners();
        Logger.info('✅ Connected to device: $deviceName');
        return true;
      }

      return false;
    } catch (e) {
      Logger.error('Failed to connect to device: $e');
      _setError('Failed to connect to device');
      return false;
    }
  }

  /// Connect to a mock device for testing
  Future<bool> connectToMockDevice({
    required String deviceId,
    required String deviceName,
  }) async {
    try {
      Logger.info('Connecting to mock device: $deviceId');
      
      final success = await _mockService.connectToDevice(
        deviceId: deviceId,
        deviceName: deviceName,
      );

      if (success) {
        _connectedDevice = DeviceModel(
          id: deviceId,
          name: deviceName,
          deviceType: 'MUSHROOM_CHAMBER',
          status: 'ONLINE',
          userId: '',
          configuration: const {
            'isMock': true,
          },
          createdAt: DateTime.now(),
        );
        
        _isMockDevice = true;
        notifyListeners();
        Logger.info('Connected to mock device: $deviceName');
        return true;
      }

      return false;
    } catch (e) {
      Logger.error('Failed to connect to mock device: $e');
      _setError('Failed to connect to mock device');
      return false;
    }
  }

  /// Disconnect from current device
  void disconnectDevice() {
    if (_isMockDevice) {
      _mockService.disconnect();
      _isMockDevice = false;
    } else {
      _connectionService.disconnect();
    }
    _connectedDevice = null;
    notifyListeners();
    Logger.info('Disconnected from device');
  }

  Future<void> updateDevice(DeviceModel device) async {
    try {
      // TODO: Implement device update
      final index = _devices.indexWhere((d) => d.id == device.id);
      if (index != -1) {
        _devices[index] = device;
        notifyListeners();
        Logger.info('Updated device: ${device.name}');
      }
    } catch (e) {
      Logger.error('Failed to update device: $e');
      _setError('Failed to update device');
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    try {
      // TODO: Implement device deletion
      _devices.removeWhere((d) => d.id == deviceId);
      notifyListeners();
      Logger.info('Deleted device: $deviceId');
    } catch (e) {
      Logger.error('Failed to delete device: $e');
      _setError('Failed to delete device');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
