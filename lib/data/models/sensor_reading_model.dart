import 'package:equatable/equatable.dart';

class SensorReadingModel extends Equatable {
  final String id;
  final String deviceId;
  final String sensorType;
  final double value;
  final String? qualityIndicator;
  final DateTime timestamp;
  final bool synced;
  final DateTime? createdAt;

  const SensorReadingModel({
    required this.id,
    required this.deviceId,
    required this.sensorType,
    required this.value,
    this.qualityIndicator,
    required this.timestamp,
    this.synced = false,
    this.createdAt,
  });

  factory SensorReadingModel.fromJson(Map<String, dynamic> json) {
    return SensorReadingModel(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      sensorType: json['sensor_type'] as String,
      value: (json['value'] as num).toDouble(),
      qualityIndicator: json['quality_indicator'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      synced: json['synced'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'sensor_type': sensorType,
      'value': value,
      'quality_indicator': qualityIndicator,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'synced': synced,
      'created_at': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory SensorReadingModel.fromDatabase(Map<String, dynamic> map) {
    return SensorReadingModel(
      id: map['id'] as String,
      deviceId: map['device_id'] as String,
      sensorType: map['sensor_type'] as String,
      value: (map['value'] as num).toDouble(),
      qualityIndicator: map['quality_indicator'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      synced: (map['synced'] as int) == 1,
      createdAt: map['created_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'device_id': deviceId,
      'sensor_type': sensorType,
      'value': value,
      'quality_indicator': qualityIndicator,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'synced': synced ? 1 : 0,
      'created_at': createdAt?.millisecondsSinceEpoch,
    };
  }

  SensorReadingModel copyWith({
    String? id,
    String? deviceId,
    String? sensorType,
    double? value,
    String? qualityIndicator,
    DateTime? timestamp,
    bool? synced,
    DateTime? createdAt,
  }) {
    return SensorReadingModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      sensorType: sensorType ?? this.sensorType,
      value: value ?? this.value,
      qualityIndicator: qualityIndicator ?? this.qualityIndicator,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get sensorTypeDisplayName {
    switch (sensorType.toLowerCase()) {
      case 'temperature':
        return 'Temperature';
      case 'humidity':
        return 'Humidity';
      case 'co2':
        return 'CO₂';
      case 'light':
        return 'Light';
      case 'pressure':
        return 'Pressure';
      default:
        return sensorType;
    }
  }

  String get unit {
    switch (sensorType.toLowerCase()) {
      case 'temperature':
        return '°C';
      case 'humidity':
        return '%';
      case 'co2':
        return 'ppm';
      case 'light':
        return 'lux';
      case 'pressure':
        return 'hPa';
      default:
        return '';
    }
  }

  String get formattedValue {
    switch (sensorType.toLowerCase()) {
      case 'temperature':
        return '${value.toStringAsFixed(1)}°C';
      case 'humidity':
        return '${value.toStringAsFixed(1)}%';
      case 'co2':
        return '${value.toStringAsFixed(0)} ppm';
      case 'light':
        return '${value.toStringAsFixed(0)} lux';
      case 'pressure':
        return '${value.toStringAsFixed(1)} hPa';
      default:
        return value.toStringAsFixed(2);
    }
  }

  String get status {
    if (qualityIndicator != null) {
      switch (qualityIndicator!.toLowerCase()) {
        case 'good':
          return 'Good';
        case 'uncertain':
          return 'Uncertain';
        case 'bad':
          return 'Bad';
        default:
          return 'Unknown';
      }
    }
    return 'Good';
  }

  bool get isGood => qualityIndicator == null || qualityIndicator!.toLowerCase() == 'good';
  bool get isUncertain => qualityIndicator?.toLowerCase() == 'uncertain';
  bool get isBad => qualityIndicator?.toLowerCase() == 'bad';

  Duration get age => DateTime.now().difference(timestamp);

  bool get isRecent => age.inMinutes < 5;

  @override
  List<Object?> get props => [
        id,
        deviceId,
        sensorType,
        value,
        qualityIndicator,
        timestamp,
        synced,
        createdAt,
      ];
}
