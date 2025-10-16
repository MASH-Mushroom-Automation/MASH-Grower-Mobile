import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../../models/notification_model.dart';

class NotificationRemoteDataSource {
  final Dio _dio = DioClient.instance.dio;

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get(ApiEndpoints.notifications);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get notifications');
      }
    } catch (e) {
      Logger.error('Failed to get notifications: $e');
      rethrow;
    }
  }

  Future<NotificationModel> getNotification(String notificationId) async {
    try {
      final response = await _dio.get(ApiEndpoints.notificationById(notificationId));

      if (response.statusCode == 200) {
        return NotificationModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to get notification');
      }
    } catch (e) {
      Logger.error('Failed to get notification: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _dio.put(ApiEndpoints.notificationRead(notificationId));

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      Logger.error('Failed to mark notification as read: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _dio.put(ApiEndpoints.notifications);

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      Logger.error('Failed to mark all notifications as read: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await _dio.delete(ApiEndpoints.notificationById(notificationId));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      Logger.error('Failed to delete notification: $e');
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get(ApiEndpoints.notificationUnreadCount);

      if (response.statusCode == 200) {
        return response.data['data']['count'] as int;
      } else {
        throw Exception('Failed to get unread count');
      }
    } catch (e) {
      Logger.error('Failed to get unread count: $e');
      rethrow;
    }
  }

  Future<void> updateNotificationPreferences(Map<String, dynamic> preferences) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.notificationPreferences,
        data: preferences,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update notification preferences');
      }
    } catch (e) {
      Logger.error('Failed to update notification preferences: $e');
      rethrow;
    }
  }
}
