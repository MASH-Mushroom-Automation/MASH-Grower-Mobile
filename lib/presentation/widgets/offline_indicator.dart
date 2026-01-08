import 'package:flutter/material.dart';
import '../../core/services/offline_handler.dart';

/// Widget that displays offline mode indicator banner at top of screen
/// 
/// Features:
/// - Shows when app is offline
/// - Displays data staleness information
/// - Different styles for forced vs actual offline
/// - Tap to see more details
class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _createConnectivityStream(),
      initialData: OfflineHandler().isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        final handler = OfflineHandler();

        if (isOnline) {
          return const SizedBox.shrink();
        }

        return _buildOfflineBanner(context, handler);
      },
    );
  }

  /// Create stream that emits connectivity changes
  Stream<bool> _createConnectivityStream() {
    return Stream.periodic(
      const Duration(seconds: 1),
      (_) => OfflineHandler().isOnline,
    ).distinct();
  }

  Widget _buildOfflineBanner(BuildContext context, OfflineHandler handler) {
    final theme = Theme.of(context);
    final isForcedOffline = handler.isForcedOffline;
    final stalenessMessage = handler.getDataStalenessMessage();

    return Material(
      color: isForcedOffline 
          ? Colors.orange.shade700 
          : theme.colorScheme.error,
      child: InkWell(
        onTap: () => _showOfflineDetails(context, handler),
        child: SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isForcedOffline ? Icons.cloud_off : Icons.wifi_off,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isForcedOffline 
                            ? 'Offline Mode (Manual)' 
                            : 'No Internet Connection',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!handler.hasNetworkConnection || handler.timeSinceLastOnline != null)
                        Text(
                          stalenessMessage,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.info_outline,
                  color: Colors.white.withOpacity(0.8),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show detailed offline mode information dialog
  void _showOfflineDetails(BuildContext context, OfflineHandler handler) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              handler.isForcedOffline ? Icons.cloud_off : Icons.wifi_off,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text('Offline Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              'Status',
              handler.isForcedOffline 
                  ? 'Manually enabled' 
                  : 'No network connection',
            ),
            const SizedBox(height: 12),
            if (handler.hasNetworkConnection)
              _buildInfoRow(
                'Network',
                'Connected',
                trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
              )
            else
              _buildInfoRow(
                'Network',
                'Disconnected',
                trailing: const Icon(Icons.cancel, color: Colors.red, size: 20),
              ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Last Online',
              handler.lastOnlineTimestamp != null
                  ? _formatTimestamp(handler.lastOnlineTimestamp!)
                  : 'Unknown',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Data Age',
              handler.getDataStalenessMessage(),
            ),
            const Divider(height: 24),
            const Text(
              'In offline mode, you can still:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('View cached sensor data'),
            _buildFeatureItem('Control devices locally'),
            _buildFeatureItem('Queue actions for later'),
            const SizedBox(height: 12),
            const Text(
              'Changes will sync when connection is restored.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          if (handler.isForcedOffline)
            TextButton(
              onPressed: () {
                handler.setForcedOfflineMode(false);
                Navigator.of(context).pop();
              },
              child: const Text('Go Online'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Widget? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

/// Compact offline indicator for use in app bars
class CompactOfflineIndicator extends StatelessWidget {
  const CompactOfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _createConnectivityStream(),
      initialData: OfflineHandler().isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        
        if (isOnline) {
          return const SizedBox.shrink();
        }

        final handler = OfflineHandler();
        final theme = Theme.of(context);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: handler.isForcedOffline 
                ? Colors.orange.shade700 
                : theme.colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                handler.isForcedOffline ? Icons.cloud_off : Icons.wifi_off,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Offline',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<bool> _createConnectivityStream() {
    return Stream.periodic(
      const Duration(seconds: 1),
      (_) => OfflineHandler().isOnline,
    ).distinct();
  }
}
