import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Service to manage offline mode state and behavior
/// 
/// Features:
/// - Track online/offline status
/// - Force offline mode toggle
/// - Monitor data staleness
/// - Provide offline mode callbacks
class OfflineHandler {
  static final OfflineHandler _instance = OfflineHandler._internal();
  factory OfflineHandler() => _instance;
  OfflineHandler._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  bool _forcedOfflineMode = false;
  DateTime? _lastOnlineTimestamp;
  
  // Callbacks for connectivity changes
  final List<Function(bool isOnline)> _connectivityListeners = [];

  /// Get current online status (considering forced offline mode)
  bool get isOnline => _forcedOfflineMode ? false : _isOnline;

  /// Get actual network connectivity status (ignoring forced offline)
  bool get hasNetworkConnection => _isOnline;

  /// Check if forced offline mode is enabled
  bool get isForcedOffline => _forcedOfflineMode;

  /// Get last online timestamp
  DateTime? get lastOnlineTimestamp => _lastOnlineTimestamp;

  /// Get duration since last online connection
  Duration? get timeSinceLastOnline {
    if (_lastOnlineTimestamp == null) return null;
    return DateTime.now().difference(_lastOnlineTimestamp!);
  }

  /// Check if data is stale (older than threshold)
  bool isDataStale({Duration threshold = const Duration(hours: 1)}) {
    final timeSince = timeSinceLastOnline;
    if (timeSince == null) return false;
    return timeSince > threshold;
  }

  /// Get human-readable staleness message
  String getDataStalenessMessage() {
    final timeSince = timeSinceLastOnline;
    if (timeSince == null || _isOnline) return 'Data is up to date';

    final hours = timeSince.inHours;
    final minutes = timeSince.inMinutes;
    final days = timeSince.inDays;

    if (days > 0) {
      return 'Data from $days day${days > 1 ? 's' : ''} ago';
    } else if (hours > 0) {
      return 'Data from $hours hour${hours > 1 ? 's' : ''} ago';
    } else if (minutes > 0) {
      return 'Data from $minutes minute${minutes > 1 ? 's' : ''} ago';
    } else {
      return 'Data from moments ago';
    }
  }

  /// Initialize offline handler
  Future<void> initialize() async {
    await _loadForcedOfflinePreference();
    await _checkInitialConnectivity();
    _startConnectivityListener();
    Logger.info('🌐 OfflineHandler initialized - Online: $_isOnline, Forced: $_forcedOfflineMode');
  }

  /// Load forced offline mode preference
  Future<void> _loadForcedOfflinePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _forcedOfflineMode = prefs.getBool('forced_offline_mode') ?? false;
  }

  /// Check initial connectivity status
  Future<void> _checkInitialConnectivity() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    _isOnline = !connectivityResults.contains(ConnectivityResult.none);
    
    if (_isOnline) {
      _lastOnlineTimestamp = DateTime.now();
      await _saveLastOnlineTimestamp();
    } else {
      await _loadLastOnlineTimestamp();
    }
  }

  /// Start listening to connectivity changes
  void _startConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final wasOnline = _isOnline;
      _isOnline = !results.contains(ConnectivityResult.none);

      if (_isOnline && !wasOnline) {
        // Just came back online
        _lastOnlineTimestamp = DateTime.now();
        _saveLastOnlineTimestamp();
        Logger.info('🌐 Network connection restored');
      } else if (!_isOnline && wasOnline) {
        // Just went offline
        Logger.info('🌐 Network connection lost');
      }

      // Notify listeners (only if effective status changed)
      final effectiveStatus = isOnline;
      final wasEffectivelyOnline = _forcedOfflineMode ? false : wasOnline;
      if (effectiveStatus != wasEffectivelyOnline) {
        _notifyListeners(effectiveStatus);
      }
    });
  }

  /// Save last online timestamp to preferences
  Future<void> _saveLastOnlineTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_online_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  /// Load last online timestamp from preferences
  Future<void> _loadLastOnlineTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_online_timestamp');
    if (timestamp != null) {
      _lastOnlineTimestamp = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
  }

  /// Toggle forced offline mode
  Future<void> setForcedOfflineMode(bool enabled) async {
    final wasOnline = isOnline;
    _forcedOfflineMode = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('forced_offline_mode', enabled);

    Logger.info('🌐 Forced offline mode: ${enabled ? 'enabled' : 'disabled'}');

    // Notify listeners if effective status changed
    if (wasOnline != isOnline) {
      _notifyListeners(isOnline);
    }
  }

  /// Add connectivity change listener
  void addConnectivityListener(Function(bool isOnline) listener) {
    _connectivityListeners.add(listener);
  }

  /// Remove connectivity change listener
  void removeConnectivityListener(Function(bool isOnline) listener) {
    _connectivityListeners.remove(listener);
  }

  /// Notify all listeners of connectivity change
  void _notifyListeners(bool isOnline) {
    for (final listener in _connectivityListeners) {
      try {
        listener(isOnline);
      } catch (e) {
        Logger.error('Error notifying connectivity listener', e);
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivityListeners.clear();
  }
}
