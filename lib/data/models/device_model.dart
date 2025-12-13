import 'package:equatable/equatable.dart';

class DeviceModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? deviceType;
  final String? status;
  final bool isActive;
  final DateTime? lastSeen;
  final String? location;
  final String? description;
  final String? serialNumber;
  final String? firmware;
  final String? ipAddress;
  final String? macAddress;
  final Map<String, dynamic>? configuration;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeviceModel({
    required this.id,
    required this.userId,
    required this.name,
    this.deviceType,
    this.status,
    this.isActive = true,
    this.lastSeen,
    this.location,
    this.description,
    this.serialNumber,
    this.firmware,
    this.ipAddress,
    this.macAddress,
    this.configuration,
    this.createdAt,
    this.updatedAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      name: json['name'] as String,
      deviceType: json['type'] as String? ?? json['device_type'] as String?,
      status: json['status'] as String?,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      lastSeen: json['lastSeen'] != null 
          ? DateTime.parse(json['lastSeen'] as String)
          : json['last_seen'] != null 
              ? DateTime.fromMillisecondsSinceEpoch(json['last_seen'] as int)
              : null,
      location: json['location'] as String?,
      description: json['description'] as String?,
      serialNumber: json['serialNumber'] as String? ?? json['serial_number'] as String?,
      firmware: json['firmware'] as String?,
      ipAddress: json['ipAddress'] as String? ?? json['ip_address'] as String?,
      macAddress: json['macAddress'] as String? ?? json['mac_address'] as String?,
      configuration: json['configuration'] != null 
          ? Map<String, dynamic>.from(json['configuration'] as Map)
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null 
              ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int)
              : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null 
              ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': deviceType,
      'status': status,
      'isActive': isActive,
      'lastSeen': lastSeen?.toIso8601String(),
      'location': location,
      'description': description,
      'serialNumber': serialNumber,
      'firmware': firmware,
      'ipAddress': ipAddress,
      'macAddress': macAddress,
      'configuration': configuration,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory DeviceModel.fromDatabase(Map<String, dynamic> map) {
    return DeviceModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      deviceType: map['device_type'] as String?,
      status: map['status'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      lastSeen: map['last_seen'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['last_seen'] as int)
          : null,
      location: map['location'] as String?,
      description: map['description'] as String?,
      serialNumber: map['serial_number'] as String?,
      firmware: map['firmware'] as String?,
      ipAddress: map['ip_address'] as String?,
      macAddress: map['mac_address'] as String?,
      configuration: map['configuration'] != null 
          ? Map<String, dynamic>.from(map['configuration'] as Map)
          : null,
      createdAt: map['created_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'device_type': deviceType,
      'status': status,
      'is_active': isActive ? 1 : 0,
      'last_seen': lastSeen?.millisecondsSinceEpoch,
      'location': location,
      'description': description,
      'serial_number': serialNumber,
      'firmware': firmware,
      'ip_address': ipAddress,
      'mac_address': macAddress,
      'configuration': configuration != null 
          ? configuration.toString() 
          : null,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  DeviceModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? deviceType,
    String? status,
    bool? isActive,
    DateTime? lastSeen,
    String? location,
    String? description,
    String? serialNumber,
    String? firmware,
    String? ipAddress,
    String? macAddress,
    Map<String, dynamic>? configuration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      deviceType: deviceType ?? this.deviceType,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      lastSeen: lastSeen ?? this.lastSeen,
      location: location ?? this.location,
      description: description ?? this.description,
      serialNumber: serialNumber ?? this.serialNumber,
      firmware: firmware ?? this.firmware,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      configuration: configuration ?? this.configuration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOnline => status == 'online';
  bool get isOffline => status == 'offline';
  bool get hasError => status == 'error';
  bool get isMaintenance => status == 'maintenance';

  String get statusDisplayName {
    switch (status) {
      case 'online':
        return 'Online';
      case 'offline':
        return 'Offline';
      case 'error':
        return 'Error';
      case 'maintenance':
        return 'Maintenance';
      default:
        return 'Unknown';
    }
  }

  String get deviceTypeDisplayName {
    switch (deviceType) {
      case 'grow_chamber':
        return 'Grow Chamber';
      case 'sensor_module':
        return 'Sensor Module';
      case 'control_unit':
        return 'Control Unit';
      default:
        return deviceType ?? 'Unknown';
    }
  }

  Duration? get timeSinceLastSeen {
    if (lastSeen == null) return null;
    return DateTime.now().difference(lastSeen!);
  }

  bool get isRecentlyActive {
    final timeSince = timeSinceLastSeen;
    if (timeSince == null) return false;
    return timeSince.inMinutes < 5; // Active if seen within last 5 minutes
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        deviceType,
        status,
        isActive,
        lastSeen,
        location,
        description,
        serialNumber,
        firmware,
        ipAddress,
        macAddress,
        configuration,
        createdAt,
        updatedAt,
      ];
}
