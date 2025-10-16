import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<Duration>> _durations = {};

  /// Start timing an operation
  static void startTiming(String operation) {
    _startTimes[operation] = DateTime.now();
    if (kDebugMode) {
      developer.log('⏱️ $operation started', name: 'Performance');
    }
  }

  /// End timing an operation and log the duration
  static Duration endTiming(String operation) {
    final startTime = _startTimes.remove(operation);
    if (startTime == null) {
      developer.log('⚠️ No start time found for operation: $operation', name: 'Performance');
      return Duration.zero;
    }

    final duration = DateTime.now().difference(startTime);
    
    // Store duration for analytics
    _durations.putIfAbsent(operation, () => []).add(duration);
    
    if (kDebugMode) {
      developer.log('⏱️ $operation completed in ${duration.inMilliseconds}ms', name: 'Performance');
    }

    // Log slow operations
    if (duration.inMilliseconds > 1000) {
      developer.log('🐌 Slow operation detected: $operation took ${duration.inMilliseconds}ms', name: 'Performance');
    }

    return duration;
  }

  /// Get average duration for an operation
  static Duration? getAverageDuration(String operation) {
    final durations = _durations[operation];
    if (durations == null || durations.isEmpty) return null;

    final totalMs = durations.fold<int>(0, (sum, duration) => sum + duration.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ durations.length);
  }

  /// Get all performance metrics
  static Map<String, Duration?> getAllMetrics() {
    final metrics = <String, Duration?>{};
    for (final operation in _durations.keys) {
      metrics[operation] = getAverageDuration(operation);
    }
    return metrics;
  }

  /// Clear all performance data
  static void clearMetrics() {
    _startTimes.clear();
    _durations.clear();
  }

  /// Log performance summary
  static void logPerformanceSummary() {
    if (kDebugMode) {
      developer.log('📊 Performance Summary:', name: 'Performance');
      final metrics = getAllMetrics();
      for (final entry in metrics.entries) {
        final avgDuration = entry.value;
        if (avgDuration != null) {
          developer.log('  ${entry.key}: ${avgDuration.inMilliseconds}ms average', name: 'Performance');
        }
      }
    }
  }
}

/// Widget performance monitoring mixin
mixin PerformanceMixin<T extends StatefulWidget> on State<T> {
  Timer? _frameTimer;
  int _frameCount = 0;
  DateTime? _lastFrameTime;

  void initPerformanceMonitoring() {
    _startFrameMonitoring();
  }

  void disposePerformanceMonitoring() {
    _frameTimer?.cancel();
  }

  void _startFrameMonitoring() {
    if (kDebugMode) {
      _frameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _logFrameRate();
      });
    }
  }

  void _logFrameRate() {
    if (_lastFrameTime != null) {
      final fps = _frameCount / (DateTime.now().difference(_lastFrameTime!).inSeconds);
      if (fps < 50) { // Alert if FPS drops below 50
        developer.log('🐌 Low FPS detected: ${fps.toStringAsFixed(1)} FPS', name: 'Performance');
      }
    }
    _frameCount = 0;
    _lastFrameTime = DateTime.now();
  }

  void onFrame() {
    _frameCount++;
  }
}

/// Memory usage monitoring
class MemoryMonitor {
  static void logMemoryUsage(String context) {
    if (kDebugMode) {
      // This would require platform-specific implementation
      // For now, we'll just log the context
      developer.log('🧠 Memory check at: $context', name: 'Memory');
    }
  }

  static void logMemoryWarning(String context, int estimatedUsage) {
    if (kDebugMode) {
      developer.log('⚠️ High memory usage detected at $context: ${estimatedUsage}MB', name: 'Memory');
    }
  }
}
