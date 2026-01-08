import 'package:flutter/material.dart';
import 'dart:async';

/// Session Timeout Warning Dialog
///
/// Shows a countdown dialog warning the user that their session is about to expire.
/// Provides options to extend the session or logout immediately.
class SessionTimeoutDialog extends StatefulWidget {
  final Duration remainingTime;
  final VoidCallback onExtendSession;
  final VoidCallback onLogout;

  const SessionTimeoutDialog({
    super.key,
    required this.remainingTime,
    required this.onExtendSession,
    required this.onLogout,
  });

  @override
  State<SessionTimeoutDialog> createState() => _SessionTimeoutDialogState();
}

class _SessionTimeoutDialogState extends State<SessionTimeoutDialog> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.remainingTime;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        setState(() {
          _remaining = Duration(seconds: _remaining.inSeconds - 1);
        });
      } else {
        timer.cancel();
        // Auto-logout when time expires
        if (mounted) {
          Navigator.of(context).pop();
          widget.onLogout();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = _remaining.inSeconds <= 60;

    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissing by tapping outside
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.timer_outlined,
              color: isUrgent ? Colors.red : const Color(0xFF2D5F4C),
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Session Expiring Soon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your session is about to expire due to inactivity.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Countdown Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUrgent ? Colors.red.shade300 : Colors.green.shade300,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Time Remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(_remaining),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isUrgent ? Colors.red : const Color(0xFF2D5F4C),
                      fontFeatures: const [
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Do you want to continue your session?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          // Logout Button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onLogout();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 16),
            ),
          ),
          // Extend Session Button
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onExtendSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5F4C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue Session',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact Session Timeout Warning Banner
///
/// Shows a persistent banner at the top of the screen when session is about to expire.
/// Less intrusive than the dialog, can be used for longer warning periods.
class SessionTimeoutBanner extends StatefulWidget {
  final Duration remainingTime;
  final VoidCallback onExtendSession;
  final VoidCallback onDismiss;

  const SessionTimeoutBanner({
    super.key,
    required this.remainingTime,
    required this.onExtendSession,
    required this.onDismiss,
  });

  @override
  State<SessionTimeoutBanner> createState() => _SessionTimeoutBannerState();
}

class _SessionTimeoutBannerState extends State<SessionTimeoutBanner> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.remainingTime;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        setState(() {
          _remaining = Duration(seconds: _remaining.inSeconds - 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        border: Border(
          bottom: BorderSide(
            color: Colors.orange.shade300,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: Colors.orange.shade900,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Session expiring in ${_formatDuration(_remaining)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                  ),
                ),
                Text(
                  'Tap to extend your session',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: widget.onExtendSession,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF2D5F4C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Extend',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: widget.onDismiss,
            icon: Icon(
              Icons.close,
              color: Colors.orange.shade900,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
