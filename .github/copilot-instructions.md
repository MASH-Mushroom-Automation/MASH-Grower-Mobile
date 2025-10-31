# MASH Grower Mobile - AI Coding Guidelines

## Project Overview
Flutter mobile app for mushroom growers with offline-first architecture, real-time IoT monitoring, and Firebase integration. Clean Architecture with Provider state management.

## Architecture Patterns

### State Management
- **Provider Pattern**: Use `ChangeNotifier` classes in `presentation/providers/`
- **MultiProvider Setup**: Register providers in `main.dart` MaterialApp wrapper
- **Consumer Widgets**: Use `Consumer<ProviderType>` for reactive UI updates
- **Provider Access**: `Provider.of<ProviderType>(context, listen: false)` for non-reactive access

**Example Provider Structure:**
```dart
class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // auth logic
      _user = userModel;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Data Layer Architecture
- **Models**: Extend `Equatable` in `data/models/`, implement `fromJson()` and `toJson()`
- **Remote DataSources**: Dio-based classes in `data/datasources/remote/`
- **Local DataSources**: SQLite-based classes in `data/datasources/local/`
- **Repository Pattern**: Combine remote/local sources (not fully implemented yet)

**Example Model:**
```dart
class UserModel extends Equatable {
  const UserModel({required this.id, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'email': email};

  @override
  List<Object?> get props => [id, email];
}
```

### Networking Patterns
- **Dio Client**: Singleton in `core/network/dio_client.dart` with interceptors
- **API Endpoints**: Centralized in `core/constants/api_endpoints.dart`
- **Error Handling**: Try/catch with custom exceptions, Logger.error() calls
- **Authentication**: JWT tokens in secure storage, auto-refresh interceptors

**Example API Call:**
```dart
final response = await _dio.post(
  ApiEndpoints.authExchange,
  data: {'firebase_token': token},
);
return response.data['data'];
```

## Configuration & Environment

### Environment Setup
- **Environment Enum**: `Environment.development` / `Environment.production`
- **Dynamic Config**: `EnvironmentConfig.apiBaseUrl` switches URLs
- **Firebase Projects**: Different projects for dev/prod environments

**Environment Switching:**
```dart
// In main.dart
EnvironmentConfig.setEnvironment(Environment.development);
```

### App Configuration
- **Constants**: `core/constants/` for API endpoints, storage keys
- **Theme**: `core/config/theme_config.dart` with Material 3
- **Sensor Thresholds**: `AppConfig.sensorThresholds` for environmental limits

## Key Dependencies & Usage

### Firebase Integration
- **Auth**: `FirebaseAuth.instance` with biometric fallback
- **Messaging**: Background message handler in `main.dart`
- **Database**: Real-time sensor data synchronization

### Local Storage
- **Secure Storage**: `FlutterSecureStorage` for tokens
- **SQLite**: `sqflite` for offline data (database helper pattern)
- **Shared Preferences**: Simple key-value storage

### Offline-First Features
- **Connectivity Monitoring**: `Connectivity` package with listeners
- **Sync Queue**: Pending operations queue for when online
- **Conflict Resolution**: Smart merging of local/remote data

## Development Workflow

### Build Commands
```bash
# Development
flutter run

# Production builds
flutter build apk --release
flutter build ios --release

# Testing
flutter test                    # Unit tests
flutter test integration_test/  # Integration tests
```

### Firebase Setup Required
1. Create Firebase project
2. Add Android/iOS apps
3. Download config files to `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`
4. Enable Authentication, Realtime Database, Cloud Messaging

### Environment Variables
- Copy `.env.example` to `.env`
- Configure API endpoints and Firebase project IDs

## Code Style & Patterns

### Logging
- **Custom Logger**: `Logger.info()`, `Logger.error()`, `Logger.networkRequest()`
- **Categories**: Network, database, auth logging methods
- **Debug Mode**: `EnvironmentConfig.isDebugMode` controls verbose logging

### Error Handling
- **Network Errors**: Dio interceptors catch and retry
- **Auth Errors**: Token refresh on 401 responses
- **UI Errors**: Provider error states with user-friendly messages

### Navigation
- **Bottom Navigation**: Custom `BottomNavBar` widget
- **Screen Structure**: Feature-based folders in `presentation/screens/`
- **Route Management**: Direct widget instantiation (no named routes yet)

## File Organization

```
lib/
├── main.dart              # App initialization, Firebase setup
├── app.dart               # Root widget, connectivity monitoring
├── core/                  # Shared utilities and config
│   ├── config/           # Environment, theme, app config
│   ├── constants/        # API endpoints, storage keys
│   ├── network/          # Dio client, WebSocket client
│   ├── services/         # Session service, background tasks
│   └── utils/            # Logger, validators, helpers
├── data/                 # Data layer
│   ├── datasources/      # Remote/local data access
│   ├── models/          # Data models with JSON serialization
│   └── repositories/    # Business logic (planned)
├── presentation/         # UI layer
│   ├── providers/       # State management
│   ├── screens/         # Page widgets
│   └── widgets/         # Reusable components
└── services/            # External integrations
    ├── device_provisioning_service.dart
    ├── local_device_client.dart
    ├── mdns_discovery_service.dart
    ├── notification_service.dart
```

## Common Patterns

### Provider Usage in Widgets
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return CircularProgressIndicator();
        }
        return Text('User: ${authProvider.user?.email}');
      },
    );
  }
}
```

### Async Operations in Providers
```dart
Future<void> fetchData() async {
  _isLoading = true;
  notifyListeners();
  try {
    final data = await _remoteDataSource.getData();
    _items = data;
  } catch (e) {
    _error = e.toString();
    Logger.error('Failed to fetch data', e);
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

### Model Serialization
```dart
// From API response
final user = UserModel.fromJson(response.data['user']);

// To send to API
final jsonData = user.toJson();
```

## Testing Approach
- **Unit Tests**: Provider methods, utility functions
- **Widget Tests**: UI component behavior
- **Integration Tests**: Full app flows, API integration

## Deployment Checklist
- [ ] Environment set to production
- [ ] Firebase config files updated
- [ ] API endpoints configured
- [ ] Build tested on device
- [ ] Release keystore configured (Android)
- [ ] App store metadata ready</content>
<parameter name="filePath">.github/copilot-instructions.md