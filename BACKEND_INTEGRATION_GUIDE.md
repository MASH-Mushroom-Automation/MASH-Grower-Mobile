# Backend Integration Guide for MASH Grow Mobile App

## Overview
This document outlines all the backend integration points in the Flutter mobile application. Each section corresponds to specific API endpoints from the NestJS backend.

---

## Authentication Integration

### Login Screen (`lib/presentation/screens/auth/login_screen.dart`)

**After Clerk Authentication Success:**
```dart
// Fetch user profile from backend
final userProfile = await apiService.getUserProfile(authProvider.userId);

// Fetch user's devices
final devices = await apiService.getUserDevices(authProvider.userId);
Provider.of<DeviceProvider>(context, listen: false).setDevices(devices);
```

**API Endpoints:**
- `GET /api/auth/me` - Get current authenticated user
- `GET /api/users/:id/devices` - Get user's devices

---

### Register Screen (`lib/presentation/screens/auth/register_screen.dart`)

**After Clerk Registration Success:**
```dart
// Create user profile in backend
final profileData = {
  'firstName': _firstNameController.text.trim(),
  'lastName': _lastNameController.text.trim(),
  'email': _emailController.text.trim(),
};
await apiService.createUserProfile(authProvider.userId, profileData);

// Initialize user data
await apiService.initializeUserData(authProvider.userId);
```

**API Endpoints:**
- `POST /api/users` - Create user profile
- `PUT /api/users/:id/profile` - Update user profile

---

## Home Screen Integration

### Home Screen (`lib/presentation/screens/home/home_screen.dart`)

**On Screen Initialization:**
```dart
// Load user's devices from backend
deviceProvider.fetchDevicesFromBackend();
// Calls: GET /api/users/:userId/devices

// Load user's notifications/alerts
notificationProvider.fetchNotificationsFromBackend();
// Calls: GET /api/notifications
```

**Device Registration (FAB Button):**
```dart
// Register new IoT device
// 1. Show device registration dialog
// 2. Collect device info (serial number, name, etc.)
// 3. POST /api/devices with device data
// 4. On success, add device to local state
```

**API Endpoints:**
- `GET /api/users/:id/devices` - Get user's devices
- `GET /api/notifications` - Get notifications
- `POST /api/devices` - Register new device

---

## Dashboard Integration

### Dashboard Screen (`lib/presentation/screens/dashboard/dashboard_screen.dart`)

**Refresh Button:**
```dart
// Get latest sensor readings
GET /api/sensors/data/:deviceId/latest

// Get device status
GET /api/devices/:id/status

// Update local state with fresh data
sensorProvider.refreshSensorData();
deviceProvider.loadDevices();
```

**API Endpoints:**
- `GET /api/sensors/data/:deviceId/latest` - Latest sensor readings
- `GET /api/devices/:id/status` - Device status
- `GET /api/sensors/analytics/:deviceId` - Sensor analytics

---

## Device Management Integration

### Device List Screen (`lib/presentation/screens/devices/device_list_screen.dart`)

**Load Devices:**
```dart
// Fetch all user devices
GET /api/users/:userId/devices
```

**Add New Device:**
```dart
// Register new device
POST /api/devices
{
  "name": "Mushroom Chamber #1",
  "device_type": "MASH_CHAMBER",
  "serial_number": "RPI-001",
  "mac_address": "B8:27:EB:XX:XX:XX"
}
```

**Device Control:**
```dart
// Send command to device
POST /api/devices/:id/commands
{
  "command_type": "SET_HUMIDITY",
  "command_data": {
    "target": 85,
    "duration": 3600
  }
}
```

**API Endpoints:**
- `GET /api/devices` - Get user's devices
- `POST /api/devices` - Register new device
- `GET /api/devices/:id` - Get device details
- `PUT /api/devices/:id` - Update device configuration
- `POST /api/devices/:id/commands` - Send command to device
- `GET /api/devices/:id/status` - Get device status

---

## Sensor Data Integration

### Sensor Provider (`lib/presentation/providers/sensor_provider.dart`)

**Real-time Sensor Data:**
```dart
// Get latest readings
GET /api/sensors/data/:deviceId/latest

// Get historical data
GET /api/sensors/data/:deviceId/history?start=2025-10-01&end=2025-10-17

// Get sensor analytics
GET /api/sensors/analytics/:deviceId

// Get trends
GET /api/sensors/analytics/:deviceId/trends
```

**API Endpoints:**
- `GET /api/sensors/data/:deviceId/latest` - Latest readings
- `GET /api/sensors/data/:deviceId/history` - Historical data
- `GET /api/sensors/analytics/:deviceId` - Analytics
- `GET /api/sensors/analytics/:deviceId/trends` - Data trends
- `POST /api/sensors/analytics/:deviceId/export` - Export data

---

## Notifications & Alerts Integration

### Notification List Screen (`lib/presentation/screens/notifications/notification_list_screen.dart`)

**Load Notifications:**
```dart
// Get all notifications
GET /api/notifications

// Get unread count
GET /api/notifications/unread-count
```

**Mark as Read:**
```dart
// Mark single notification as read
PUT /api/notifications/:id/read

// Mark all as read
PUT /api/notifications/mark-all-read
```

**Alert Management:**
```dart
// Acknowledge alert
POST /api/alerts/:id/acknowledge

// Resolve alert
POST /api/alerts/:id/resolve
```

**API Endpoints:**
- `GET /api/notifications` - Get user notifications
- `PUT /api/notifications/:id/read` - Mark as read
- `GET /api/notifications/unread-count` - Get unread count
- `GET /api/alerts` - Get user alerts
- `POST /api/alerts/:id/acknowledge` - Acknowledge alert
- `POST /api/alerts/:id/resolve` - Resolve alert

---

## WebSocket Integration

### Real-time Updates

**Connect to WebSocket:**
```dart
// WebSocket URL
wss://mash-backend.onrender.com/ws

// Subscribe to events
socket.on('device:status', (data) => updateDeviceStatus(data));
socket.on('sensor:data', (data) => updateSensorData(data));
socket.on('alert:new', (data) => showNewAlert(data));
socket.on('notification:new', (data) => showNotification(data));
```

**WebSocket Events:**
- `device:status` - Device status updates
- `sensor:data` - Real-time sensor data
- `alert:new` - New alert notifications
- `alert:resolved` - Alert resolution updates
- `notification:new` - New notifications

---

## Data Models Alignment

### User Model
```dart
class UserModel {
  final String id;              // UUID from backend
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final String role;            // 'admin', 'user', 'seller'
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Device Model
```dart
class DeviceModel {
  final String id;              // UUID from backend
  final String userId;
  final String name;
  final String deviceType;      // 'MASH_CHAMBER'
  final String status;          // 'online', 'offline', 'error'
  final Map<String, dynamic> configuration;
  final DateTime? lastSeen;
  final DateTime createdAt;
}
```

### Sensor Reading Model
```dart
class SensorReadingModel {
  final String id;              // UUID from backend
  final String deviceId;
  final String sensorType;      // 'temperature', 'humidity', 'co2'
  final double value;
  final String unit;            // 'celsius', 'percent', 'ppm'
  final String qualityIndicator; // 'good', 'uncertain', 'bad'
  final DateTime timestamp;
}
```

### Alert Model
```dart
class AlertModel {
  final String id;              // UUID from backend
  final String deviceId;
  final String alertType;
  final String severity;        // 'low', 'medium', 'high', 'critical'
  final String title;
  final String message;
  final bool acknowledged;
  final bool resolved;
  final DateTime createdAt;
}
```

---

## Implementation Steps

### 1. Update Remote Data Sources

**File:** `lib/data/datasources/remote/auth_remote_datasource.dart`
- Already has basic structure
- Add methods for user profile management

**File:** `lib/data/datasources/remote/device_remote_datasource.dart`
- Add device registration
- Add device control commands
- Add device status fetching

**File:** `lib/data/datasources/remote/sensor_remote_datasource.dart`
- Add real-time data fetching
- Add historical data queries
- Add analytics endpoints

**File:** `lib/data/datasources/remote/notification_remote_datasource.dart`
- Add notification fetching
- Add mark as read functionality
- Add alert management

### 2. Update Providers

**File:** `lib/presentation/providers/auth_provider.dart`
- Remove bypass/demo logic
- Integrate with Clerk authentication
- Call backend APIs after Clerk auth

**File:** `lib/presentation/providers/device_provider.dart`
- Fetch devices from backend
- Send commands to devices
- Update device status

**File:** `lib/presentation/providers/sensor_provider.dart`
- Fetch real-time sensor data
- Load historical data
- Handle WebSocket updates

**File:** `lib/presentation/providers/notification_provider.dart`
- Fetch notifications from backend
- Mark notifications as read
- Handle alert acknowledgment

### 3. Configure API Client

**File:** `lib/core/network/dio_client.dart`
- Ensure proper base URL configuration
- Add authentication interceptors
- Add error handling

**File:** `lib/core/constants/api_endpoints.dart`
- Already configured with all endpoints
- Verify endpoint paths match backend

### 4. WebSocket Integration

**Create:** `lib/services/websocket_service.dart`
```dart
class WebSocketService {
  late WebSocketChannel _channel;
  
  void connect(String token) {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://mash-backend.onrender.com/ws?token=$token'),
    );
  }
  
  void subscribe(String event, Function(dynamic) callback) {
    // Handle event subscriptions
  }
}
```

---

## Environment Configuration

### Development
```dart
static const String devBaseUrl = 'http://localhost:3000/api/v1';
static const String devWsUrl = 'ws://localhost:3000/ws';
```

### Production
```dart
static const String prodBaseUrl = 'https://mash-backend.onrender.com/api/v1';
static const String prodWsUrl = 'wss://mash-backend.onrender.com/ws';
```

---

## Testing Checklist

- [ ] Authentication flow (login/register)
- [ ] User profile fetching
- [ ] Device registration
- [ ] Device list loading
- [ ] Sensor data fetching (latest)
- [ ] Sensor data fetching (historical)
- [ ] Device command sending
- [ ] Alert fetching
- [ ] Alert acknowledgment
- [ ] Notification loading
- [ ] Notification mark as read
- [ ] WebSocket connection
- [ ] Real-time sensor updates
- [ ] Real-time alert notifications

---

## Error Handling

All API calls should handle:
1. Network errors (no internet)
2. Authentication errors (401)
3. Authorization errors (403)
4. Not found errors (404)
5. Server errors (500)
6. Timeout errors

Example:
```dart
try {
  final response = await _dio.get(endpoint);
  return response.data;
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    throw NetworkException('Connection timeout');
  } else if (e.response?.statusCode == 401) {
    throw AuthenticationException('Unauthorized');
  }
  rethrow;
}
```

---

## Next Steps

1. **Remove Demo/Bypass Logic**: Update `auth_provider.dart` to use real Clerk authentication
2. **Implement Remote Data Sources**: Complete all API call implementations
3. **Update Providers**: Connect providers to remote data sources
4. **Add WebSocket Service**: Implement real-time updates
5. **Test Integration**: Test each endpoint with backend
6. **Handle Offline Mode**: Implement offline-first with local SQLite sync

---

**Document Version:** 1.0  
**Last Updated:** October 17, 2025  
**Author:** Development Team
