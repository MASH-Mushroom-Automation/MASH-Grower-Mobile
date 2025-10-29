import 'dart:async';
import 'package:multicast_dns/multicast_dns.dart';
import '../core/utils/logger.dart';

/// Model for discovered device
class DiscoveredDevice {
  final String deviceId;
  final String name;
  final String ipAddress;
  final int port;
  final Map<String, String> properties;
  final DateTime discoveredAt;

  DiscoveredDevice({
    required this.deviceId,
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.properties,
    DateTime? discoveredAt,
  }) : discoveredAt = discoveredAt ?? DateTime.now();

  String get displayName => properties['name'] ?? name;
  String get deviceType => properties['type'] ?? 'unknown';
  String get apiVersion => properties['api_version'] ?? 'v1';

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

/// Service for discovering MASH IoT devices on local network using mDNS
class MDNSDiscoveryService {
  static const String _serviceType = '_mash-iot._tcp';
  static const Duration _discoveryTimeout = Duration(seconds: 10);
  
  final List<DiscoveredDevice> _discoveredDevices = [];
  final StreamController<List<DiscoveredDevice>> _devicesController = 
      StreamController<List<DiscoveredDevice>>.broadcast();
  
  bool _isDiscovering = false;
  MDnsClient? _mdnsClient;

  /// Stream of discovered devices
  Stream<List<DiscoveredDevice>> get devicesStream => _devicesController.stream;

  /// Currently discovered devices
  List<DiscoveredDevice> get discoveredDevices => List.unmodifiable(_discoveredDevices);

  /// Whether discovery is currently running
  bool get isDiscovering => _isDiscovering;

  /// Start discovering devices on the local network
  Future<void> startDiscovery() async {
    if (_isDiscovering) {
      Logger.warning('Discovery already in progress');
      return;
    }

    try {
      _isDiscovering = true;
      _discoveredDevices.clear();
      _devicesController.add([]);

      Logger.info('Starting mDNS discovery for MASH IoT devices...');

      // Create mDNS client
      _mdnsClient = MDnsClient();
      await _mdnsClient!.start();

      // Lookup MASH IoT devices
      await for (final PtrResourceRecord ptr in _mdnsClient!
          .lookup<PtrResourceRecord>(
            ResourceRecordQuery.serverPointer(_serviceType),
          )
          .timeout(_discoveryTimeout, onTimeout: (sink) => sink.close())) {
        
        Logger.debug('Found mDNS pointer: ${ptr.domainName}');
        
        // Get service details
        await _resolveService(ptr.domainName);
      }

      Logger.info('mDNS discovery completed. Found ${_discoveredDevices.length} devices');
      
    } catch (e) {
      Logger.error('Error during mDNS discovery: $e');
    } finally {
      await stopDiscovery();
    }
  }

  /// Resolve service details for a discovered service
  Future<void> _resolveService(String serviceName) async {
    if (_mdnsClient == null) return;

    try {
      // Get SRV records (hostname and port)
      await for (final SrvResourceRecord srv in _mdnsClient!
          .lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(serviceName),
          )
          .timeout(const Duration(seconds: 2), onTimeout: (sink) => sink.close())) {
        
        Logger.debug('Found SRV record: ${srv.target}:${srv.port}');

        // Get TXT records (properties)
        final properties = await _getTxtRecords(serviceName);

        // Get A records (IP addresses)
        await for (final IPAddressResourceRecord a in _mdnsClient!
            .lookup<IPAddressResourceRecord>(
              ResourceRecordQuery.addressIPv4(srv.target),
            )
            .timeout(const Duration(seconds: 2), onTimeout: (sink) => sink.close())) {
          
          final ipAddress = a.address.address;
          Logger.debug('Found IP address: $ipAddress');

          // Extract device ID from service name or properties
          final deviceId = properties['device_id'] ?? _extractDeviceId(serviceName);

          final device = DiscoveredDevice(
            deviceId: deviceId,
            name: serviceName,
            ipAddress: ipAddress,
            port: srv.port,
            properties: properties,
          );

          // Add to discovered devices if not already present
          if (!_discoveredDevices.any((d) => d.deviceId == device.deviceId)) {
            _discoveredDevices.add(device);
            _devicesController.add(List.from(_discoveredDevices));
            Logger.info('Discovered device: $device');
          }
        }
      }
    } catch (e) {
      Logger.error('Error resolving service $serviceName: $e');
    }
  }

  /// Get TXT records for service properties
  Future<Map<String, String>> _getTxtRecords(String serviceName) async {
    final properties = <String, String>{};
    
    if (_mdnsClient == null) return properties;

    try {
      await for (final TxtResourceRecord txt in _mdnsClient!
          .lookup<TxtResourceRecord>(
            ResourceRecordQuery.text(serviceName),
          )
          .timeout(const Duration(seconds: 2), onTimeout: (sink) => sink.close())) {
        
        // Parse TXT record data
        for (final text in txt.text.split('\n')) {
          final parts = text.split('=');
          if (parts.length == 2) {
            properties[parts[0].trim()] = parts[1].trim();
          }
        }
      }
    } catch (e) {
      Logger.debug('Error getting TXT records: $e');
    }

    return properties;
  }

  /// Extract device ID from service name
  String _extractDeviceId(String serviceName) {
    // Service name format: <device-id>._mash-iot._tcp.local
    final parts = serviceName.split('.');
    if (parts.isNotEmpty) {
      return parts[0];
    }
    return serviceName;
  }

  /// Stop discovery
  Future<void> stopDiscovery() async {
    _isDiscovering = false;
    
    if (_mdnsClient != null) {
      try {
        _mdnsClient!.stop();
        _mdnsClient = null;
        Logger.debug('mDNS client stopped');
      } catch (e) {
        Logger.error('Error stopping mDNS client: $e');
      }
    }
  }

  /// Clear discovered devices
  void clearDevices() {
    _discoveredDevices.clear();
    _devicesController.add([]);
  }

  /// Find device by ID
  DiscoveredDevice? findDeviceById(String deviceId) {
    try {
      return _discoveredDevices.firstWhere((d) => d.deviceId == deviceId);
    } catch (e) {
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    stopDiscovery();
    _devicesController.close();
  }
}
