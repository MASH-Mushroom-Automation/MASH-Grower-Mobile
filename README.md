# M.A.S.H. Grower Mobile App

A Flutter mobile application for the M.A.S.H. (Mushroom Automation with Smart Hydro-environment) system that enables mushroom growers to monitor environmental conditions in real-time, control IoT devices remotely, receive critical alerts, and manage cultivation cycles—all with full offline capability.

## Features

### 🔐 Authentication
- Email/password login with Firebase Authentication
- Biometric authentication support
- Auto-login with saved credentials
- Session management and token refresh

### 📊 Real-time Dashboard
- Live temperature, humidity, and CO₂ readings
- Visual indicators with color-coded status
- Historical data charts
- Device online/offline status
- Pull-to-refresh functionality

### 🔔 Push Notifications & Alerts
- Firebase Cloud Messaging integration
- Critical alert notifications
- Environmental threshold warnings
- Device offline notifications
- In-app notification center

### 📱 Offline-First Architecture
- SQLite local database for caching
- Background sync when connectivity restored
- Queue system for pending actions
- Offline indicator in UI
- Conflict resolution strategy

## Technology Stack

- **Framework**: Flutter 3.24+ with Dart 3.5+
- **State Management**: Provider pattern
- **Authentication**: Firebase Auth + JWT fallback
- **Real-time Data**: WebSocket + Firebase Realtime Database
- **Local Database**: SQLite with sqflite
- **HTTP Client**: Dio with interceptors
- **UI Design**: Material 3 design system

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   ├── constants/
│   ├── network/
│   └── utils/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── repositories/
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── widgets/
└── services/
```

## Getting Started

### Prerequisites

- Flutter SDK 3.24 or higher
- Dart SDK 3.5 or higher
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/PP-Namias/MASH-Grower-Mobile.git
   cd MASH-Grower-Mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project
   - Add Android/iOS apps to the project
   - Download configuration files:
     - `android/app/google-services.json` (Android)
     - `ios/Runner/GoogleService-Info.plist` (iOS)

4. **Configure environment variables**
   - Copy `.env.example` to `.env`
   - Update API endpoints and Firebase configuration

5. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS IPA:**
```bash
flutter build ios --release
```

## API Integration

The app integrates with the M.A.S.H. backend API:

- **Base URL**: `https://mash-backend.onrender.com/api/v1`
- **WebSocket**: `wss://mash-backend.onrender.com/ws`
- **Authentication**: JWT tokens with Firebase Auth
- **Real-time**: WebSocket for live sensor data

### Key Endpoints

- `POST /auth/exchange` - Exchange Firebase token for JWT
- `GET /devices` - Get user's devices
- `GET /sensors/data/:deviceId/latest` - Latest sensor readings
- `GET /alerts` - Get user alerts
- `GET /notifications` - Get notifications

## Database Schema

The app uses SQLite for offline storage with the following tables:

- `users` - User information
- `devices` - IoT device data
- `sensor_readings` - Sensor data with sync status
- `alerts` - Alert notifications
- `notifications` - General notifications
- `sync_queue` - Pending sync operations

## State Management

The app uses Provider for state management with the following providers:

- `AuthProvider` - Authentication state
- `SensorProvider` - Sensor data management
- `DeviceProvider` - Device management
- `NotificationProvider` - Notification handling
- `ThemeProvider` - Theme management

## Offline Functionality

The app is designed to work offline with the following features:

1. **Data Caching**: All data is cached in SQLite
2. **Background Sync**: Automatic sync when online
3. **Queue System**: Pending operations are queued
4. **Conflict Resolution**: Smart conflict resolution for data sync
5. **Offline Indicators**: Clear UI indicators for offline state

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

## Deployment

### Android Play Store

1. Build release APK/AAB
2. Upload to Google Play Console
3. Configure app signing
4. Submit for review

### iOS App Store

1. Build release IPA
2. Upload to App Store Connect
3. Configure app metadata
4. Submit for review

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:

- Create an issue on GitHub
- Contact the development team
- Check the documentation

## Roadmap

- [ ] Advanced analytics dashboard
- [ ] Machine learning predictions
- [ ] Multi-language support
- [ ] Dark mode improvements
- [ ] Performance optimizations
- [ ] Additional sensor types
- [ ] Export functionality
- [ ] Backup and restore

---

**M.A.S.H. Grower Mobile App** - Smart mushroom growing made simple! 🍄