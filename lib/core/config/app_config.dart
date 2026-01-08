class AppConfig {
  static const String appName = 'MASH Grow';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // API Configuration
  static const String devApiBaseUrl = 'http://localhost:3000/api/v1';
  static const String prodApiBaseUrl = 'https://mash-backend-production.up.railway.app/api/v1';
  
  // WebSocket Configuration
  static const String devWsUrl = 'ws://localhost:3000/ws';
  static const String prodWsUrl = 'wss://mash-backend-production.up.railway.app/ws';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'mash-grower-app';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String themeModeKey = 'theme_mode';
  
  // Database Configuration
  static const String databaseName = 'mash_grower.db';
  static const int databaseVersion = 1;
  
  // Sensor Configuration
  static const Map<String, Map<String, double>> sensorThresholds = {
    'temperature': {
      'min': 20.0,
      'max': 30.0,
      'optimal_min': 25.0,
      'optimal_max': 28.0,
    },
    'humidity': {
      'min': 70.0,
      'max': 95.0,
      'optimal_min': 80.0,
      'optimal_max': 90.0,
    },
    'co2': {
      'min': 5000.0,
      'max': 20000.0,
      'optimal_min': 10000.0,
      'optimal_max': 15000.0,
    },
  };
  
  // Alert Severity Colors
  static const Map<String, int> alertSeverityColors = {
    'low': 0xFF4CAF50,      // Green
    'medium': 0xFFFF9800,    // Orange
    'high': 0xFFFF5722,      // Deep Orange
    'critical': 0xFFF44336,  // Red
  };
  
  // Sync Configuration
  static const int syncIntervalSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const int syncBatchSize = 100;
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
