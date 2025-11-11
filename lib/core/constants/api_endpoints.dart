class ApiEndpoints {
  // Base URLs - Using Railway Production
  static const String baseUrl = 'https://mash-backend-api-production.up.railway.app';
  static const String apiVersion = '/api/v1';
  static const String apiBaseUrl = '$baseUrl$apiVersion';
  
  // For backward compatibility
  static const String devBaseUrl = 'http://localhost:3000/api/v1';
  static const String prodBaseUrl = apiBaseUrl;
  
  // WebSocket URLs
  static const String devWsUrl = 'ws://localhost:3000/ws';
  static const String prodWsUrl = 'wss://mash-backend-api-production.up.railway.app/ws';
  
  // ========== Backend Authentication Endpoints ==========
  // Registration & Email Verification
  static const String authRegister = '$apiBaseUrl/auth/register';
  static const String authVerifyEmail = '$apiBaseUrl/auth/verify-email';
  static const String authVerifyEmailCode = '$apiBaseUrl/auth/verify-email-code'; // 6-digit code (PRIMARY for mobile)
  static const String authResendVerification = '$apiBaseUrl/auth/resend-verification';
  static const String authResendVerificationCode = '$apiBaseUrl/auth/resend-verification-code'; // 6-digit code resend
  
  // Login & Logout
  static const String authLogin = '$apiBaseUrl/auth/login';
  static const String authLogout = '$apiBaseUrl/auth/logout';
  
  // Token Management
  static const String authRefresh = '$apiBaseUrl/auth/refresh-token';
  static const String authVerify = '$apiBaseUrl/auth/verify';
  
  // User Information
  static const String authMe = '$apiBaseUrl/auth/me';
  
  // Password Management
  static const String authForgotPassword = '$apiBaseUrl/auth/forgot-password';
  static const String authResetPassword = '$apiBaseUrl/auth/reset-password';
  
  // OAuth Endpoints
  static const String authOAuthGoogle = '$apiBaseUrl/auth/oauth/google';
  static const String authOAuthGithub = '$apiBaseUrl/auth/oauth/github';
  static const String authOAuthFacebook = '$apiBaseUrl/auth/oauth/facebook';
  static const String authOAuthCallback = '$apiBaseUrl/auth/oauth/callback';
  
  // Legacy Firebase Exchange (to be deprecated)
  static const String authExchange = '$apiBaseUrl/auth/exchange';
  
  // ========== Profile Management Endpoints ==========
  static const String profile = '$apiBaseUrl/users/profile';
  static const String profileAvatar = '$apiBaseUrl/users/profile/avatar';
  static const String profilePassword = '$apiBaseUrl/users/change-password';
  static const String profilePreferences = '$apiBaseUrl/users/profile/preferences';
  
  // Device Endpoints (Protected)
  static const String devices = '$apiBaseUrl/devices';
  static String deviceById(String id) => '$apiBaseUrl/devices/$id';
  static String deviceStatus(String id) => '$apiBaseUrl/devices/$id/status';
  static String deviceCommands(String id) => '$apiBaseUrl/devices/$id/commands';
  static String deviceConfig(String id) => '$apiBaseUrl/devices/$id/config';
  static String deviceLogs(String id) => '$apiBaseUrl/devices/$id/logs';
  
  // Sensor Endpoints (Protected)
  static const String sensorData = '$apiBaseUrl/sensor-data';
  static String sensorDataByDevice(String deviceId) => '$apiBaseUrl/sensor-data/device/$deviceId';
  static String sensorLatest(String deviceId) => '$apiBaseUrl/sensor-data/device/$deviceId/latest';
  static String sensorHistory(String deviceId) => '$apiBaseUrl/sensor-data/device/$deviceId/history';
  static String sensorAnalytics(String deviceId) => '$apiBaseUrl/sensor-data/analytics/$deviceId';
  static String sensorTrends(String deviceId) => '$apiBaseUrl/sensor-data/analytics/$deviceId/trends';
  static String sensorAlerts(String deviceId) => '$apiBaseUrl/sensor-data/analytics/$deviceId/alerts';
  static String sensorExport(String deviceId) => '$apiBaseUrl/sensor-data/analytics/$deviceId/export';
  static const String sensorTypes = '$apiBaseUrl/sensor-data/types';
  static String sensorCalibration(String deviceId) => '$apiBaseUrl/sensor-data/$deviceId/calibration';
  static String sensorCalibrate(String deviceId) => '$apiBaseUrl/sensor-data/$deviceId/calibrate';
  
  // Alert Endpoints (Protected)
  static const String alerts = '$apiBaseUrl/alerts';
  static String alertById(String id) => '$apiBaseUrl/alerts/$id';
  static String alertAcknowledge(String id) => '$apiBaseUrl/alerts/$id/acknowledge';
  static String alertResolve(String id) => '$apiBaseUrl/alerts/$id/resolve';
  static String alertConfig(String deviceId) => '$apiBaseUrl/alerts/config/$deviceId';
  static String alertTest(String deviceId) => '$apiBaseUrl/alerts/test/$deviceId';
  
  // Notification Endpoints
  static const String notifications = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationPreferences = '/notifications/preferences';
  static const String notificationUnreadCount = '/notifications/unread-count';
  
  // User Endpoints
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static String userProfile(String id) => '/users/$id/profile';
  static String userAvatar(String id) => '/users/$id/avatar';
  static String userPreferences(String id) => '/users/$id/preferences';
  static String userDevices(String id) => '/users/$id/devices';
  static String userOrders(String id) => '/users/$id/orders';
  
  // Product Endpoints
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static String productImages(String id) => '/products/$id/images';
  static String productInventory(String id) => '/products/$id/inventory';
  static String productStockAlert(String id) => '/products/$id/stock-alert';
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';
  static String categoryProducts(String id) => '/categories/$id/products';
  static const String inventoryLowStock = '/inventory/low-stock';
  
  // Order Endpoints
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String orderStatus(String id) => '/orders/$id/status';
  static String orderShip(String id) => '/orders/$id/ship';
  static String orderDeliver(String id) => '/orders/$id/deliver';
  static String orderReturn(String id) => '/orders/$id/return';
  static String orderTracking(String id) => '/orders/$id/tracking';
  static const String orderAnalytics = '/orders/analytics';
  static const String orderReports = '/orders/reports';
  static const String orderRevenue = '/orders/revenue';
  
  // Payment Endpoints
  static const String paymentIntent = '/payments/intent';
  static const String paymentConfirm = '/payments/confirm';
  static String paymentById(String id) => '/payments/$id';
  static String paymentRefund(String id) => '/payments/$id/refund';
  static const String paymentMethods = '/payments/methods';
  static const String paymentWebhookStripe = '/payments/webhooks/stripe';
  static const String paymentWebhookPaypal = '/payments/webhooks/paypal';
  static const String paymentWebhookGcash = '/payments/webhooks/gcash';
  
  // File Upload Endpoints
  static const String fileUpload = '/files/upload';
  static String fileById(String id) => '/files/$id';
  static String fileDownload(String id) => '/files/$id/download';
  static const String imageUpload = '/images/upload';
  static const String imageResize = '/images/resize';
  static const String imageOptimize = '/images/optimize';
  static String imageVariants(String id) => '/images/$id/variants';
  
  // Admin Endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminDevices = '/admin/devices';
  static const String adminOrders = '/admin/orders';
  static const String adminAnalytics = '/admin/analytics';
  static String adminUserBan(String id) => '/admin/users/$id/ban';
  static String adminUserUnban(String id) => '/admin/users/$id/unban';
  static const String adminUserReports = '/admin/users/reports';
  static const String adminUserBulkAction = '/admin/users/bulk-action';
  static const String adminConfig = '/admin/config';
  static const String adminLogs = '/admin/logs';
  static const String adminMaintenance = '/admin/maintenance';
  
  // Health Check Endpoints
  static const String health = '/health';
  static const String healthDetailed = '/health/detailed';
  static const String healthDatabase = '/health/database';
  static const String healthRedis = '/health/redis';
  static const String healthMqtt = '/health/mqtt';
  static const String metrics = '/metrics';
  static const String metricsPerformance = '/metrics/performance';
  static const String metricsUsage = '/metrics/usage';
  static const String status = '/status';
}
