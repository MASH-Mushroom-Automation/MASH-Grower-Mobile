import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

/// Service for discovering MASH IoT devices on the local network
/// 
/// This service uses UDP broadcast to discover devices that are on the same
/// network as the mobile app. Devices respond with their ID and IP address.
class DeviceDiscoveryService {
  static final DeviceDiscoveryService _instance = DeviceDiscoveryService._internal();
  factory DeviceDiscoveryService() => _instance;
  DeviceDiscoveryService._internal();

  // Discovery configuration
  static const int discoveryPort = 8888; // Port for UDP broadcast
  static const String broadcastMessage = 'MASH_DISCOVER';
  static const Duration discoveryTimeout = Duration(seconds: 5);
  static const Duration scanInterval = Duration(seconds: 2);

  RawDatagramSocket? _socket;
  final List<DiscoveredDevice> _discoveredDevices = [];
  final StreamController<List<DiscoveredDevice>> _devicesController = 
      StreamController<List<DiscoveredDevice>>.broadcast();

  bool _isScanning = false;
  Timer? _scanTimer;

  /// Stream of discovered devices
  Stream<List<DiscoveredDevice>> get devicesStream => _devicesController.stream;

  /// List of currently discovered devices
  List<DiscoveredDevice> get discoveredDevices => List.unmodifiable(_discoveredDevices);

  /// Check if currently scanning
  bool get isScanning => _isScanning;

  /// Start scanning for devices on the network
  Future<void> startScanning() async {
    if (kIsWeb) {
      Logger.error('Device discovery not supported on web platform');
      return;
    }

    if (_isScanning) {
      Logger.info('Already scanning for devices');
      return;
    }

    try {
      _isScanning = true;
      _discoveredDevices.clear();
      _devicesController.add(_discoveredDevices);

      Logger.info('🔍 Starting device discovery on port $discoveryPort');
      Logger.warning('⚠️ UDP broadcast not supported on mobile. Please use mDNS discovery or manual IP connection instead.');

      // Note: RawDatagramSocket.bind(InternetAddress.anyIPv4, 0) is not supported on mobile
      // Use mDNS discovery (MDNSDiscoveryService) or manual IP connection instead
      // This method is kept for backward compatibility but will not work on mobile
      
      _isScanning = false;
      throw UnsupportedError(
        'UDP broadcast discovery is not supported on mobile platforms. '
        'Please use mDNS discovery (Local Network tab) or Manual IP connection instead.'
      );
    } catch (e) {
      Logger.error('❌ Failed to start device discovery', e);
      _isScanning = false;
      rethrow;
    }
  }

  /// Stop scanning for devices
  void stopScanning() {
    if (!_isScanning) return;

    Logger.info('🛑 Stopping device discovery');

    _scanTimer?.cancel();
    _scanTimer = null;

    _socket?.close();
    _socket = null;

    _isScanning = false;
    Logger.info('✅ Device discovery stopped');
  }

  /// Send UDP broadcast to discover devices
  void _sendBroadcast() {
    if (_socket == null) return;

    try {
      final message = broadcastMessage.codeUnits;
      final broadcastAddress = InternetAddress('255.255.255.255');
      
      _socket!.send(message, broadcastAddress, discoveryPort);
      Logger.debug('📡 Broadcast sent to 255.255.255.255:$discoveryPort');
    } catch (e) {
      Logger.error('❌ Failed to send broadcast', e);
    }
  }

  /// Handle response from a device
  void _handleDeviceResponse(Datagram datagram) {
    try {
      final response = String.fromCharCodes(datagram.data);
      final parts = response.split('|');

      if (parts.length >= 3 && parts[0] == 'MASH_DEVICE') {
        final deviceId = parts[1];
        final deviceName = parts[2];
        final ipAddress = datagram.address.address;
        final port = parts.length > 3 ? int.tryParse(parts[3]) ?? 80 : 80;

        // Check if device already discovered
        final existingIndex = _discoveredDevices.indexWhere(
          (d) => d.deviceId == deviceId,
        );

        final device = DiscoveredDevice(
          deviceId: deviceId,
          name: deviceName,
          ipAddress: ipAddress,
          port: port,
          lastSeen: DateTime.now(),
        );

        if (existingIndex >= 0) {
          // Update existing device
          _discoveredDevices[existingIndex] = device;
        } else {
          // Add new device
          _discoveredDevices.add(device);
          Logger.info('✅ Discovered device: $deviceName ($deviceId) at $ipAddress:$port');
        }

        // Notify listeners
        _devicesController.add(_discoveredDevices);
      }
    } catch (e) {
      Logger.error('❌ Failed to parse device response', e);
    }
  }

  /// Manually scan for devices (one-time scan)
  Future<List<DiscoveredDevice>> scanOnce({Duration timeout = discoveryTimeout}) async {
    if (kIsWeb) {
      Logger.error('Device discovery not supported on web platform');
      return [];
    }

    _discoveredDevices.clear();
    await startScanning();

    // Wait for timeout
    await Future.delayed(timeout);

    stopScanning();
    return _discoveredDevices;
  }

  /// Remove stale devices (not seen in last 30 seconds)
  void removeStaleDevices() {
    final now = DateTime.now();
    _discoveredDevices.removeWhere((device) {
      final age = now.difference(device.lastSeen);
      return age.inSeconds > 30;
    });
    _devicesController.add(_discoveredDevices);
  }

  /// Dispose resources
  void dispose() {
    stopScanning();
    _devicesController.close();
  }
}

/// Represents a discovered device on the network
class DiscoveredDevice {
  final String deviceId;
  final String name;
  final String ipAddress;
  final int port;
  final DateTime lastSeen;

  DiscoveredDevice({
    required this.deviceId,
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.lastSeen,
  });

  /// Get the base URL for HTTP requests to this device
  String get baseUrl => 'http://$ipAddress:$port';

  @override
  String toString() {
    return 'DiscoveredDevice(id: $deviceId, name: $name, ip: $ipAddress:$port)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiscoveredDevice && other.deviceId == deviceId;
  }

  @override
  int get hashCode => deviceId.hashCode;
}
