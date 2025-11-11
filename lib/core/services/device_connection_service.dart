import 'dart:async';
import 'package:dio/dio.dart';
import '../utils/logger.dart';

/// Service for connecting to and controlling MASH IoT devices
/// 
/// Communicates directly with RPi3 devices on the same network
class DeviceConnectionService {
  static final DeviceConnectionService _instance = DeviceConnectionService._internal();
  factory DeviceConnectionService() => _instance;
  DeviceConnectionService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 5),
  ));

  ConnectedDevice? _currentDevice;
  Timer? _dataPollingTimer;
  final StreamController<DeviceSensorData> _sensorDataController = 
      StreamController<DeviceSensorData>.broadcast();

  /// Stream of sensor data from connected device
  Stream<DeviceSensorData> get sensorDataStream => _sensorDataController.stream;

  /// Currently connected device
  ConnectedDevice? get currentDevice => _currentDevice;

  /// Check if a device is connected
  bool get isConnected => _currentDevice != null;

  /// Connect to a device by IP address (simple version)
  Future<bool> connect(String ipAddress, int port) async {
    try {
      Logger.info('🔌 Connecting to device at $ipAddress:$port');

      final baseUrl = 'http://$ipAddress:$port/api';

      // Test connection by getting device status
      final response = await _dio.get('$baseUrl/status');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        _currentDevice = ConnectedDevice(
          deviceId: data['deviceId'] ?? 'unknown',
          ipAddress: ipAddress,
          port: port,
          baseUrl: baseUrl,
        );

        Logger.info('✅ Connected to device ${_currentDevice!.deviceId}');
        
        // Start polling for sensor data
        _startDataPolling();
        
        return true;
      }

      return false;
    } catch (e) {
      Logger.error('❌ Failed to connect to device', e);
      return false;
    }
  }

  /// Connect to a device by IP address (with device ID)
  Future<bool> connectToDevice({
    required String deviceId,
    required String ipAddress,
    int port = 5000,
  }) async {
    try {
      Logger.info('🔌 Connecting to device $deviceId at $ipAddress:$port');

      final baseUrl = 'http://$ipAddress:$port/api';

      // Test connection by getting device status
      final response = await _dio.get('$baseUrl/status');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        _currentDevice = ConnectedDevice(
          deviceId: deviceId,
          ipAddress: ipAddress,
          port: port,
          baseUrl: baseUrl,
        );

        Logger.info('✅ Connected to device $deviceId');
        
        // Start polling for sensor data
        _startDataPolling();
        
        return true;
      }

      return false;
    } catch (e) {
      Logger.error('❌ Failed to connect to device', e);
      return false;
    }
  }

  /// Disconnect from current device
  void disconnect() {
    if (_currentDevice == null) return;

    Logger.info('🔌 Disconnecting from device ${_currentDevice!.deviceId}');
    
    _stopDataPolling();
    _currentDevice = null;

    Logger.info('✅ Disconnected from device');
  }

  /// Get device status
  Future<Map<String, dynamic>> getDeviceStatus() async {
    if (_currentDevice == null) {
      throw Exception('No device connected');
    }

    try {
      final response = await _dio.get('${_currentDevice!.baseUrl}/status');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }

      throw Exception('Failed to get device status');
    } catch (e) {
      Logger.error('❌ Failed to get device status', e);
      rethrow;
    }
  }

  /// Get current sensor data from device
  Future<DeviceSensorData?> getSensorData() async {
    if (_currentDevice == null) {
      Logger.error('No device connected');
      return null;
    }

    try {
      final url = '${_currentDevice!.baseUrl}/sensor/current';
      Logger.debug('📡 Fetching sensor data from: $url');
      
      final response = await _dio.get(url);
      
      Logger.debug('📥 Response status: ${response.statusCode}');
      Logger.debug('📥 Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.debug('✅ Parsing sensor data...');
        final data = DeviceSensorData.fromJson(response.data['data']);
        Logger.info('📊 Sensor data: Temp=${data.temperature}°C, Humidity=${data.humidity}%, CO2=${data.co2}ppm');
        _sensorDataController.add(data);
        return data;
      } else {
        Logger.warning('⚠️ Invalid response: success=${response.data['success']}, status=${response.statusCode}');
      }

      return null;
    } catch (e, stackTrace) {
      Logger.error('❌ Failed to get sensor data: $e');
      Logger.debug('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Set device mode (Fruiting or Spawning)
  /// @param mode 's' for Spawning, 'f' for Fruiting
  Future<bool> setMode(String mode) async {
    if (_currentDevice == null) {
      Logger.error('No device connected');
      return false;
    }

    if (mode != 's' && mode != 'f') {
      Logger.error('Invalid mode. Use "s" for Spawning or "f" for Fruiting');
      return false;
    }

    try {
      Logger.info('📝 Setting device mode to ${mode == "s" ? "Spawning" : "Fruiting"}');

      final response = await _dio.post(
        '${_currentDevice!.baseUrl}/mode',
        data: {'mode': mode},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.info('✅ Mode set successfully');
        return true;
      }

      return false;
    } catch (e) {
      Logger.error('❌ Failed to set mode', e);
      return false;
    }
  }

  /// Control actuator (relay)
  /// @param actuatorId ID of the actuator (e.g., 'humidifier', 'exhaust_fan', 'blower_fan')
  /// @param state true to turn ON, false to turn OFF
  Future<bool> controlActuator(String actuatorId, bool state) async {
    if (_currentDevice == null) {
      Logger.error('No device connected');
      return false;
    }

    try {
      Logger.info('🎛️ Setting $actuatorId to ${state ? "ON" : "OFF"}');

      final response = await _dio.post(
        '${_currentDevice!.baseUrl}/actuator',
        data: {
          'actuator': actuatorId,
          'state': state,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.info('✅ Actuator control successful');
        return true;
      }

      return false;
    } catch (e) {
      Logger.error('❌ Failed to control actuator', e);
      return false;
    }
  }

  /// Start polling sensor data periodically
  void _startDataPolling() {
    _stopDataPolling();
    
    // Poll every 5 seconds
    _dataPollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      getSensorData();
    });

    Logger.info('📊 Started sensor data polling');
  }

  /// Stop polling sensor data
  void _stopDataPolling() {
    _dataPollingTimer?.cancel();
    _dataPollingTimer = null;
  }

  /// Get AI automation status
  Future<Map<String, dynamic>?> getAutomationStatus() async {
    if (_currentDevice == null) {
      Logger.error('No device connected');
      return null;
    }

    try {
      final response = await _dio.get(
        '${_currentDevice!.baseUrl}/automation/status',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }

      return null;
    } catch (e) {
      Logger.error('Failed to get automation status', e);
      return null;
    }
  }

  /// Enable AI automation
  Future<bool> enableAutomation() async {
    if (_currentDevice == null) {
      Logger.error('No device connected');
      return false;
    }

    try {
      Logger.info('Enabling AI automation');

      final response = await _dio.post(
        '${_currentDevice!.baseUrl}/automation/enable',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.info('AI automation enabled');
        return true;
      }

      return false;
    } catch (e) {
      Logger.error('Failed to enable automation', e);
      return false;
    }
  }

  /// Disable AI automation
  Future<bool> disableAutomation() async {
    if (_currentDevice == null) {
      Logger.error('No device connected');
      return false;
    }

    try {
      Logger.info('Disabling AI automation');

      final response = await _dio.post(
        '${_currentDevice!.baseUrl}/automation/disable',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.info('AI automation disabled');
        return true;
      }

      return false;
    } catch (e) {
      Logger.error('Failed to disable automation', e);
      return false;
    }
  }

  /// Get actuator states
  Future<Map<String, dynamic>?> getActuatorStates() async {
    if (_currentDevice == null) {
      Logger.error('No device connected');
      return null;
    }

    try {
      final response = await _dio.get(
        '${_currentDevice!.baseUrl}/actuators',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }

      return null;
    } catch (e) {
      Logger.error('Failed to get actuator states', e);
      return null;
    }
  }

  /// Get AI automation decision history
  Future<List<dynamic>?> getAutomationHistory({int limit = 10}) async {
    if (_currentDevice == null) {
      Logger.error('No device connected');
      return null;
    }

    try {
      final response = await _dio.get(
        '${_currentDevice!.baseUrl}/automation/history?limit=$limit',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['history'];
      }

      return null;
    } catch (e) {
      Logger.error('Failed to get automation history', e);
      return null;
    }
  }

  /// Get sensor logs
  Future<List<dynamic>?> getSensorLogs({int hours = 24, int limit = 1000}) async {
    if (_currentDevice == null) {
      Logger.error('No device connected');
      return null;
    }

    try {
      final response = await _dio.get(
        '${_currentDevice!.baseUrl}/logs/sensors?hours=$hours&limit=$limit',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['readings'];
      }

      return null;
    } catch (e) {
      Logger.error('Failed to get sensor logs', e);
      return null;
    }
  }

  /// Get actuator logs
  Future<List<dynamic>?> getActuatorLogs({int hours = 24, int limit = 500}) async {
    if (_currentDevice == null) {
      Logger.error('No device connected');
      return null;
    }

    try {
      final response = await _dio.get(
        '${_currentDevice!.baseUrl}/logs/actuators?hours=$hours&limit=$limit',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['history'];
      }

      return null;
    } catch (e) {
      Logger.error('Failed to get actuator logs', e);
      return null;
    }
  }

  /// Get AI decision logs
  Future<List<dynamic>?> getAIDecisionLogs({int hours = 24, int limit = 100}) async {
    if (_currentDevice == null) {
      Logger.error('No device connected');
      return null;
    }

    try {
      final response = await _dio.get(
        '${_currentDevice!.baseUrl}/logs/ai-decisions?hours=$hours&limit=$limit',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['decisions'];
      }

      return null;
    } catch (e) {
      Logger.error('Failed to get AI decision logs', e);
      return null;
    }
  }

  /// Get statistics
  Future<Map<String, dynamic>?> getStatistics({int hours = 24}) async {
    if (_currentDevice == null) {
      Logger.error('No device connected');
      return null;
    }

    try {
      final response = await _dio.get(
        '${_currentDevice!.baseUrl}/logs/statistics?hours=$hours',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }

      return null;
    } catch (e) {
      Logger.error('Failed to get statistics', e);
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _sensorDataController.close();
    _dio.close();
  }
}

/// Represents a connected device
class ConnectedDevice {
  final String deviceId;
  final String ipAddress;
  final int port;
  final String baseUrl;

  ConnectedDevice({
    required this.deviceId,
    required this.ipAddress,
    required this.port,
    required this.baseUrl,
  });
}

/// Sensor data from device
class DeviceSensorData {
  final double temperature;
  final double humidity;
  final double co2;
  final String mode; // 's' or 'f'
  final Map<String, bool> actuators; // actuator states
  final DateTime timestamp;

  DeviceSensorData({
    required this.temperature,
    required this.humidity,
    required this.co2,
    required this.mode,
    required this.actuators,
    required this.timestamp,
  });

  factory DeviceSensorData.fromJson(Map<String, dynamic> json) {
    return DeviceSensorData(
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      co2: (json['co2'] ?? 0).toDouble(),
      mode: json['mode'] ?? 's',
      actuators: Map<String, bool>.from(json['actuators'] ?? {}),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'co2': co2,
      'mode': mode,
      'actuators': actuators,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get modeDisplay => mode == 's' ? 'Spawning' : 'Fruiting';
}
