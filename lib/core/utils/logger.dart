import 'dart:developer' as developer;

class Logger {
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(message, name: 'DEBUG', error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(message, name: 'INFO', error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(message, name: 'WARNING', error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(message, name: 'ERROR', error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(message, name: 'FATAL', error: error, stackTrace: stackTrace);
  }

  // Network logging
  static void networkRequest(String method, String url, [Map<String, dynamic>? headers, dynamic body]) {
    info('🌐 $method $url');
    if (headers != null) {
      debug('Headers: $headers');
    }
    if (body != null) {
      debug('Body: $body');
    }
  }

  static void networkResponse(int statusCode, String url, [dynamic response]) {
    if (statusCode >= 200 && statusCode < 300) {
      info('✅ $statusCode $url');
    } else if (statusCode >= 400 && statusCode < 500) {
      warning('⚠️ $statusCode $url');
    } else {
      error('❌ $statusCode $url');
    }
    if (response != null) {
      debug('Response: $response');
    }
  }

  // Database logging
  static void databaseQuery(String query, [List<dynamic>? parameters]) {
    debug('🗄️ Query: $query');
    if (parameters != null) {
      debug('Parameters: $parameters');
    }
  }

  static void databaseResult(int rowCount, [String? operation]) {
    info('📊 Database $operation: $rowCount rows affected');
  }

  // WebSocket logging
  static void websocketConnect(String url) {
    info('🔌 WebSocket connecting to: $url');
  }

  static void websocketConnected() {
    info('✅ WebSocket connected');
  }

  static void websocketDisconnect([String? reason]) {
    warning('🔌 WebSocket disconnected${reason != null ? ': $reason' : ''}');
  }

  static void websocketMessage(String event, [dynamic data]) {
    debug('📨 WebSocket event: $event');
    if (data != null) {
      debug('Data: $data');
    }
  }

  // Authentication logging
  static void authLogin(String method) {
    info('🔐 User login via $method');
  }

  static void authLogout() {
    info('🔐 User logout');
  }

  static void authTokenRefresh() {
    debug('🔄 Token refresh');
  }

  // Sync logging
  static void syncStart() {
    info('🔄 Sync started');
  }

  static void syncComplete(int itemsSynced) {
    info('✅ Sync completed: $itemsSynced items');
  }

  static void syncError(String errorMessage) {
    error('❌ Sync error: $errorMessage');
  }

  // Performance logging
  static void performanceStart(String operation) {
    debug('⏱️ $operation started');
  }

  static void performanceEnd(String operation, Duration duration) {
    info('⏱️ $operation completed in ${duration.inMilliseconds}ms');
  }
}