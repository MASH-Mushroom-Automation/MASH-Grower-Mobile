# M.A.S.H. Grower Mobile App - Environment Setup

## Overview

The Flutter mobile app uses a different environment configuration than the backend. You need to configure Firebase and API endpoints specifically for the mobile app.

## Required Setup Steps

### 1. Firebase Configuration

#### A. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project: `mash-grower-app`
3. Enable the following services:
   - **Authentication** (Email/Password, Google, GitHub, Facebook)
   - **Realtime Database**
   - **Cloud Messaging**

#### B. Add Mobile Apps to Firebase Project
1. **Android App:**
   - Add Android app to your Firebase project
   - Package name: `com.mash.grower`
   - Download `google-services.json`
   - Place in `android/app/google-services.json`

2. **iOS App:**
   - Add iOS app to your Firebase project
   - Bundle ID: `com.mash.grower`
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/GoogleService-Info.plist`

#### C. Update Firebase Configuration
Update `lib/firebase_options.dart` with your actual Firebase configuration:

```dart
// Replace these with your actual Firebase config values
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-actual-android-api-key',
  appId: 'your-actual-android-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'mash-grower-app',
  storageBucket: 'mash-grower-app.appspot.com',
);
```

### 2. Backend API Configuration

The mobile app connects to your existing backend API. Update the API endpoints in `lib/core/config/environment.dart`:

```dart
// Development (for testing)
static String get apiBaseUrl {
  return 'http://your-local-ip:3000/api/v1'; // Your local backend
}

// Production
static String get apiBaseUrl {
  return 'https://mash-backend.onrender.com/api/v1'; // Your deployed backend
}
```

### 3. Environment Variables

#### Development Environment
- **API Base URL**: `http://localhost:3000/api/v1` (or your local IP)
- **WebSocket URL**: `ws://localhost:3000/ws`
- **Firebase Project**: `mash-grower-dev`

#### Production Environment
- **API Base URL**: `https://mash-backend.onrender.com/api/v1`
- **WebSocket URL**: `wss://mash-backend.onrender.com/ws`
- **Firebase Project**: `mash-grower-prod`

### 4. Switching Environments

To switch between development and production:

```dart
// In lib/main.dart
void main() async {
  // For development
  EnvironmentConfig.setEnvironment(Environment.development);
  
  // For production
  // EnvironmentConfig.setEnvironment(Environment.production);
  
  // ... rest of initialization
}
```

### 5. Firebase Realtime Database Rules

Set up your Firebase Realtime Database with these rules:

```json
{
  "rules": {
    "live": {
      "sensors": {
        "$deviceId": {
          ".read": "auth != null",
          ".write": "auth != null"
        }
      }
    },
    "presence": {
      "$userId": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    },
    "controls": {
      "$deviceId": {
        "desired": {
          ".read": "auth != null",
          ".write": "auth != null"
        }
      }
    },
    "alerts": {
      "$growerId": {
        "$alertId": {
          ".read": "auth != null",
          ".write": "auth != null"
        }
      }
    }
  }
}
```

## What You DON'T Need from Backend

The following backend environment variables are **NOT needed** in the Flutter app:

- Database connection strings (PostgreSQL, Redis)
- JWT secrets
- Email service configurations
- Payment gateway keys
- Server-specific configurations

## What You DO Need

1. **Firebase Configuration Files** (google-services.json, GoogleService-Info.plist)
2. **Backend API Endpoints** (already configured)
3. **Firebase Project Setup** (Authentication, Realtime Database, Cloud Messaging)

## Testing the Setup

1. **Run the app**: `flutter run`
2. **Check Firebase connection**: Look for Firebase initialization logs
3. **Test authentication**: Try signing up/in
4. **Test API connection**: Check if the app can connect to your backend
5. **Test WebSocket**: Verify real-time data connection

## Troubleshooting

### Firebase Issues
- Ensure `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Check Firebase project settings match your configuration
- Verify Firebase services are enabled

### API Connection Issues
- Check if your backend is running and accessible
- Verify API endpoints in `environment.dart`
- Check network connectivity

### WebSocket Issues
- Ensure WebSocket server is running on your backend
- Check WebSocket URL configuration
- Verify CORS settings on backend

## Next Steps

1. Set up Firebase project and download configuration files
2. Update `firebase_options.dart` with your actual values
3. Test the app with your backend API
4. Configure push notifications
5. Deploy to app stores

The mobile app is now ready to connect to your existing backend! 🚀
