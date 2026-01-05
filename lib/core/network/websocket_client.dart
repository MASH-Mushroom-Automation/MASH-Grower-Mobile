import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/logger.dart';
import '../constants/storage_keys.dart';

class WebSocketClient {
  static final WebSocketClient _instance = WebSocketClient._internal();
  static WebSocketChannel? _channel;

  WebSocketClient._internal();

  factory WebSocketClient() => _instance;

  static WebSocketClient get instance => _instance;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final StreamController<Map<String, dynamic>> _messageController = StreamController.broadcast();
  final StreamController<String> _connectionController = StreamController.broadcast();

  Timer? _pingTimer;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<String> get connectionStream => _connectionController.stream;
  bool get isConnected => _channel != null;

  Future<void> connect() async {
    if (_isConnecting || isConnected) return;

    _isConnecting = true;
    _shouldReconnect = true;

    try {
      final token = await _secureStorage.read(key: StorageKeys.accessToken);
      if (token == null) {
        Logger.warning('No auth token available for WebSocket connection');
        return;
      }

      final wsUrl = _getWebSocketUrl();
      Logger.websocketConnect(wsUrl);

      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: ['websocket'],
      );

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      // Send authentication
      await _sendAuth(token);

      // Start ping timer
      _startPingTimer();

      _reconnectAttempts = 0;
      _isConnecting = false;
      Logger.websocketConnected();

    } catch (e) {
      _isConnecting = false;
      Logger.websocketDisconnect('Connection failed: $e');
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _shouldReconnect = false;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _channel = null;
    Logger.websocketDisconnect('Manual disconnect');
  }

  Future<void> subscribe(String deviceId, [String? userId]) async {
    if (!isConnected) return;

    final payload = {
      'event': 'subscribe',
      'data': {
        'deviceId': deviceId,
        if (userId != null) 'userId': userId,
      }
    };

    await _sendMessage(payload);
    Logger.websocketMessage('subscribe', payload);
  }

  Future<void> unsubscribe(String deviceId, [String? userId]) async {
    if (!isConnected) return;

    final payload = {
      'event': 'unsubscribe',
      'data': {
        'deviceId': deviceId,
        if (userId != null) 'userId': userId,
      }
    };

    await _sendMessage(payload);
    Logger.websocketMessage('unsubscribe', payload);
  }

  Future<void> sendCommand(String deviceId, String command, Map<String, dynamic> data) async {
    if (!isConnected) return;

    final payload = {
      'event': 'command',
      'data': {
        'deviceId': deviceId,
        'command': command,
        'params': data,
      }
    };

    await _sendMessage(payload);
    Logger.websocketMessage('command', payload);
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      Logger.websocketMessage(data['event'] ?? 'message', data);
      _messageController.add(data);
    } catch (e) {
      Logger.error('Failed to parse WebSocket message: $e');
    }
  }

  void _handleError(dynamic error) {
    Logger.websocketDisconnect('Error: $error');
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    Logger.websocketDisconnect('Connection closed');
    _channel = null;
    _pingTimer?.cancel();
    _scheduleReconnect();
  }

  Future<void> _sendAuth(String token) async {
    final authMessage = {
      'event': 'auth',
      'data': {'token': token}
    };
    await _sendMessage(authMessage);
  }

  Future<void> _sendMessage(Map<String, dynamic> message) async {
    if (_channel == null) return;
    
    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      Logger.error('Failed to send WebSocket message: $e');
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isConnected) {
        _sendMessage({'event': 'ping'});
      }
    });
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= maxReconnectAttempts) {
      if (_reconnectAttempts >= maxReconnectAttempts) {
        Logger.error('Max reconnection attempts reached');
        _connectionController.add('failed');
      }
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2);
    
    Logger.info('Scheduling reconnect in ${delay.inSeconds}s (attempt $_reconnectAttempts/$maxReconnectAttempts)');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_shouldReconnect) {
        connect();
      }
    });
  }

  String _getWebSocketUrl() {
    // In production, you might want to use environment variables
    // For now, we'll use the production URL
    return 'wss://mash-space.up.railway.app/ws';
  }

  // Stream filters for specific events
  Stream<Map<String, dynamic>> getDeviceStatusStream() {
    return messageStream.where((data) => data['event'] == 'device:status');
  }

  Stream<Map<String, dynamic>> getSensorDataStream() {
    return messageStream.where((data) => data['event'] == 'sensor:data');
  }

  Stream<Map<String, dynamic>> getAlertStream() {
    return messageStream.where((data) => data['event'] == 'alert:new');
  }

  Stream<Map<String, dynamic>> getNotificationStream() {
    return messageStream.where((data) => data['event'] == 'notification:new');
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}
