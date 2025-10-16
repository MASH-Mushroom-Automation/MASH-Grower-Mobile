import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';
import '../../widgets/common/loading_indicator.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () {
              // TODO: Backend Integration - Mark all notifications as read
              // Example API call:
              // PUT /api/notifications/mark-all-read
              // Then refresh local notification state
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mark all as read not implemented yet')),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (notificationProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notificationProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Backend Integration - Retry fetching notifications
                      // This should call: GET /api/notifications
                      notificationProvider.loadNotifications();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (notificationProvider.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: notification.read 
                    ? null 
                    : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getNotificationColor(notification.type),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.message),
                      const SizedBox(height: 4),
                      Text(
                        notification.timeAgo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: notification.read
                      ? null
                      : Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                  onTap: () {
                    // TODO: Mark as read and show details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Notification ${notification.title} details not implemented yet')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'alert':
        return Colors.red;
      case 'device_status':
        return Colors.blue;
      case 'sensor_data':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'system':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'alert':
        return Icons.warning;
      case 'device_status':
        return Icons.device_hub;
      case 'sensor_data':
        return Icons.analytics;
      case 'maintenance':
        return Icons.build;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }
}
