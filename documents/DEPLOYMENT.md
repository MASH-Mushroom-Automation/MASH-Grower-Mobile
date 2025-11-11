# MASH Grow Mobile - Deployment Guide

## Overview

This guide covers the complete deployment process for the MASH Grow Mobile Flutter application, including build configuration, app store submission, and production deployment.

## Prerequisites

### Development Environment
- Flutter SDK 3.24+ with Dart 3.5+
- Android Studio / Xcode
- Firebase project configured
- Backend API endpoints configured
- Code signing certificates (for production)

### Required Accounts
- Google Play Console (Android)
- Apple Developer Program (iOS)
- Firebase Console
- Backend hosting service

## Build Configuration

### Environment Setup

1. **Development Environment**
   ```bash
   # Set development environment
   flutter run --dart-define=ENVIRONMENT=development
   ```

2. **Production Environment**
   ```bash
   # Set production environment
   flutter run --dart-define=ENVIRONMENT=production
   ```

### Firebase Configuration

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create new project: "MASH-Grower-Mobile"
   - Enable Authentication, Realtime Database, Cloud Messaging

2. **Configure Firebase for Flutter**
   ```bash
   # Install FlutterFire CLI
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

3. **Update Firebase Options**
   - Replace placeholder values in `lib/firebase_options.dart`
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

### Backend Integration

1. **API Configuration**
   ```dart
   // Update lib/core/config/environment.dart
   static String get baseUrl {
     switch (_currentEnvironment) {
       case Environment.development:
         return 'http://your-dev-backend.com/api/v1';
       case Environment.production:
         return 'https://your-prod-backend.com/api/v1';
     }
   }
   ```

2. **WebSocket Configuration**
   ```dart
   static String get websocketUrl {
     switch (_currentEnvironment) {
       case Environment.development:
         return 'ws://your-dev-backend.com/ws';
       case Environment.production:
         return 'wss://your-prod-backend.com/ws';
     }
   }
   ```

## Android Deployment

### 1. Build Configuration

**Debug Build**
```bash
# Build debug APK
flutter build apk --debug

# Install on device
flutter install
```

**Release Build**
```bash
# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### 2. Code Signing

1. **Generate Keystore**
   ```bash
   keytool -genkey -v -keystore ~/mash-grower-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mash-grower
   ```

2. **Configure Signing**
   ```gradle
   // android/key.properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=mash-grower
   storeFile=../mash-grower-key.jks
   ```

3. **Update build.gradle**
   ```gradle
   android {
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile']
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

### 3. Google Play Store Submission

1. **Prepare Store Listing**
   - App title: "MASH Grow Mobile"
   - Short description: "Smart mushroom growing assistant"
   - Full description: Use content from `assets/metadata/app_store_description.md`
   - Screenshots: 5-8 screenshots showing key features
   - App icon: 512x512 PNG

2. **Upload AAB**
   ```bash
   # Build and upload App Bundle
   flutter build appbundle --release
   # Upload build/app/outputs/bundle/release/app-release.aab to Play Console
   ```

3. **Release Management**
   - Internal testing → Closed testing → Open testing → Production
   - Gradual rollout (5% → 20% → 50% → 100%)
   - Monitor crash reports and user feedback

## iOS Deployment

### 1. Build Configuration

**Debug Build**
```bash
# Build for simulator
flutter build ios --simulator

# Build for device
flutter build ios --debug
```

**Release Build**
```bash
# Build for App Store
flutter build ios --release

# Build IPA
flutter build ipa --release
```

### 2. Code Signing

1. **Apple Developer Account**
   - Enroll in Apple Developer Program ($99/year)
   - Create App ID: `com.mash.grower.mobile`
   - Create Provisioning Profiles

2. **Xcode Configuration**
   - Open `ios/Runner.xcworkspace`
   - Set Team and Bundle Identifier
   - Configure Signing & Capabilities
   - Enable Push Notifications, Background Modes

### 3. App Store Submission

1. **Prepare Store Listing**
   - App name: "MASH Grow Mobile"
   - Subtitle: "Smart Mushroom Growing Assistant"
   - Description: Use content from `assets/metadata/app_store_description.md`
   - Keywords: "mushroom, farming, IoT, sensors"
   - Screenshots: 6.7" iPhone, 6.5" iPhone, 12.9" iPad

2. **Upload to App Store Connect**
   ```bash
   # Build and upload IPA
   flutter build ipa --release
   # Upload build/ios/ipa/Runner.ipa via Xcode or Transporter
   ```

3. **App Review Process**
   - Submit for review
   - Address any rejection feedback
   - Monitor TestFlight feedback
   - Release to App Store

## Production Deployment Checklist

### Pre-Deployment
- [ ] All tests passing
- [ ] Code analysis clean
- [ ] Performance optimized
- [ ] Security audit completed
- [ ] Backend APIs tested
- [ ] Firebase configuration verified
- [ ] App signing configured
- [ ] Store listings prepared

### Deployment
- [ ] Build release artifacts
- [ ] Upload to app stores
- [ ] Submit for review
- [ ] Monitor deployment status
- [ ] Test on production devices

### Post-Deployment
- [ ] Monitor crash reports
- [ ] Track user analytics
- [ ] Collect user feedback
- [ ] Plan next release
- [ ] Update documentation

## Monitoring and Analytics

### Firebase Analytics
```dart
// Track key events
FirebaseAnalytics.instance.logEvent(
  name: 'sensor_data_received',
  parameters: {
    'device_id': deviceId,
    'sensor_type': sensorType,
    'value': value,
  },
);
```

### Crash Reporting
```dart
// Automatic crash reporting via Firebase Crashlytics
// Configure in firebase_options.dart
```

### Performance Monitoring
```dart
// Track app performance
PerformanceMonitor.startTiming('dashboard_load');
// ... dashboard loading code ...
PerformanceMonitor.endTiming('dashboard_load');
```

## Security Considerations

### Data Protection
- All API calls use HTTPS
- Sensitive data encrypted in local storage
- Biometric authentication for app access
- Token-based authentication with refresh

### Privacy Compliance
- GDPR compliance for EU users
- CCPA compliance for California users
- Clear privacy policy
- User consent for data collection

## Troubleshooting

### Common Issues

1. **Build Failures**
   ```bash
   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

2. **Signing Issues**
   - Verify keystore file exists
   - Check key.properties configuration
   - Ensure certificates are valid

3. **Firebase Issues**
   - Verify google-services.json is updated
   - Check Firebase project configuration
   - Ensure API keys are correct

### Support Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Store Connect Help](https://developer.apple.com/support/app-store-connect/)

## Maintenance

### Regular Updates
- Monthly security updates
- Quarterly feature releases
- Annual major version updates
- Continuous bug fixes

### Monitoring
- App performance metrics
- User engagement analytics
- Crash report analysis
- User feedback review

---

**Contact Information**
- Development Team: dev@mash-grower.com
- Support: support@mash-grower.com
- Website: https://mash-grower.com
