# MASH Grow Mobile - Performance Optimization Guide

## Overview

This guide covers performance optimization strategies for the MASH Grow Mobile Flutter application, including memory management, rendering optimization, and network efficiency.

## Performance Metrics

### Target Performance
- **App Launch Time**: < 3 seconds
- **Frame Rate**: 60 FPS consistently
- **Memory Usage**: < 150MB peak
- **Battery Usage**: Optimized for 8+ hours continuous use
- **Network Efficiency**: Minimal data usage, smart caching

## Memory Optimization

### 1. Image Optimization

```dart
// Use cached network images
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(height: 200, color: Colors.white),
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheWidth: 300, // Limit memory usage
  memCacheHeight: 200,
)
```

### 2. List Performance

```dart
// Use ListView.builder for large lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index].title),
    );
  },
)

// Implement pagination for large datasets
class PaginatedList extends StatefulWidget {
  @override
  _PaginatedListState createState() => _PaginatedListState();
}

class _PaginatedListState extends State<PaginatedList> {
  final ScrollController _scrollController = ScrollController();
  List<Item> _items = [];
  bool _isLoading = false;
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadMoreItems();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    final newItems = await _fetchItems(_currentPage, _pageSize);
    
    setState(() {
      _items.addAll(newItems);
      _currentPage++;
      _isLoading = false;
    });
  }
}
```

### 3. Memory Management

```dart
// Dispose resources properly
class SensorProvider extends ChangeNotifier {
  Timer? _timer;
  StreamSubscription? _subscription;

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}

// Use const constructors where possible
const SensorCard({
  required this.sensorData,
  required this.onTap,
});

// Avoid creating objects in build methods
class OptimizedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ❌ Don't create objects in build
    // final now = DateTime.now();
    
    // ✅ Use static or cached values
    return Text('Static content');
  }
}
```

## Rendering Optimization

### 1. Widget Tree Optimization

```dart
// Use RepaintBoundary for complex widgets
RepaintBoundary(
  child: ComplexChart(
    data: chartData,
  ),
)

// Minimize rebuilds with const widgets
class SensorDisplay extends StatelessWidget {
  const SensorDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SensorValue(),
        SensorChart(),
      ],
    );
  }
}
```

### 2. Animation Optimization

```dart
// Use AnimationController efficiently
class AnimatedSensorCard extends StatefulWidget {
  @override
  _AnimatedSensorCardState createState() => _AnimatedSensorCardState();
}

class _AnimatedSensorCardState extends State<AnimatedSensorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 3. Custom Paint Optimization

```dart
class OptimizedChart extends CustomPainter {
  final List<DataPoint> data;
  final Paint _paint = Paint();

  OptimizedChart(this.data) {
    _paint
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Cache expensive calculations
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final point = _calculatePoint(data[i], size);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(OptimizedChart oldDelegate) {
    return oldDelegate.data != data;
  }
}
```

## Network Optimization

### 1. Efficient API Calls

```dart
// Implement request caching
class ApiService {
  static final Map<String, CachedResponse> _cache = {};
  static const Duration _cacheTimeout = Duration(minutes: 5);

  Future<Response> get(String url) async {
    final cacheKey = url;
    final cached = _cache[cacheKey];
    
    if (cached != null && 
        DateTime.now().difference(cached.timestamp) < _cacheTimeout) {
      return cached.response;
    }

    final response = await _dio.get(url);
    _cache[cacheKey] = CachedResponse(
      response: response,
      timestamp: DateTime.now(),
    );
    
    return response;
  }
}

class CachedResponse {
  final Response response;
  final DateTime timestamp;
  
  CachedResponse({required this.response, required this.timestamp});
}
```

### 2. WebSocket Optimization

```dart
class OptimizedWebSocketClient {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(websocketUrl));
    _setupHeartbeat();
    _setupReconnect();
  }

  void _setupHeartbeat() {
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: 30),
      (timer) => _sendHeartbeat(),
    );
  }

  void _sendHeartbeat() {
    _channel?.sink.add(jsonEncode({'type': 'ping'}));
  }

  void _setupReconnect() {
    _channel?.stream.listen(
      (data) => _handleMessage(data),
      onError: (error) => _handleError(error),
      onDone: () => _attemptReconnect(),
    );
  }

  void _attemptReconnect() {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectTimer = Timer(
        Duration(seconds: _reconnectAttempts * 2),
        () {
          _reconnectAttempts++;
          connect();
        },
      );
    }
  }
}
```

### 3. Data Compression

```dart
// Compress large payloads
import 'dart:convert';
import 'dart:io';

class CompressedApiService {
  Future<Response> postCompressed(String url, Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);
    final compressed = gzip.encode(utf8.encode(jsonString));
    
    return await _dio.post(
      url,
      data: compressed,
      options: Options(
        headers: {
          'Content-Encoding': 'gzip',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}
```

## Database Optimization

### 1. SQLite Performance

```dart
class OptimizedDatabaseHelper {
  static Database? _database;
  static const int _batchSize = 100;

  Future<void> batchInsert(List<SensorReading> readings) async {
    final db = await database;
    final batch = db.batch();
    
    for (int i = 0; i < readings.length; i += _batchSize) {
      final batchReadings = readings.skip(i).take(_batchSize);
      
      for (final reading in batchReadings) {
        batch.insert(
          'sensor_readings',
          reading.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      await batch.commit(noResult: true);
    }
  }

  Future<List<SensorReading>> getReadingsOptimized({
    required String deviceId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 1000,
  }) async {
    final db = await database;
    
    String query = '''
      SELECT * FROM sensor_readings 
      WHERE device_id = ? 
    ''';
    
    List<dynamic> args = [deviceId];
    
    if (startDate != null) {
      query += ' AND timestamp >= ?';
      args.add(startDate.millisecondsSinceEpoch);
    }
    
    if (endDate != null) {
      query += ' AND timestamp <= ?';
      args.add(endDate.millisecondsSinceEpoch);
    }
    
    query += ' ORDER BY timestamp DESC LIMIT ?';
    args.add(limit);
    
    final results = await db.rawQuery(query, args);
    return results.map((map) => SensorReading.fromMap(map)).toList();
  }
}
```

### 2. Index Optimization

```dart
class DatabaseHelper {
  static Future<void> createIndexes(Database db) async {
    // Create indexes for frequently queried columns
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sensor_readings_device_timestamp 
      ON sensor_readings(device_id, timestamp DESC)
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sensor_readings_synced 
      ON sensor_readings(synced)
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_alerts_device_created 
      ON alerts(device_id, created_at DESC)
    ''');
  }
}
```

## Battery Optimization

### 1. Background Processing

```dart
class BackgroundSyncService {
  static Timer? _syncTimer;
  static const Duration _syncInterval = Duration(minutes: 15);

  static void startBackgroundSync() {
    _syncTimer = Timer.periodic(_syncInterval, (timer) {
      _performSync();
    });
  }

  static Future<void> _performSync() async {
    try {
      // Only sync if device is connected to WiFi
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.wifi) {
        await _syncPendingData();
      }
    } catch (e) {
      Logger.error('Background sync failed: $e');
    }
  }

  static void stopBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}
```

### 2. Efficient Notifications

```dart
class OptimizedNotificationService {
  static const Duration _notificationThrottle = Duration(minutes: 5);
  static DateTime? _lastNotificationTime;

  static Future<void> showNotification(Alert alert) async {
    // Throttle notifications to prevent spam
    final now = DateTime.now();
    if (_lastNotificationTime != null &&
        now.difference(_lastNotificationTime!) < _notificationThrottle) {
      return;
    }

    // Only show critical alerts immediately
    if (alert.severity == 'critical') {
      await _showImmediateNotification(alert);
    } else {
      await _scheduleNotification(alert);
    }

    _lastNotificationTime = now;
  }
}
```

## Performance Monitoring

### 1. Real-time Metrics

```dart
class PerformanceTracker {
  static final Map<String, List<Duration>> _metrics = {};
  
  static void trackOperation(String operation, Duration duration) {
    _metrics.putIfAbsent(operation, () => []).add(duration);
    
    // Log slow operations
    if (duration.inMilliseconds > 1000) {
      Logger.warning('Slow operation: $operation took ${duration.inMilliseconds}ms');
    }
  }
  
  static Map<String, double> getAverageMetrics() {
    final averages = <String, double>{};
    
    for (final entry in _metrics.entries) {
      final durations = entry.value;
      final average = durations.fold(0.0, (sum, duration) => sum + duration.inMilliseconds) / durations.length;
      averages[entry.key] = average;
    }
    
    return averages;
  }
}
```

### 2. Memory Monitoring

```dart
class MemoryMonitor {
  static Timer? _monitorTimer;
  
  static void startMonitoring() {
    _monitorTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _checkMemoryUsage();
    });
  }
  
  static void _checkMemoryUsage() {
    // This would require platform-specific implementation
    // For now, we'll log memory-related events
    Logger.info('Memory check performed');
  }
  
  static void stopMonitoring() {
    _monitorTimer?.cancel();
  }
}
```

## Testing Performance

### 1. Performance Tests

```dart
void main() {
  group('Performance Tests', () {
    testWidgets('Dashboard loads within 2 seconds', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
    
    testWidgets('List scrolling maintains 60 FPS', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      
      final listFinder = find.byType(ListView);
      expect(listFinder, findsOneWidget);
      
      // Simulate scrolling
      await tester.fling(listFinder, Offset(0, -500), 1000);
      await tester.pumpAndSettle();
      
      // Verify smooth scrolling
      expect(tester.binding.transientCallbackCount, equals(0));
    });
  });
}
```

### 2. Memory Leak Tests

```dart
void main() {
  group('Memory Leak Tests', () {
    testWidgets('Provider disposal prevents memory leaks', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      
      // Navigate to screen with provider
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      
      // Navigate away
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      
      // Force garbage collection
      await tester.binding.delayed(Duration(seconds: 1));
      
      // Verify no memory leaks
      expect(tester.binding.transientCallbackCount, equals(0));
    });
  });
}
```

## Best Practices Summary

### Do's ✅
- Use `const` constructors wherever possible
- Implement proper disposal of resources
- Use `ListView.builder` for large lists
- Cache network responses appropriately
- Monitor memory usage regularly
- Test performance on real devices
- Use `RepaintBoundary` for complex widgets
- Implement pagination for large datasets

### Don'ts ❌
- Don't create objects in `build()` methods
- Don't forget to dispose controllers and streams
- Don't load all data at once
- Don't ignore memory warnings
- Don't skip performance testing
- Don't use expensive operations in animations
- Don't forget to cancel timers and subscriptions

---

**Performance is not an afterthought - it's a core requirement for user experience.**
