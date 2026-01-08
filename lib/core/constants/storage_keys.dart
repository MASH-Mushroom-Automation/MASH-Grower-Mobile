class StorageKeys {
  // Authentication
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String firebaseToken = 'firebase_token';
  static const String userData = 'user_data';
  static const String lastLoginTime = 'last_login_time';
  
  // Biometric Authentication
  static const String biometricEnabled = 'biometric_enabled';
  static const String biometricCredentials = 'biometric_credentials';
  
  // Session Management
  static const String rememberMe = 'remember_me';
  static const String currentUserId = 'current_user_id';
  static const String currentUserEmail = 'current_user_email';
  static const String sessionStartTime = 'session_start_time';
  static const String sessionTimeout = 'session_timeout';
  
  // Multi-Factor Authentication
  static const String mfaEnabled = 'mfa_enabled';
  static const String mfaSecret = 'mfa_secret';
  static const String trustedDevices = 'trusted_devices';
  
  // User Preferences
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String pushNotificationsEnabled = 'push_notifications_enabled';
  static const String soundEnabled = 'sound_enabled';
  static const String vibrationEnabled = 'vibration_enabled';
  
  // Device Settings
  static const String selectedDevice = 'selected_device';
  static const String deviceConfigurations = 'device_configurations';
  static const String alertThresholds = 'alert_thresholds';
  
  // Sync Settings
  static const String lastSyncTime = 'last_sync_time';
  static const String syncEnabled = 'sync_enabled';
  static const String offlineMode = 'offline_mode';
  
  // App Settings
  static const String firstLaunch = 'first_launch';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String appVersion = 'app_version';
  static const String lastUpdateCheck = 'last_update_check';
  
  // Cache Settings
  static const String cacheExpiry = 'cache_expiry';
  static const String dataRetentionDays = 'data_retention_days';
  
  // Debug Settings
  static const String debugMode = 'debug_mode';
  static const String logLevel = 'log_level';
  static const String crashReportingEnabled = 'crash_reporting_enabled';
}
