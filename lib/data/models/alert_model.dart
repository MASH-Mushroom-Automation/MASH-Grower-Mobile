import 'package:equatable/equatable.dart';

class AlertModel extends Equatable {
  final String id;
  final String deviceId;
  final String alertType;
  final String severity;
  final String title;
  final String message;
  final bool acknowledged;
  final bool resolved;
  final DateTime createdAt;

  const AlertModel({
    required this.id,
    required this.deviceId,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.message,
    this.acknowledged = false,
    this.resolved = false,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      alertType: json['alert_type'] as String,
      severity: json['severity'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      acknowledged: json['acknowledged'] as bool? ?? false,
      resolved: json['resolved'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'alert_type': alertType,
      'severity': severity,
      'title': title,
      'message': message,
      'acknowledged': acknowledged,
      'resolved': resolved,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory AlertModel.fromDatabase(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id'] as String,
      deviceId: map['device_id'] as String,
      alertType: map['alert_type'] as String,
      severity: map['severity'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      acknowledged: (map['acknowledged'] as int) == 1,
      resolved: (map['resolved'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'device_id': deviceId,
      'alert_type': alertType,
      'severity': severity,
      'title': title,
      'message': message,
      'acknowledged': acknowledged ? 1 : 0,
      'resolved': resolved ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  AlertModel copyWith({
    String? id,
    String? deviceId,
    String? alertType,
    String? severity,
    String? title,
    String? message,
    bool? acknowledged,
    bool? resolved,
    DateTime? createdAt,
  }) {
    return AlertModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      alertType: alertType ?? this.alertType,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      message: message ?? this.message,
      acknowledged: acknowledged ?? this.acknowledged,
      resolved: resolved ?? this.resolved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get severityDisplayName {
    switch (severity.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'critical':
        return 'Critical';
      default:
        return severity;
    }
  }

  String get alertTypeDisplayName {
    switch (alertType.toLowerCase()) {
      case 'temperature':
        return 'Temperature Alert';
      case 'humidity':
        return 'Humidity Alert';
      case 'co2':
        return 'CO₂ Alert';
      case 'device_offline':
        return 'Device Offline';
      case 'sensor_failure':
        return 'Sensor Failure';
      case 'contamination':
        return 'Contamination Alert';
      case 'maintenance':
        return 'Maintenance Required';
      default:
        return alertType;
    }
  }

  bool get isActive => !resolved;
  bool get isPending => !acknowledged && !resolved;
  bool get isAcknowledged => acknowledged && !resolved;
  bool get isResolved => resolved;

  Duration get age => DateTime.now().difference(createdAt);

  bool get isRecent => age.inHours < 1;
  bool get isOld => age.inDays > 7;

  String get statusText {
    if (isResolved) return 'Resolved';
    if (isAcknowledged) return 'Acknowledged';
    return 'Pending';
  }

  @override
  List<Object?> get props => [
        id,
        deviceId,
        alertType,
        severity,
        title,
        message,
        acknowledged,
        resolved,
        createdAt,
      ];
}
