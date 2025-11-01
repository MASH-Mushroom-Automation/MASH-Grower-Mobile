import 'environment.dart';

/// API Configuration for Backend Integration
/// 
/// This class manages API endpoints and configuration for different environments.
/// It provides a centralized location for API-related settings including base URLs,
/// API versions, and timeout configurations.
class ApiConfig {
  // Base URLs for different environments
  static const String baseUrlDev = 'http://localhost:3000';
  static const String baseUrlStaging = 'https://staging-api.mashgrower.com';
  static const String baseUrlProd = 'https://api.mashgrower.com';
  
  // API Version
  static const String apiVersion = '/api/v1';
  
  // Timeout Settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  /// Get the base URL based on current environment
  static String get baseUrl {
    switch (EnvironmentConfig.environment) {
      case Environment.development:
        return baseUrlDev;
      case Environment.production:
        return baseUrlProd;
    }
  }
  
  /// Get the full API base URL (baseUrl + apiVersion)
  static String get apiBaseUrl => '$baseUrl$apiVersion';
  
  /// Check if the current environment is development
  static bool get isDevelopment => EnvironmentConfig.environment == Environment.development;
  
  /// Check if the current environment is production
  static bool get isProduction => EnvironmentConfig.environment == Environment.production;
}
