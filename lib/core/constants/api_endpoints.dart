class ApiEndpoints {
  // Base URLs
  static const String devBaseUrl = 'http://localhost:3000/api/v1';
  static const String prodBaseUrl = 'https://mash-backend.onrender.com/api/v1';
  
  // WebSocket URLs
  static const String devWsUrl = 'ws://localhost:3000/ws';
  static const String prodWsUrl = 'wss://mash-backend.onrender.com/ws';
  
  // ========== Backend Authentication Endpoints ==========
  // Registration & Email Verification
  static const String authRegister = '/auth/register';
  static const String authVerifyEmail = '/auth/verify-email';
  static const String authResendVerification = '/auth/resend-verification';
  
  // Login & Logout
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  
  // Token Management
  static const String authRefresh = '/auth/refresh';
  static const String authVerify = '/auth/verify';
  
  // User Information
  static const String authMe = '/auth/me';
  
  // Password Management
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  
  // OAuth Endpoints
  static const String authOAuthGoogle = '/auth/oauth/google';
  static const String authOAuthGithub = '/auth/oauth/github';
  static const String authOAuthFacebook = '/auth/oauth/facebook';
  static const String authOAuthCallback = '/auth/oauth/callback';
  
  // Legacy Firebase Exchange (to be deprecated)
  static const String authExchange = '/auth/exchange';
  
  // ========== Profile Management Endpoints ==========
  static const String profile = '/profile';
  static const String profileAvatar = '/profile/avatar';
  static const String profilePassword = '/profile/password';
  static const String profilePreferences = '/profile/preferences';
  
  // Device Endpoints
  static const String devices = '/devices';
  static String deviceById(String id) => '/devices/$id';
  static String deviceStatus(String id) => '/devices/$id/status';
  static String deviceCommands(String id) => '/devices/$id/commands';
  static String deviceConfig(String id) => '/devices/$id/config';
  static String deviceLogs(String id) => '/devices/$id/logs';
  
  // Sensor Endpoints
  static const String sensorData = '/sensors/data';
  static String sensorDataByDevice(String deviceId) => '/sensors/data/$deviceId';
  static String sensorLatest(String deviceId) => '/sensors/data/$deviceId/latest';
  static String sensorHistory(String deviceId) => '/sensors/data/$deviceId/history';
  static String sensorAnalytics(String deviceId) => '/sensors/analytics/$deviceId';
  static String sensorTrends(String deviceId) => '/sensors/analytics/$deviceId/trends';
  static String sensorAlerts(String deviceId) => '/sensors/analytics/$deviceId/alerts';
  static String sensorExport(String deviceId) => '/sensors/analytics/$deviceId/export';
  static const String sensorTypes = '/sensors/types';
  static String sensorCalibration(String deviceId) => '/sensors/$deviceId/calibration';
  static String sensorCalibrate(String deviceId) => '/sensors/$deviceId/calibrate';
  
  // Alert Endpoints
  static const String alerts = '/alerts';
  static String alertById(String id) => '/alerts/$id';
  static String alertAcknowledge(String id) => '/alerts/$id/acknowledge';
  static String alertResolve(String id) => '/alerts/$id/resolve';
  static String alertConfig(String deviceId) => '/alerts/config/$deviceId';
  static String alertTest(String deviceId) => '/alerts/test/$deviceId';
  
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
