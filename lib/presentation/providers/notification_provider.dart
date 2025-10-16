import 'package:flutter/material.dart';

import '../../core/utils/logger.dart';
import '../../data/models/notification_model.dart';
import '../../data/datasources/remote/notification_remote_datasource.dart';
import '../../data/datasources/local/notification_local_datasource.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRemoteDataSource _notificationRemoteDataSource = NotificationRemoteDataSource();
  final NotificationLocalDataSource _notificationLocalDataSource = NotificationLocalDataSource();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotifications() async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implement notification loading
      // For now, return empty list
      _notifications = [];
      _unreadCount = 0;
      Logger.info('Loaded ${_notifications.length} notifications');
    } catch (e) {
      Logger.error('Failed to load notifications: $e');
      _setError('Failed to load notifications');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // TODO: Implement mark as read
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(read: true);
        _unreadCount = _notifications.where((n) => !n.read).length;
        notifyListeners();
        Logger.info('Marked notification as read: $notificationId');
      }
    } catch (e) {
      Logger.error('Failed to mark notification as read: $e');
      _setError('Failed to mark notification as read');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // TODO: Implement mark all as read
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(read: true);
      }
      _unreadCount = 0;
      notifyListeners();
      Logger.info('Marked all notifications as read');
    } catch (e) {
      Logger.error('Failed to mark all notifications as read: $e');
      _setError('Failed to mark all notifications as read');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      // TODO: Implement notification deletion
      _notifications.removeWhere((n) => n.id == notificationId);
      _unreadCount = _notifications.where((n) => !n.read).length;
      notifyListeners();
      Logger.info('Deleted notification: $notificationId');
    } catch (e) {
      Logger.error('Failed to delete notification: $e');
      _setError('Failed to delete notification');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
