import 'package:dio/dio.dart';
import 'dart:async';
import '../core/utils/logger.dart';

/// Model for WiFi network information
class WiFiNetworkInfo {
  final String ssid;
  final int signal;
  final String security;
  final String frequency;

  WiFiNetworkInfo({
    required this.ssid,
    required this.signal,
    required this.security,
    required this.frequency,
  });

  factory WiFiNetworkInfo.fromJson(Map<String, dynamic> json) {
    return WiFiNetworkInfo(
      ssid: json['ssid'] as String,
      signal: json['signal'] as int,
      security: json['security'] as String,
      frequency: json['frequency'] as String,
    );
  }

  int get signalBars {
    if (signal >= 75) return 4;
    if (signal >= 50) return 3;
    if (signal >= 25) return 2;
    return 1;
  }

  bool get isSecured => security != 'Open' && security.isNotEmpty;
}

/// Model for device provisioning information
class ProvisioningInfo {
  final bool active;
  final String ssid;
  final String ipAddress;
  final bool passwordProtected;
  final int channel;
  final String deviceId;
  final bool networkConnected;
  final Map<String, dynamic>? currentConnection;

  ProvisioningInfo({
    required this.active,
    required this.ssid,
    required this.ipAddress,
    required this.passwordProtected,
    required this.channel,
    required this.deviceId,
    this.networkConnected = false,
    this.currentConnection,
  });

  factory ProvisioningInfo.fromJson(Map<String, dynamic> json) {
    return ProvisioningInfo(
      active: json['active'] as bool? ?? false,
      ssid: json['ssid'] as String? ?? '',
      ipAddress: json['ip_address'] as String? ?? '',
      passwordProtected: json['password_protected'] as bool? ?? false,
      channel: json['channel'] as int? ?? 0,
      deviceId: json['device_id'] as String? ?? '',
      networkConnected: json['network_connected'] as bool? ?? false,
      currentConnection: json['current_connection'] as Map<String, dynamic>?,
    );
  }
}

/// Client for communicating with IoT device's local API
class LocalDeviceClient {
  final String baseUrl;
  late final Dio _dio;
  final Duration timeout;

  LocalDeviceClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 10),
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add logging interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        Logger.debug('Local Device Request: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        Logger.debug('Local Device Response: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (error, handler) {
        Logger.error('Local Device Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  /// Factory constructor for provisioning mode (device acting as access point)
  factory LocalDeviceClient.provisioning({String ip = '192.168.4.1'}) {
    return LocalDeviceClient(
      baseUrl: 'http://$ip:5000/api/v1',
      timeout: const Duration(seconds: 15),
    );
  }

  /// Factory constructor for local network connection
  factory LocalDeviceClient.local(String ip) {
    return LocalDeviceClient(
      baseUrl: 'http://$ip:5000/api/v1',
      timeout: const Duration(seconds: 10),
    );
  }

  /// Get device status
  Future<Map<String, dynamic>> getDeviceStatus() async {
    try {
      final response = await _dio.get('/status');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      Logger.error('Failed to get device status: $e');
      rethrow;
    }
  }

  /// Get latest sensor data
  Future<Map<String, dynamic>> getSensorData() async {
    try {
      final response = await _dio.get('/sensors/latest');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      Logger.error('Failed to get sensor data: $e');
      rethrow;
    }
  }

  /// Scan for WiFi networks (provisioning mode)
  Future<List<WiFiNetworkInfo>> scanWiFiNetworks() async {
    try {
      final response = await _dio.get('/wifi/scan');
      
      if (response.data['success'] == true) {
        final networks = response.data['networks'] as List;
        return networks
            .map((network) => WiFiNetworkInfo.fromJson(network as Map<String, dynamic>))
            .toList();
      }
      
      throw Exception('WiFi scan failed');
    } catch (e) {
      Logger.error('Failed to scan WiFi networks: $e');
      rethrow;
    }
  }

  /// Configure WiFi (provisioning mode)
  Future<bool> configureWiFi({
    required String ssid,
    String password = '',
  }) async {
    try {
      final response = await _dio.post(
        '/wifi/config',
        data: {
          'ssid': ssid,
          'password': password,
        },
      );

      return response.data['success'] == true;
    } catch (e) {
      Logger.error('Failed to configure WiFi: $e');
      rethrow;
    }
  }

  /// Get provisioning information
  Future<ProvisioningInfo> getProvisioningInfo() async {
    try {
      final response = await _dio.get('/provisioning/info');
      
      if (response.data['success'] == true) {
        return ProvisioningInfo.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      
      throw Exception('Failed to get provisioning info');
    } catch (e) {
      Logger.error('Failed to get provisioning info: $e');
      rethrow;
    }
  }

  /// Send command to device
  Future<Map<String, dynamic>> sendCommand({
    required String commandType,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(
        '/commands/$commandType',
        data: data ?? {},
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      Logger.error('Failed to send command: $e');
      rethrow;
    }
  }

  /// Test connection to device
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get(
        '/status',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      Logger.debug('Connection test failed: $e');
      return false;
    }
  }

  /// Poll device until it responds (useful after WiFi configuration)
  Future<bool> waitForConnection({
    int maxAttempts = 30,
    Duration delayBetweenAttempts = const Duration(seconds: 2),
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      try {
        final connected = await testConnection();
        if (connected) {
          Logger.info('Device connected after $i attempts');
          return true;
        }
      } catch (e) {
        Logger.debug('Connection attempt ${i + 1} failed');
      }

      if (i < maxAttempts - 1) {
        await Future.delayed(delayBetweenAttempts);
      }
    }

    Logger.warning('Device connection timeout after $maxAttempts attempts');
    return false;
  }
}
