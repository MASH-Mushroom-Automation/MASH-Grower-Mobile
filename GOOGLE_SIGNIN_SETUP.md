# Google Sign-In and SSO Setup Guide

This guide will help you set up Google Sign-In and Single Sign-On (SSO) for your MASH Grower Mobile app.

## Overview

The implementation includes:
- ✅ Google Sign-In integration using `google_sign_in` package
- ✅ OAuth authentication flow with backend API
- ✅ Support for SSO (Single Sign-On) across devices
- ✅ Automatic token management and refresh

## Prerequisites

1. **Firebase Project** - Already configured in your project
2. **Google Cloud Console** - For OAuth credentials
3. **Backend API** - Must support OAuth endpoint `/auth/oauth/google`

## Setup Steps

### 1. Configure Google Sign-In in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `mashappbuild-a7068`
3. Navigate to **Authentication** > **Sign-in method**
4. Enable **Google** as a sign-in provider
5. Add your **OAuth client IDs** (see step 2)

### 2. Get OAuth Client IDs from Google Cloud Console

#### For Android:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project or create a new one
3. Navigate to **APIs & Services** > **Credentials**
4. Click **Create Credentials** > **OAuth client ID**
5. Select **Android** as application type
6. Enter your package name: `com.example.mash_grower_mobile`
7. Get your **SHA-1 fingerprint**:
   ```bash
   # For debug keystore (default)
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # For Windows
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
8. Copy the SHA-1 fingerprint and add it to the OAuth client configuration
9. Save the **Client ID** (you'll need this)

#### For Web (if supporting web platform):
1. Create another OAuth client ID
2. Select **Web application**
3. Add authorized JavaScript origins:
   - `http://localhost` (for development)
   - Your production domain (for production)
4. Add authorized redirect URIs:
   - `http://localhost/auth/callback` (for development)
   - Your production callback URL (for production)

#### For iOS (if supporting iOS):
1. Create another OAuth client ID
2. Select **iOS**
3. Enter your bundle ID: `com.example.mashGrowerMobile`
4. Save the **Client ID**

### 3. Configure Backend API

Your backend API should have an endpoint that accepts Google OAuth tokens:

**Endpoint:** `POST /api/v1/auth/oauth/google`

**Request Body:**
```json
{
  "idToken": "google_id_token_here",
  "accessToken": "google_access_token_here",
  "provider": "google",
  "email": "user@example.com",
  "displayName": "User Name",
  "photoUrl": "https://..."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Authentication successful",
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "firstName": "User",
    "lastName": "Name",
    "avatarUrl": "https://...",
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  },
  "isNewUser": false
}
```

### 4. Android Configuration

The Android configuration is already set up in your project:

- ✅ `google-services.json` is in place
- ✅ Google Services plugin is configured in `build.gradle`
- ✅ Firebase dependencies are added

**Additional Steps (if needed):**

1. Ensure your `google-services.json` includes the OAuth client ID
2. Verify the package name matches: `com.example.mash_grower_mobile`

### 5. Testing Google Sign-In

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Test the flow:**
   - Tap "Login with Google" button on the login screen
   - Select a Google account
   - Verify successful authentication
   - Check that user data is loaded correctly

3. **Check logs:**
   - Look for `🔐 Starting Google Sign-In...`
   - Look for `✅ Google authentication successful`
   - Look for `✅ User logged in: [name]`

### 6. Troubleshooting

#### Issue: "Sign in failed" or "DEVELOPER_ERROR"
**Solution:**
- Verify SHA-1 fingerprint is correctly added in Firebase Console
- Ensure OAuth client ID is configured for Android
- Check that `google-services.json` is up to date

#### Issue: "Network error"
**Solution:**
- Check backend API is running and accessible
- Verify OAuth endpoint `/auth/oauth/google` exists
- Check network connectivity

#### Issue: "Account error"
**Solution:**
- Verify backend API accepts the OAuth request format
- Check backend logs for authentication errors
- Ensure backend can verify Google ID tokens

#### Issue: Google Sign-In dialog doesn't appear
**Solution:**
- Check internet connection
- Verify Google Play Services is installed and updated
- Clear app cache and try again

### 7. Production Checklist

Before deploying to production:

- [ ] Configure production OAuth client IDs
- [ ] Update SHA-1 fingerprint for release keystore
- [ ] Test with production backend API
- [ ] Verify token refresh works correctly
- [ ] Test SSO across multiple devices
- [ ] Review security settings in Firebase Console
- [ ] Enable app verification in Google Cloud Console

### 8. Additional OAuth Providers

The implementation supports multiple OAuth providers. To add more:

1. **Facebook:**
   - Add `facebook_sign_in` package
   - Implement similar flow in `AuthProvider`
   - Add endpoint in `AuthRemoteDataSource`

2. **GitHub:**
   - Add `github_sign_in` package (if available)
   - Or use web-based OAuth flow
   - Add endpoint in `AuthRemoteDataSource`

### 9. SSO (Single Sign-On) Features

The current implementation provides:
- ✅ Automatic token refresh
- ✅ Persistent authentication across app restarts
- ✅ Secure token storage using `flutter_secure_storage`

**To enable true SSO across devices:**
- Backend should support device token management
- Consider implementing device registration
- Use Firebase Auth for cross-platform SSO (optional)

## Code Structure

```
lib/
├── data/
│   ├── models/auth/
│   │   ├── oauth_request_model.dart      # OAuth request model
│   │   └── oauth_response_model.dart    # OAuth response model
│   ├── datasources/remote/
│   │   └── auth_remote_datasource.dart  # OAuth API calls
│   └── repositories/
│       └── auth_repository.dart         # OAuth business logic
└── presentation/
    └── providers/
        └── auth_provider.dart            # Google Sign-In implementation
```

## API Endpoints Used

- `POST /api/v1/auth/oauth/google` - Google OAuth authentication
- `POST /api/v1/auth/oauth/facebook` - Facebook OAuth (if implemented)
- `POST /api/v1/auth/oauth/github` - GitHub OAuth (if implemented)

## Security Considerations

1. **Token Storage:**
   - Tokens are stored securely using `flutter_secure_storage`
   - Never log tokens in production

2. **Token Validation:**
   - Backend must verify Google ID tokens
   - Use Firebase Admin SDK or Google's token verification

3. **HTTPS:**
   - Always use HTTPS in production
   - Verify SSL certificates

4. **OAuth Scopes:**
   - Only request necessary scopes (`email`, `profile`)
   - Review permissions with users

## Support

For issues or questions:
1. Check Firebase Console for authentication errors
2. Review backend API logs
3. Check Flutter/Dart logs for detailed error messages
4. Verify OAuth client configuration

## Next Steps

1. Test Google Sign-In on a physical device
2. Configure production OAuth credentials
3. Test SSO across multiple devices
4. Consider adding more OAuth providers (Facebook, Apple, etc.)
5. Implement account linking (link Google account to existing email account)


