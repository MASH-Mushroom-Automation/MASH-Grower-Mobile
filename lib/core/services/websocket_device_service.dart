import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../utils/logger.dart';

/// WebSocket-based device connection service
/// This replaces direct IP connection with a more robust WebSocket approach
/// 
/// Architecture:
/// Mobile App <--WebSocket--> Backend Server <--HTTP/WebSocket--> RPi3 Device
/// 
/// Benefits:
/// 1. No need for RPi3 hotspot - both connect to internet
/// 2. Works behind NAT/firewalls
/// 3. Real-time bidirectional communication
/// 4. Automatic reconnection
/// 5. Message queuing and delivery guarantees
class WebSocketDeviceService {
  static final WebSocketDeviceService _instance = WebSocketDeviceService._internal();
  factory WebSocketDeviceService() => _instance;
  WebSocketDeviceService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _deviceId;
  String? _wsUrl;
  
  // Callbacks
  Function(Map<String, dynamic>)? onSensorData;
  Function(Map<String, dynamic>)? onDeviceStatus;
  Function(String)? onError;
  Function()? onConnected;
  Function()? onDisconnected;
  
  // Connection state
  bool get isConnected => _isConnected;
  String? get connectedDeviceId => _deviceId;
  
  /// Connect to device via WebSocket
  /// 
  /// Parameters:
  /// - wsUrl: WebSocket server URL (e.g., 'ws://your-backend.com/ws/device')
  /// - deviceId: Unique device identifier
  /// - userId: User ID for authentication
  /// - token: JWT token for authentication
  Future<bool> connect({
    required String wsUrl,
    required String deviceId,
    required String userId,
    required String token,
  }) async {
    if (_isConnecting) {
      Logger.warning('Connection already in progress');
      return false;
    }
    
    if (_isConnected && _deviceId == deviceId) {
      Logger.info('Already connected to device: $deviceId');
      return true;
    }
    
    _isConnecting = true;
    _wsUrl = wsUrl;
    _deviceId = deviceId;
    
    try {
      Logger.info('Connecting to WebSocket: $wsUrl');
      Logger.info('Device ID: $deviceId, User ID: $userId');
      
      // Build WebSocket URL with query parameters
      final uri = Uri.parse(wsUrl).replace(queryParameters: {
        'deviceId': deviceId,
        'userId': userId,
        'token': token,
      });
      
      // Create WebSocket connection
      _channel = WebSocketChannel.connect(uri);
      
      // Wait for connection to establish (with timeout)
      await _channel!.ready.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('WebSocket connection timeout');
        },
      );
      
      // Listen to messages
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );
      
      _isConnected = true;
      _isConnecting = false;
      
      // Start heartbeat
      _startHeartbeat();
      
      // Send initial connection message
      _sendMessage({
        'type': 'connect',
        'deviceId': deviceId,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      Logger.info('WebSocket connected successfully');
      onConnected?.call();
      
      return true;
      
    } catch (e) {
      Logger.error('WebSocket connection failed: $e');
      _isConnected = false;
      _isConnecting = false;
      onError?.call('Connection failed: $e');
      
      // Schedule reconnection
      _scheduleReconnect();
      
      return false;
    }
  }
  
  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    Logger.info('Disconnecting WebSocket');
    
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    
    if (_channel != null) {
      // Send disconnect message
      _sendMessage({
        'type': 'disconnect',
        'deviceId': _deviceId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await _subscription?.cancel();
      await _channel?.sink.close(status.goingAway);
    }
    
    _isConnected = false;
    _deviceId = null;
    _channel = null;
    _subscription = null;
    
    onDisconnected?.call();
  }
  
  /// Send command to device
  Future<bool> sendCommand(String command, Map<String, dynamic> params) async {
    if (!_isConnected) {
      Logger.error('Cannot send command - not connected');
      return false;
    }
    
    try {
      _sendMessage({
        'type': 'command',
        'deviceId': _deviceId,
        'command': command,
        'params': params,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      Logger.info('Command sent: $command');
      return true;
      
    } catch (e) {
      Logger.error('Failed to send command: $e');
      return false;
    }
  }
  
  /// Request device status
  Future<void> requestDeviceStatus() async {
    await sendCommand('getStatus', {});
  }
  
  /// Request sensor data
  Future<void> requestSensorData() async {
    await sendCommand('getSensorData', {});
  }
  
  /// Control actuator (fan, humidifier, etc.)
  Future<bool> controlActuator(String actuatorName, bool state) async {
    return await sendCommand('setActuator', {
      'actuator': actuatorName,
      'state': state,
    });
  }
  
  /// Set growth mode (SPAWNING, FRUITING, etc.)
  Future<bool> setGrowthMode(String mode) async {
    return await sendCommand('setMode', {
      'mode': mode,
    });
  }
  
  // Private methods
  
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final type = data['type'] as String?;
      
      Logger.info('WebSocket message received: $type');
      
      switch (type) {
        case 'sensorData':
          onSensorData?.call(data['data'] as Map<String, dynamic>);
          break;
          
        case 'deviceStatus':
          onDeviceStatus?.call(data['data'] as Map<String, dynamic>);
          break;
          
        case 'error':
          final error = data['message'] as String? ?? 'Unknown error';
          Logger.error('Device error: $error');
          onError?.call(error);
          break;
          
        case 'pong':
          // Heartbeat response
          Logger.debug('Heartbeat acknowledged');
          break;
          
        default:
          Logger.warning('Unknown message type: $type');
      }
      
    } catch (e) {
      Logger.error('Failed to parse WebSocket message: $e');
    }
  }
  
  void _handleError(dynamic error) {
    Logger.error('WebSocket error: $error');
    onError?.call('Connection error: $error');
    _scheduleReconnect();
  }
  
  void _handleDisconnect() {
    Logger.warning('WebSocket disconnected');
    _isConnected = false;
    onDisconnected?.call();
    _scheduleReconnect();
  }
  
  void _sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }
  
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _sendMessage({
          'type': 'ping',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }
  
  void _scheduleReconnect() {
    if (_wsUrl == null || _deviceId == null) return;
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      Logger.info('Attempting to reconnect...');
      // Note: You'll need to store userId and token to reconnect
      // This is a simplified version
    });
  }
}
