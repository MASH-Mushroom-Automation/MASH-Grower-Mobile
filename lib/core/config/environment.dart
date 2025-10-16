enum Environment { development, production }

class EnvironmentConfig {
  static Environment _environment = Environment.development;
  
  static Environment get environment => _environment;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  // API Configuration
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://localhost:3000/api/v1';
      case Environment.production:
        return 'https://mash-backend.onrender.com/api/v1';
    }
  }
  
  static String get wsBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'ws://localhost:3000/ws';
      case Environment.production:
        return 'wss://mash-backend.onrender.com/ws';
    }
  }
  
  // Firebase Configuration
  static String get firebaseProjectId {
    switch (_environment) {
      case Environment.development:
        return 'mash-grower-dev';
      case Environment.production:
        return 'mash-grower-prod';
    }
  }
  
  // App Configuration
  static bool get isDebugMode {
    switch (_environment) {
      case Environment.development:
        return true;
      case Environment.production:
        return false;
    }
  }
  
  static String get appName {
    switch (_environment) {
      case Environment.development:
        return 'M.A.S.H. Grower (Dev)';
      case Environment.production:
        return 'M.A.S.H. Grower';
    }
  }
}
