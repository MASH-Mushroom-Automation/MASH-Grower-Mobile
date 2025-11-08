import 'dart:async';
import 'dart:math';
import '../utils/logger.dart';
import 'device_connection_service.dart';

class MockDeviceService {
  static final MockDeviceService _instance = MockDeviceService._internal();
  factory MockDeviceService() => _instance;
  MockDeviceService._internal();

  bool _isConnected = false;
  String? _connectedDeviceId;
  Timer? _dataUpdateTimer;
  
  final Random _random = Random();
  
  double _temperature = 25.0;
  double _humidity = 65.0;
  double _co2 = 800.0;
  String _mode = 'f';
  
  Map<String, bool> _actuatorStates = {
    'exhaust_fan': false,
    'humidifier': false,
    'blower_fan': false,
    'led_lights': false,
  };
  
  bool _automationEnabled = false;
  final List<Map<String, dynamic>> _automationHistory = [];
  final List<Map<String, dynamic>> _deviceLogs = [];

  bool get isConnected => _isConnected;
  String? get connectedDeviceId => _connectedDeviceId;

  Future<bool> connectToDevice({
    required String deviceId,
    required String deviceName,
  }) async {
    Logger.info('Connecting to mock device: $deviceId');
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isConnected = true;
    _connectedDeviceId = deviceId;
    
    _startMockDataGeneration();
    _addLog('Device connected', 'info');
    
    Logger.info('Connected to mock device: $deviceName');
    return true;
  }

  void disconnect() {
    Logger.info('Disconnecting from mock device');
    _dataUpdateTimer?.cancel();
    _isConnected = false;
    _connectedDeviceId = null;
    _addLog('Device disconnected', 'info');
  }

  void _startMockDataGeneration() {
    _dataUpdateTimer?.cancel();
    
    _dataUpdateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _temperature += (_random.nextDouble() - 0.5) * 0.5;
      _temperature = _temperature.clamp(20.0, 30.0);
      
      _humidity += (_random.nextDouble() - 0.5) * 2.0;
      _humidity = _humidity.clamp(50.0, 80.0);
      
      _co2 += (_random.nextDouble() - 0.5) * 50.0;
      _co2 = _co2.clamp(400.0, 1500.0);
      
      if (_automationEnabled) {
        _runAutomation();
      }
    });
  }

  void _runAutomation() {
    bool changed = false;
    final decisions = <String>[];
    
    if (_temperature > 27.0 && !_actuatorStates['exhaust_fan']!) {
      _actuatorStates['exhaust_fan'] = true;
      decisions.add('Enabled exhaust fan (temp: ${_temperature.toStringAsFixed(1)}°C)');
      changed = true;
    } else if (_temperature < 24.0 && _actuatorStates['exhaust_fan']!) {
      _actuatorStates['exhaust_fan'] = false;
      decisions.add('Disabled exhaust fan (temp: ${_temperature.toStringAsFixed(1)}°C)');
      changed = true;
    }
    
    if (_humidity < 60.0 && !_actuatorStates['humidifier']!) {
      _actuatorStates['humidifier'] = true;
      decisions.add('Enabled humidifier (humidity: ${_humidity.toStringAsFixed(1)}%)');
      changed = true;
    } else if (_humidity > 75.0 && _actuatorStates['humidifier']!) {
      _actuatorStates['humidifier'] = false;
      decisions.add('Disabled humidifier (humidity: ${_humidity.toStringAsFixed(1)}%)');
      changed = true;
    }
    
    if (changed) {
      _automationHistory.insert(0, {
        'timestamp': DateTime.now().toIso8601String(),
        'mode': _mode == 's' ? 'Spawning Mode' : 'Fruiting Mode',
        'actions': Map<String, bool>.from(_actuatorStates),
        'reasoning': decisions,
        'sensor_data': {
          'temperature': _temperature,
          'humidity': _humidity,
          'co2': _co2,
        },
      });
      
      if (_automationHistory.length > 50) {
        _automationHistory.removeLast();
      }
      
      for (final decision in decisions) {
        _addLog('AI Decision: $decision', 'automation');
      }
    }
  }

  void _addLog(String message, String type) {
    _deviceLogs.insert(0, {
      'timestamp': DateTime.now().toIso8601String(),
      'message': message,
      'type': type,
      'temperature': _temperature,
      'humidity': _humidity,
      'co2': _co2,
    });
    
    if (_deviceLogs.length > 100) {
      _deviceLogs.removeLast();
    }
  }

  Future<DeviceSensorData?> getSensorData() async {
    if (!_isConnected) {
      Logger.warning('Cannot get sensor data - not connected');
      return null;
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    return DeviceSensorData(
      temperature: _temperature,
      humidity: _humidity,
      co2: _co2,
      mode: _mode,
      actuators: Map<String, bool>.from(_actuatorStates),
      timestamp: DateTime.now(),
    );
  }

  Future<Map<String, dynamic>?> getDeviceStatus() async {
    if (!_isConnected) return null;
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    return {
      'deviceId': _connectedDeviceId ?? 'mock-chamber-1',
      'deviceName': 'Mock Chamber 1',
      'status': 'online',
      'mode': _mode,
      'uptime': '5h 23m',
      'firmware': 'v1.0.0-mock',
    };
  }

  Future<Map<String, bool>?> getActuatorStates() async {
    if (!_isConnected) return null;
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    return Map<String, bool>.from(_actuatorStates);
  }

  Future<bool> setActuator(String actuatorName, bool state) async {
    if (!_isConnected) return false;
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_actuatorStates.containsKey(actuatorName)) {
      _actuatorStates[actuatorName] = state;
      _addLog('${state ? 'Enabled' : 'Disabled'} $actuatorName', 'control');
      Logger.info('Mock: Set $actuatorName to $state');
      return true;
    }
    
    return false;
  }

  Future<bool> setMode(String mode) async {
    if (!_isConnected) return false;
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    _mode = mode;
    final modeName = mode == 's' ? 'Spawning Phase' : 'Fruiting Phase';
    _addLog('Changed mode to $modeName', 'control');
    Logger.info('Mock: Set mode to $modeName');
    return true;
  }

  Future<Map<String, dynamic>?> getAutomationStatus() async {
    if (!_isConnected) return null;
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    return {
      'enabled': _automationEnabled,
      'mode': _automationEnabled ? 'active' : 'disabled',
      'lastDecision': _automationHistory.isNotEmpty 
          ? _automationHistory.first['timestamp']
          : null,
      'totalDecisions': _automationHistory.length,
    };
  }

  Future<bool> enableAutomation() async {
    if (!_isConnected) return false;
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    _automationEnabled = true;
    _addLog('AI Automation enabled', 'automation');
    Logger.info('Mock: AI Automation enabled');
    return true;
  }

  Future<bool> disableAutomation() async {
    if (!_isConnected) return false;
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    _automationEnabled = false;
    _addLog('AI Automation disabled', 'automation');
    Logger.info('Mock: AI Automation disabled');
    return false;
  }

  Future<List<dynamic>?> getAutomationHistory({int limit = 10}) async {
    if (!_isConnected) return null;
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    return _automationHistory.take(limit).toList();
  }

  Future<List<Map<String, dynamic>>?> getDeviceLogs({int limit = 50}) async {
    if (!_isConnected) return null;
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    return _deviceLogs.take(limit).toList();
  }

  Future<Map<String, dynamic>?> getSystemInfo() async {
    if (!_isConnected) return null;
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    return {
      'deviceId': _connectedDeviceId ?? 'mock-chamber-1',
      'firmware': 'v1.0.0-mock',
      'hardware': 'Raspberry Pi 3 (Simulated)',
      'uptime': '5h 23m 14s',
      'memory': '45%',
      'cpu': '23%',
      'temperature': '42°C',
    };
  }
}
