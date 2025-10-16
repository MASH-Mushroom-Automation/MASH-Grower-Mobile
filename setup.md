# M.A.S.H. Grower Mobile App - Setup Guide

## Quick Start

1. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase**
   - Create a Firebase project at https://console.firebase.google.com
   - Add Android app to your Firebase project
   - Download `google-services.json` and place it in `android/app/`
   - Add iOS app to your Firebase project
   - Download `GoogleService-Info.plist` and place it in `ios/Runner/`

3. **Configure Environment Variables**
   - Copy `.env.example` to `.env`
   - Update the API endpoints and Firebase configuration

4. **Run the App**
   ```bash
   flutter run
   ```

## Project Structure

The Flutter app has been implemented with the following structure:

### Core Features Implemented ✅

1. **Project Setup & Infrastructure**
   - Flutter project with proper folder structure
   - Material 3 theming with custom color scheme
   - Dependency injection with Provider
   - Dio HTTP client with interceptors
   - Secure storage for tokens
   - SQLite database with migrations

2. **Authentication System**
   - Firebase Authentication integration
   - JWT token management
   - Biometric authentication support
   - Auto-login functionality
   - Session management

3. **Data Models & Storage**
   - User, Device, Sensor Reading, Alert, Notification models
   - SQLite local database with proper schema
   - Remote and local data sources
   - Repository pattern implementation

4. **State Management**
   - AuthProvider for authentication state
   - SensorProvider for sensor data
   - DeviceProvider for device management
   - NotificationProvider for notifications
   - ThemeProvider for theme management

5. **UI Screens**
   - Splash screen with animations
   - Login/Register screens with validation
   - Home screen with navigation
   - Dashboard, Devices, Notifications, Profile screens
   - Custom widgets and components

6. **Network Layer**
   - Dio HTTP client with authentication
   - WebSocket client for real-time data
   - Error handling and retry logic
   - Connectivity monitoring

7. **Services**
   - Notification service with Firebase Cloud Messaging
   - Background message handling
   - Local notification support

### Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.2
  
  # Authentication
  firebase_auth: ^5.3.1
  firebase_core: ^3.6.0
  flutter_secure_storage: ^9.2.2
  local_auth: ^2.3.0
  
  # Networking
  dio: ^5.7.0
  web_socket_channel: ^3.0.1
  connectivity_plus: ^6.0.5
  
  # Firebase
  firebase_messaging: ^15.1.3
  firebase_database: ^11.1.4
  
  # Local Storage
  sqflite: ^2.4.0
  path_provider: ^2.1.4
  shared_preferences: ^2.3.2
  
  # UI & Charts
  fl_chart: ^0.69.0
  shimmer: ^3.0.0
  cached_network_image: ^3.4.1
  flutter_svg: ^2.0.10+1
  
  # Utilities
  intl: ^0.19.0
  uuid: ^4.5.1
  logger: ^2.4.0
  equatable: ^2.0.7
```

### Database Schema

The app uses SQLite with the following tables:

- `users` - User information and authentication
- `devices` - IoT device data and status
- `sensor_readings` - Sensor data with sync status
- `alerts` - Alert notifications and status
- `notifications` - General notifications
- `sync_queue` - Pending sync operations

### API Integration

The app integrates with the M.A.S.H. backend API:

- **Base URL**: `https://mash-backend.onrender.com/api/v1`
- **WebSocket**: `wss://mash-backend.onrender.com/ws`
- **Authentication**: JWT tokens with Firebase Auth
- **Real-time**: WebSocket for live sensor data

### Next Steps

1. **Run `flutter pub get`** to install dependencies
2. **Configure Firebase** with your project credentials
3. **Update API endpoints** in the configuration files
4. **Test the app** on a device or emulator
5. **Customize the UI** according to your needs

### Features Ready for Development

- ✅ Project structure and dependencies
- ✅ Authentication system
- ✅ Database schema and models
- ✅ State management with Provider
- ✅ Network layer with Dio and WebSocket
- ✅ UI screens and navigation
- ✅ Offline-first architecture foundation
- ✅ Firebase integration setup

### Remaining Tasks

- [ ] Implement real-time sensor data visualization
- [ ] Add chart components for historical data
- [ ] Implement device control functionality
- [ ] Add push notification handling
- [ ] Implement offline sync service
- [ ] Add comprehensive testing
- [ ] Optimize performance
- [ ] Prepare for app store deployment

The foundation is complete and ready for further development! 🚀
