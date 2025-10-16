import 'package:flutter/material.dart';

import '../../core/utils/logger.dart';
import '../../data/models/device_model.dart';
import '../../data/datasources/remote/device_remote_datasource.dart';
import '../../data/datasources/local/device_local_datasource.dart';

class DeviceProvider extends ChangeNotifier {
  final DeviceRemoteDataSource _deviceRemoteDataSource = DeviceRemoteDataSource();
  final DeviceLocalDataSource _deviceLocalDataSource = DeviceLocalDataSource();

  List<DeviceModel> _devices = [];
  bool _isLoading = false;
  String? _error;

  List<DeviceModel> get devices => _devices;
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
