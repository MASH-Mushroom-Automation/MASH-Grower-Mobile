import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.read = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      data: json['data'] != null 
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'read': read,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory NotificationModel.fromDatabase(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      data: map['data'] != null 
          ? Map<String, dynamic>.from(map['data'] as Map)
          : null,
      read: (map['read'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'data': data?.toString(),
      'read': read ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? read,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'alert':
        return 'Alert';
      case 'device_status':
        return 'Device Status';
      case 'sensor_data':
        return 'Sensor Data';
      case 'maintenance':
        return 'Maintenance';
      case 'system':
        return 'System';
      case 'order':
        return 'Order';
      case 'payment':
        return 'Payment';
      default:
        return type;
    }
  }

  String get iconName {
    switch (type.toLowerCase()) {
      case 'alert':
        return 'warning';
      case 'device_status':
        return 'device_hub';
      case 'sensor_data':
        return 'analytics';
      case 'maintenance':
        return 'build';
      case 'system':
        return 'settings';
      case 'order':
        return 'shopping_cart';
      case 'payment':
        return 'payment';
      default:
        return 'notifications';
    }
  }

  Duration get age => DateTime.now().difference(createdAt);

  bool get isRecent => age.inHours < 1;
  bool get isOld => age.inDays > 7;

  String get timeAgo {
    final duration = age;
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        message,
        data,
        read,
        createdAt,
      ];
}
