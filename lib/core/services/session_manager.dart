import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../utils/logger.dart';

/// Enhanced session management with timeout and activity tracking
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;
  
  Timer? _sessionTimer;
  Timer? _activityTimer;
  DateTime? _lastActivityTime;
  
  /// Session timeout duration (default: 30 minutes)
  static const Duration _sessionTimeout = Duration(minutes: 30);
  
  /// Activity check interval (default: 1 minute)
  static const Duration _activityCheckInterval = Duration(minutes: 1);
  
  /// Callback when session expires
  Function()? _onSessionExpired;
  
  /// Callback when session is about to expire (5 minutes warning)
  Function()? _onSessionAboutToExpire;
  
  /// Session expiry warning threshold (5 minutes before expiry)
  static const Duration _expiryWarningThreshold = Duration(minutes: 5);
  
  bool _isInitialized = false;
  bool _isSessionActive = false;

  /// Initialize session manager
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    await _loadSessionState();
    _isInitialized = true;
    
    Logger.info('SessionManager initialized');
  }

  /// Set callback for session expiration
  void setOnSessionExpired(Function() callback) {
    _onSessionExpired = callback;
  }

  /// Set callback for session about to expire warning
  void setOnSessionAboutToExpire(Function() callback) {
    _onSessionAboutToExpire = callback;
  }

  /// Start session with user activity tracking
  Future<void> startSession({
    required String userId,
    required String email,
    bool rememberMe = false,
  }) async {
    await initialize();
    
    _isSessionActive = true;
    _lastActivityTime = DateTime.now();
    
    // Store session data
    await _prefs!.setString(StorageKeys.currentUserId, userId);
    await _prefs!.setString(StorageKeys.currentUserEmail, email);
    await _prefs!.setBool(StorageKeys.rememberMe, rememberMe);
    await _prefs!.setString(
      StorageKeys.sessionStartTime,
      DateTime.now().toIso8601String(),
    );
    
    // Start session timeout timer
    _startSessionTimer();
    
    Logger.info('Session started for user: $email (Remember me: $rememberMe)');
  }

  /// Record user activity to reset timeout
  void recordActivity() {
    if (!_isSessionActive) return;
    
    _lastActivityTime = DateTime.now();
    
    // Reset session timer
    _sessionTimer?.cancel();
    _startSessionTimer();
  }

  /// End current session
  Future<void> endSession() async {
    await initialize();
    
    _isSessionActive = false;
    _lastActivityTime = null;
    
    // Cancel timers
    _sessionTimer?.cancel();
    _activityTimer?.cancel();
    
    // Clear session data (but keep rememberMe if set)
    final rememberMe = _prefs!.getBool(StorageKeys.rememberMe) ?? false;
    
    await _prefs!.remove(StorageKeys.currentUserId);
    await _prefs!.remove(StorageKeys.currentUserEmail);
    await _prefs!.remove(StorageKeys.sessionStartTime);
    
    // Only clear credentials if rememberMe is false
    if (!rememberMe) {
      await _secureStorage.delete(key: StorageKeys.accessToken);
      await _secureStorage.delete(key: StorageKeys.refreshToken);
      await _prefs!.remove(StorageKeys.rememberMe);
    }
    
    Logger.info('Session ended');
  }

  /// Check if session is active
  bool isSessionActive() {
    return _isSessionActive;
  }

  /// Get time since last activity
  Duration? getTimeSinceLastActivity() {
    if (_lastActivityTime == null) return null;
    return DateTime.now().difference(_lastActivityTime!);
  }

  /// Get remaining session time before timeout
  Duration? getRemainingSessionTime() {
    if (_lastActivityTime == null) return null;
    
    final elapsed = DateTime.now().difference(_lastActivityTime!);
    final remaining = _sessionTimeout - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if remember me is enabled
  Future<bool> isRememberMeEnabled() async {
    await initialize();
    return _prefs!.getBool(StorageKeys.rememberMe) ?? false;
  }

  /// Set remember me preference
  Future<void> setRememberMe(bool enabled) async {
    await initialize();
    await _prefs!.setBool(StorageKeys.rememberMe, enabled);
    Logger.info('Remember me: $enabled');
  }

  /// Load session state from storage
  Future<void> _loadSessionState() async {
    final userId = _prefs!.getString(StorageKeys.currentUserId);
    final sessionStartTime = _prefs!.getString(StorageKeys.sessionStartTime);
    
    if (userId != null && sessionStartTime != null) {
      final startTime = DateTime.parse(sessionStartTime);
      final elapsed = DateTime.now().difference(startTime);
      
      if (elapsed < _sessionTimeout) {
        // Session still valid
        _isSessionActive = true;
        _lastActivityTime = startTime;
        _startSessionTimer();
        Logger.info('Restored active session');
      } else {
        // Session expired
        await endSession();
        Logger.info('Previous session expired');
      }
    }
  }

  /// Start session timeout timer
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    
    // Main session timeout timer
    _sessionTimer = Timer(_sessionTimeout, () {
      _handleSessionExpired();
    });
    
    // Activity check timer (checks every minute)
    _activityTimer?.cancel();
    _activityTimer = Timer.periodic(_activityCheckInterval, (timer) {
      _checkSessionActivity();
    });
  }

  /// Check session activity and warn if about to expire
  void _checkSessionActivity() {
    if (!_isSessionActive || _lastActivityTime == null) {
      _activityTimer?.cancel();
      return;
    }
    
    final elapsed = DateTime.now().difference(_lastActivityTime!);
    final remaining = _sessionTimeout - elapsed;
    
    // Warn when 5 minutes remaining
    if (remaining <= _expiryWarningThreshold && remaining > Duration.zero) {
      _onSessionAboutToExpire?.call();
      Logger.info('Session expiring in ${remaining.inMinutes} minutes');
    }
  }

  /// Handle session expiration
  void _handleSessionExpired() {
    if (!_isSessionActive) return;
    
    Logger.info('Session expired due to inactivity');
    _isSessionActive = false;
    
    // Call expiration callback
    _onSessionExpired?.call();
    
    // Clean up
    endSession();
  }

  /// Extend session (refresh session timeout)
  void extendSession() {
    if (!_isSessionActive) return;
    
    recordActivity();
    Logger.info('Session extended');
  }

  /// Dispose and cleanup
  void dispose() {
    _sessionTimer?.cancel();
    _activityTimer?.cancel();
    Logger.info('SessionManager disposed');
  }
}

/// Multi-Factor Authentication (MFA) Manager
class MFAManager {
  static final MFAManager _instance = MFAManager._internal();
  factory MFAManager() => _instance;
  MFAManager._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  /// Initialize MFA manager
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Check if MFA is enabled for user
  Future<bool> isMFAEnabled() async {
    await initialize();
    return _prefs!.getBool(StorageKeys.mfaEnabled) ?? false;
  }

  /// Enable MFA for user
  Future<void> enableMFA({
    required String userId,
    required String secret,
  }) async {
    await initialize();
    
    // Store MFA secret securely
    await _secureStorage.write(
      key: '${StorageKeys.mfaSecret}_$userId',
      value: secret,
    );
    
    await _prefs!.setBool(StorageKeys.mfaEnabled, true);
    Logger.info('MFA enabled for user');
  }

  /// Disable MFA for user
  Future<void> disableMFA({required String userId}) async {
    await initialize();
    
    await _secureStorage.delete(key: '${StorageKeys.mfaSecret}_$userId');
    await _prefs!.setBool(StorageKeys.mfaEnabled, false);
    
    Logger.info('MFA disabled for user');
  }

  /// Get MFA secret for user
  Future<String?> getMFASecret(String userId) async {
    await initialize();
    return await _secureStorage.read(key: '${StorageKeys.mfaSecret}_$userId');
  }

  /// Verify MFA code (placeholder - actual implementation depends on backend)
  Future<bool> verifyMFACode({
    required String userId,
    required String code,
  }) async {
    await initialize();
    
    // TODO: Implement actual MFA verification with backend
    // This is a placeholder for the MFA foundation
    Logger.info('MFA code verification requested for user: $userId');
    
    return false; // Will be implemented with backend support
  }

  /// Get list of trusted devices
  Future<List<Map<String, dynamic>>> getTrustedDevices() async {
    await initialize();
    
    final devicesJson = _prefs!.getString(StorageKeys.trustedDevices);
    if (devicesJson == null) return [];
    
    // TODO: Parse and return trusted devices list
    return [];
  }

  /// Add current device to trusted devices
  Future<void> addTrustedDevice({
    required String deviceId,
    required String deviceName,
  }) async {
    await initialize();
    
    // TODO: Implement trusted devices management
    Logger.info('Device added to trusted list: $deviceName');
  }

  /// Remove device from trusted devices
  Future<void> removeTrustedDevice(String deviceId) async {
    await initialize();
    
    // TODO: Implement trusted device removal
    Logger.info('Device removed from trusted list: $deviceId');
  }

  /// Check if current device is trusted
  Future<bool> isDeviceTrusted(String deviceId) async {
    await initialize();
    
    // TODO: Implement device trust check
    return false;
  }
}
