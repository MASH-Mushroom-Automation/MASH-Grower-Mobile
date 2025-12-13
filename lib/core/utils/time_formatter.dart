import 'package:intl/intl.dart';

class TimeFormatter {
  /// Format timestamp to real-time format
  /// Examples: "4:35 PM", "Nov 11, 2025, 8:43 PM"
  static String formatTimestamp(DateTime timestamp, {bool includeDate = false}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final timestampDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (includeDate || !timestampDate.isAtSameMomentAs(today)) {
      // Include date: "Nov 11, 2025, 8:43 PM"
      return DateFormat('MMM d, y, h:mm a').format(timestamp);
    } else {
      // Today, time only: "4:35 PM"
      return DateFormat('h:mm a').format(timestamp);
    }
  }
  
  /// Format timestamp for sensor/actuator logs with full date and time
  static String formatLogTimestamp(DateTime timestamp) {
    return DateFormat('MMM d, y, h:mm a').format(timestamp);
  }
  
  /// Format timestamp for short display (time only)
  static String formatTimeOnly(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }
  
  /// Format timestamp for date only
  static String formatDateOnly(DateTime timestamp) {
    return DateFormat('MMM d, y').format(timestamp);
  }
  
  /// Get aggregation label for time range
  static String getAggregationLabel(String aggregation) {
    switch (aggregation.toLowerCase()) {
      case 'minute':
        return 'Per Minute';
      case 'hour':
        return 'Per Hour';
      case 'day':
        return 'Per Day';
      default:
        return 'Real-time';
    }
  }
}
