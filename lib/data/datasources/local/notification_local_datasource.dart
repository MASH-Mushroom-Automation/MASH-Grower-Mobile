import '../local/database_helper.dart';
import '../../models/notification_model.dart';
import '../../../core/utils/logger.dart';

class NotificationLocalDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> saveNotification(NotificationModel notification) async {
    try {
      await _databaseHelper.insert('notifications', notification.toDatabase());
      Logger.databaseResult(1, 'INSERT');
    } catch (e) {
      Logger.error('Failed to save notification: $e');
      rethrow;
    }
  }

  Future<void> saveNotifications(List<NotificationModel> notifications) async {
    try {
      await _databaseHelper.transaction((txn) async {
        for (final notification in notifications) {
          await txn.insert('notifications', notification.toDatabase());
        }
      });
      Logger.databaseResult(notifications.length, 'BATCH INSERT');
    } catch (e) {
      Logger.error('Failed to save notifications: $e');
      rethrow;
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final results = await _databaseHelper.query(
        'notifications',
        orderBy: 'created_at DESC',
      );

      return results.map((map) => NotificationModel.fromDatabase(map)).toList();
    } catch (e) {
      Logger.error('Failed to get notifications: $e');
      return [];
    }
  }

  Future<NotificationModel?> getNotification(String notificationId) async {
    try {
      final result = await _databaseHelper.queryFirst(
        'notifications',
        where: 'id = ?',
        whereArgs: [notificationId],
      );

      return result != null ? NotificationModel.fromDatabase(result) : null;
    } catch (e) {
      Logger.error('Failed to get notification: $e');
      return null;
    }
  }

  Future<List<NotificationModel>> getNotificationsByUser(String userId) async {
    try {
      final results = await _databaseHelper.query(
        'notifications',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return results.map((map) => NotificationModel.fromDatabase(map)).toList();
    } catch (e) {
      Logger.error('Failed to get notifications by user: $e');
      return [];
    }
  }

  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final results = await _databaseHelper.query(
        'notifications',
        where: 'read = 0',
        orderBy: 'created_at DESC',
      );

      return results.map((map) => NotificationModel.fromDatabase(map)).toList();
    } catch (e) {
      Logger.error('Failed to get unread notifications: $e');
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final results = await _databaseHelper.query(
        'notifications',
        where: 'read = 0',
      );

      return results.length;
    } catch (e) {
      Logger.error('Failed to get unread count: $e');
      return 0;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _databaseHelper.update(
        'notifications',
        {'read': 1},
        where: 'id = ?',
        whereArgs: [notificationId],
      );
      Logger.databaseResult(1, 'UPDATE');
    } catch (e) {
      Logger.error('Failed to mark notification as read: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _databaseHelper.update(
        'notifications',
        {'read': 1},
      );
      Logger.databaseResult(1, 'BATCH UPDATE');
    } catch (e) {
      Logger.error('Failed to mark all notifications as read: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _databaseHelper.delete(
        'notifications',
        where: 'id = ?',
        whereArgs: [notificationId],
      );
      Logger.databaseResult(1, 'DELETE');
    } catch (e) {
      Logger.error('Failed to delete notification: $e');
      rethrow;
    }
  }

  Future<void> deleteOldNotifications(int daysToKeep) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      final deletedCount = await _databaseHelper.delete(
        'notifications',
        where: 'created_at < ?',
        whereArgs: [cutoffDate.millisecondsSinceEpoch],
      );
      
      Logger.info('Deleted $deletedCount old notifications');
    } catch (e) {
      Logger.error('Failed to delete old notifications: $e');
      rethrow;
    }
  }

  Future<void> clearNotifications() async {
    try {
      await _databaseHelper.delete('notifications');
      Logger.info('Cleared all notifications');
    } catch (e) {
      Logger.error('Failed to clear notifications: $e');
      rethrow;
    }
  }
}
