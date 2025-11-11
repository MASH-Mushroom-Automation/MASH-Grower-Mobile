# MASH Grower Mobile - AI Coding Guidelines

## Project Overview
Flutter mobile app for mushroom growers with **offline-first architecture**, real-time IoT monitoring, and **dual backend integration** (Railway REST API + Firebase). Clean Architecture with Provider state management.

**Backend:** Railway production API at `https://mash-backend-api-production.up.railway.app/api/v1`  
**Branch:** `Build-apk` (feature/api-backend-connections merged)

## Architecture Patterns

### State Management
- **Provider Pattern**: Use `ChangeNotifier` classes in `presentation/providers/`
- **MultiProvider Setup**: Register providers in `main.dart` MaterialApp wrapper
- **Consumer Widgets**: Use `Consumer<ProviderType>` for reactive UI updates
- **Provider Access**: `Provider.of<ProviderType>(context, listen: false)` for non-reactive access

**Critical Pattern - Always wrap async operations:**
```dart
Future<void> fetchData() async {
  _isLoading = true;
  notifyListeners();
  try {
    final data = await _dataSource.getData();
    _items = data;
    _error = null;
  } catch (e) {
    _error = e.toString().replaceAll('Exception: ', '');
    Logger.error('Failed to fetch data', e);
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

### Data Layer Architecture
- **Models**: Extend `Equatable` in `data/models/`, implement `fromJson()` and `toJson()`
- **Remote DataSources**: Railway backend via `BackendAuthRemoteDataSource` in `data/datasources/remote/`
- **Local DataSources**: SQLite-based classes in `data/datasources/local/`
- **API Response Wrapper**: All backend responses use `ApiResponse<T>` with success, statusCode, data, timestamp

**Example Model:**
```dart
class BackendUserModel extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool emailVerified;

  factory BackendUserModel.fromJson(Map<String, dynamic> json) => BackendUserModel(
    id: json['id'] as String,
    email: json['email'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    emailVerified: json['emailVerified'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [id, email, firstName, lastName, emailVerified];
}
```

### Backend Integration (Railway REST API)
- **Base URL**: `ApiEndpoints.prodBaseUrl` = Railway production (via `core/constants/api_endpoints.dart`)
- **Authentication Flow**: 6-digit email verification codes (10-min expiry) → JWT tokens (1-hour access, 7-day refresh)
- **Data Source Pattern**: `BackendAuthRemoteDataSource` handles all auth API calls (register, verify, login, forgot password)
- **Token Storage**: `FlutterSecureStorage` for encrypted JWT storage (`access_token`, `refresh_token` keys)
- **Auto-Refresh**: `DioClient` interceptor catches 401 errors → calls `/auth/refresh` → retries original request

**Critical: Backend API Response Structure**
```dart
// All backend responses follow this pattern:
{
  "success": true,
  "statusCode": 200,
  "data": { /* actual data */ },
  "timestamp": "2025-11-12T10:30:00.000Z",
  "path": "/api/v1/auth/login",
  "correlationId": "uuid-here"
}
```

### Authentication Flows (IMPORTANT)

**Registration Flow (7-page wizard):**
```
1. Email page → collect email only
2. Password page → collect password
3. Profile page → firstName, lastName, username
4. Account page → optional address info
5. Review page → submitRegistration() → POST /auth/register → 6-digit code sent
6. OTP page → verifyEmailWithCode() → POST /auth/verify-email-code → JWT tokens → auto-login
7. Success page
```

**Login Flow:**
```
signInWithEmail() → loginWithBackendDirect() → POST /auth/login → JWT tokens stored
```

**Forgot Password Flow:**
```
sendOtp() → POST /auth/forgot-password → 6-digit code sent
resetPassword() → POST /auth/reset-password → password updated
```

### Networking Patterns
- **Dio Client**: Singleton in `core/network/dio_client.dart` with interceptors
- **API Endpoints**: Centralized in `core/constants/api_endpoints.dart`
- **Error Handling**: Try/catch with custom exceptions, Logger.error() calls
- **Authentication**: JWT tokens in secure storage, auto-refresh interceptors

**Example API Call:**
```dart
final response = await _dioClient.dio.post(
  ApiEndpoints.authLogin,
  data: {'email': email, 'password': password},
);

final apiResponse = ApiResponse.fromJson(response.data, (data) => data);
if (apiResponse.success) {
  return apiResponse.data as Map<String, dynamic>;
}
throw Exception(apiResponse.message ?? 'Request failed');
```

**Error Handling Pattern:**
```dart
on DioException catch (e) {
  if (e.response?.statusCode == 400) {
    throw Exception(e.response?.data['message'] ?? 'Bad request');
  } else if (e.response?.statusCode == 429) {
    throw Exception('Too many attempts. Please try again later.');
  }
  throw Exception('Network error. Please check your connection.');
}
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
- **Secure Storage**: `FlutterSecureStorage` for tokens (JWT access/refresh)
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