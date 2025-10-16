import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../core/utils/logger.dart';
import '../data/models/notification_model.dart';
import '../data/datasources/local/notification_local_datasource.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationLocalDataSource _localDataSource = NotificationLocalDataSource();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        Logger.info('Firebase messaging permission granted');
      } else {
        Logger.warning('Firebase messaging permission denied');
      }

      // Configure foreground message handling
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Configure background message handling
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Configure message opened app
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Get initial message
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      _isInitialized = true;
      Logger.info('Notification service initialized');
    } catch (e) {
      Logger.error('Failed to initialize notification service: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      Logger.info('Received foreground message: ${message.messageId}');
      
      // Create notification model
      final notification = NotificationModel(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: message.data['user_id'] ?? '',
        type: message.data['type'] ?? 'system',
        title: message.notification?.title ?? 'Notification',
        message: message.notification?.body ?? '',
        data: message.data,
        createdAt: DateTime.now(),
      );

      // Save to local storage
      await _localDataSource.saveNotification(notification);

      // Show local notification if needed
      _showLocalNotification(notification);
    } catch (e) {
      Logger.error('Failed to handle foreground message: $e');
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    try {
      Logger.info('Received background message: ${message.messageId}');
      
      // Handle background message processing here
      // Note: This runs in a separate isolate
    } catch (e) {
      Logger.error('Failed to handle background message: $e');
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    try {
      Logger.info('Message opened app: ${message.messageId}');
      
      // Handle navigation based on message data
      final data = message.data;
      if (data.containsKey('route')) {
        // TODO: Navigate to specific route
        Logger.info('Navigate to route: ${data['route']}');
      }
    } catch (e) {
      Logger.error('Failed to handle message opened app: $e');
    }
  }

  void _showLocalNotification(NotificationModel notification) {
    // TODO: Show local notification using flutter_local_notifications
    Logger.info('Show local notification: ${notification.title}');
  }

  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      Logger.info('FCM token: $token');
      return token;
    } catch (e) {
      Logger.error('Failed to get FCM token: $e');
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      Logger.info('Subscribed to topic: $topic');
    } catch (e) {
      Logger.error('Failed to subscribe to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      Logger.info('Unsubscribed from topic: $topic');
    } catch (e) {
      Logger.error('Failed to unsubscribe from topic: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      Logger.info('FCM token deleted');
    } catch (e) {
      Logger.error('Failed to delete FCM token: $e');
    }
  }
}
