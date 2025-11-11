import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/utils/logger.dart';
import '../../data/models/sensor_reading_model.dart';
import '../../data/datasources/remote/sensor_remote_datasource.dart';
import '../../data/datasources/local/sensor_local_datasource.dart';
import '../../core/network/websocket_client.dart';

class SensorProvider extends ChangeNotifier {
  final SensorRemoteDataSource _sensorRemoteDataSource = SensorRemoteDataSource();
  final SensorLocalDataSource _sensorLocalDataSource = SensorLocalDataSource();
  final WebSocketClient _webSocketClient = WebSocketClient.instance;
  final Connectivity _connectivity = Connectivity();

  List<SensorReadingModel> _latestReadings = [];
  List<SensorReadingModel> _historicalData = [];
  final Map<String, List<SensorReadingModel>> _deviceData = {};
  bool _isLoading = false;
  String? _error;
  String? _selectedDeviceId;
  bool _isOnline = true;

  List<SensorReadingModel> get latestReadings => _latestReadings;
  List<SensorReadingModel> get historicalData => _historicalData;
  Map<String, List<SensorReadingModel>> get deviceData => _deviceData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedDeviceId => _selectedDeviceId;
  bool get isOnline => _isOnline;

  SensorProvider() {
    _initializeConnectivity();
    _initializeWebSocket();
  }

  void _initializeConnectivity() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _isOnline = !results.contains(ConnectivityResult.none);
      notifyListeners();
      
      if (_isOnline) {
        _syncOfflineData();
      }
    });
  }

  void _initializeWebSocket() {
    // Listen to real-time sensor data
    _webSocketClient.getSensorDataStream().listen((data) {
      _handleRealtimeData(data);
    });

    // Listen to device status updates
    _webSocketClient.getDeviceStatusStream().listen((data) {
      _handleDeviceStatusUpdate(data);
    });
  }

  Future<void> loadLatestReadings(String deviceId) async {
    _setLoading(true);
    _clearError();
    _selectedDeviceId = deviceId;

    try {
      if (_isOnline) {
        // Load from remote API
        final readings = await _sensorRemoteDataSource.getLatestReadings(deviceId);
        _latestReadings = readings;
        
        // Cache locally
        await _sensorLocalDataSource.saveReadings(readings);
      } else {
        // Load from local storage
        _latestReadings = await _sensorLocalDataSource.getLatestReadings(deviceId);
      }
      
      Logger.info('Loaded ${_latestReadings.length} latest readings for device $deviceId');
    } catch (e) {
      Logger.error('Failed to load latest readings: $e');
      _setError('Failed to load sensor data');
      
      // Fallback to local data
      try {
        _latestReadings = await _sensorLocalDataSource.getLatestReadings(deviceId);
      } catch (localError) {
        Logger.error('Failed to load local data: $localError');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadHistoricalData(String deviceId, {DateTime? startDate, DateTime? endDate}) async {
    _setLoading(true);
    _clearError();

    try {
      if (_isOnline) {
        // Load from remote API
        final data = await _sensorRemoteDataSource.getHistoricalData(
          deviceId,
          startDate: startDate,
          endDate: endDate,
        );
        _historicalData = data;
        
        // Cache locally
        await _sensorLocalDataSource.saveReadings(data);
      } else {
        // Load from local storage
        _historicalData = await _sensorLocalDataSource.getHistoricalData(
          deviceId,
          startDate: startDate,
          endDate: endDate,
        );
      }
      
      Logger.info('Loaded ${_historicalData.length} historical readings for device $deviceId');
    } catch (e) {
      Logger.error('Failed to load historical data: $e');
      _setError('Failed to load historical data');
      
      // Fallback to local data
      try {
        _historicalData = await _sensorLocalDataSource.getHistoricalData(
          deviceId,
          startDate: startDate,
          endDate: endDate,
        );
      } catch (localError) {
        Logger.error('Failed to load local historical data: $localError');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadDeviceData(String deviceId) async {
    _setLoading(true);
    _clearError();

    try {
      if (_isOnline) {
        // Load from remote API
        final data = await _sensorRemoteDataSource.getDeviceData(deviceId);
        _deviceData[deviceId] = data;
        
        // Cache locally
        await _sensorLocalDataSource.saveReadings(data);
      } else {
        // Load from local storage
        _deviceData[deviceId] = await _sensorLocalDataSource.getDeviceData(deviceId);
      }
      
      Logger.info('Loaded data for device $deviceId');
    } catch (e) {
      Logger.error('Failed to load device data: $e');
      _setError('Failed to load device data');
      
      // Fallback to local data
      try {
        _deviceData[deviceId] = await _sensorLocalDataSource.getDeviceData(deviceId);
      } catch (localError) {
        Logger.error('Failed to load local device data: $localError');
      }
    } finally {
      _setLoading(false);
    }
  }

  void _handleRealtimeData(Map<String, dynamic> data) {
    try {
      final deviceId = data['deviceId'] as String?;
      if (deviceId == null) return;

      final reading = SensorReadingModel.fromJson(data['reading']);
      
      // Update latest readings if this is the selected device
      if (deviceId == _selectedDeviceId) {
        _updateLatestReading(reading);
      }
      
      // Update device data
      _updateDeviceData(deviceId, reading);
      
      // Save to local storage
      _sensorLocalDataSource.saveReading(reading);
      
      Logger.info('Updated real-time sensor data for device $deviceId');
    } catch (e) {
      Logger.error('Failed to handle real-time data: $e');
    }
  }

  void _handleDeviceStatusUpdate(Map<String, dynamic> data) {
    try {
      final deviceId = data['deviceId'] as String?;
      if (deviceId == null) return;

      // Update device status in the data
      // This would typically update a device provider
      Logger.info('Device status updated for $deviceId');
    } catch (e) {
      Logger.error('Failed to handle device status update: $e');
    }
  }

  void _updateLatestReading(SensorReadingModel reading) {
    // Remove existing reading of the same type
    _latestReadings.removeWhere((r) => r.sensorType == reading.sensorType);
    
    // Add new reading
    _latestReadings.add(reading);
    
    // Sort by timestamp
    _latestReadings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    notifyListeners();
  }

  void _updateDeviceData(String deviceId, SensorReadingModel reading) {
    if (_deviceData[deviceId] == null) {
      _deviceData[deviceId] = [];
    }
    
    // Remove existing reading of the same type
    _deviceData[deviceId]!.removeWhere((r) => r.sensorType == reading.sensorType);
    
    // Add new reading
    _deviceData[deviceId]!.add(reading);
    
    // Sort by timestamp
    _deviceData[deviceId]!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    notifyListeners();
  }

  Future<void> _syncOfflineData() async {
    try {
      Logger.syncStart();
      
      // Get unsynced readings
      final unsyncedReadings = await _sensorLocalDataSource.getUnsyncedReadings();
      
      if (unsyncedReadings.isNotEmpty) {
        // Sync with remote server
        await _sensorRemoteDataSource.syncReadings(unsyncedReadings);
        
        // Mark as synced
        await _sensorLocalDataSource.markAsSynced(unsyncedReadings);
        
        Logger.syncComplete(unsyncedReadings.length);
      }
    } catch (e) {
      Logger.syncError(e.toString());
    }
  }

  List<SensorReadingModel> getReadingsByType(String sensorType) {
    return _latestReadings.where((r) => r.sensorType == sensorType).toList();
  }

  SensorReadingModel? getLatestReadingByType(String sensorType) {
    final readings = getReadingsByType(sensorType);
    if (readings.isEmpty) return null;
    
    readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return readings.first;
  }

  Map<String, double> getCurrentValues() {
    final values = <String, double>{};
    
    for (final reading in _latestReadings) {
      values[reading.sensorType] = reading.value;
    }
    
    return values;
  }

  void clearData() {
    _latestReadings.clear();
    _historicalData.clear();
    _deviceData.clear();
    _clearError();
    notifyListeners();
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
