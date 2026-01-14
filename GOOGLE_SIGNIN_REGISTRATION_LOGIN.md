# Google Sign-In for Registration and Login

## Overview

Google Sign-In has been implemented to work seamlessly for both **registration** (new users) and **login** (existing users). The same OAuth flow handles both scenarios automatically.

## How It Works

### Unified OAuth Flow

When a user clicks "Sign in with Google" or "Sign up with Google":

1. **User authenticates with Google** - Opens Google sign-in dialog
2. **App receives Google ID token** - Google provides authentication token
3. **Backend processes the token** - Your backend API (`/auth/oauth/google`) determines:
   - **New User**: Automatically creates account with Google profile data
   - **Existing User**: Logs them in with existing account
4. **Backend returns JWT tokens** - Standard access/refresh tokens for your app
5. **User is authenticated** - Can access the app immediately

### Key Points

- ✅ **Same method for both**: `AuthProvider.signInWithGoogle()` works for registration and login
- ✅ **Automatic account creation**: Backend creates account if user doesn't exist
- ✅ **No email verification needed**: Google already verified the email
- ✅ **No password required**: OAuth handles authentication
- ✅ **Instant access**: User is logged in immediately after Google authentication

## Implementation Details

### Login Screen (`login_screen.dart`)

```dart
Future<void> _handleGoogleLogin() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final success = await authProvider.signInWithGoogle();
  
  if (success && mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}
```

**Button**: "Login with Google"

### Registration Screen (`email_page.dart`)

```dart
Future<void> _handleGoogleSignUp() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final success = await authProvider.signInWithGoogle();
  
  if (success && mounted) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }
}
```

**Button**: "Sign up with Google"

### Backend Response

The backend returns an `isNewUser` flag in the OAuth response:

```json
{
  "success": true,
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token",
  "user": { ... },
  "isNewUser": true  // true = registration, false = login
}
```

## User Experience

### Scenario 1: New User (Registration)
1. User clicks "Sign up with Google" on registration screen
2. Selects Google account
3. Backend creates new account automatically
4. User is immediately logged in and sees home screen
5. **No need to fill registration form!**

### Scenario 2: Existing User (Login)
1. User clicks "Login with Google" on login screen
2. Selects Google account (same one used before)
3. Backend recognizes existing account
4. User is logged in and sees home screen

### Scenario 3: Existing User on Registration Screen
1. User clicks "Sign up with Google" on registration screen
2. Selects Google account that already exists
3. Backend recognizes existing account
4. User is logged in (not registered again)
5. **Prevents duplicate accounts!**

## Backend Requirements

Your backend API endpoint `/auth/oauth/google` should:

1. **Verify Google ID token** - Validate the token with Google
2. **Check if user exists** - Look up user by email
3. **Create or login**:
   - If user doesn't exist: Create new account with Google profile data
   - If user exists: Return existing user data
4. **Return JWT tokens** - Standard access/refresh tokens
5. **Set `isNewUser` flag** - Indicate if account was just created

### Example Backend Logic (Pseudocode)

```javascript
async function handleGoogleOAuth(idToken, accessToken, email, displayName, photoUrl) {
  // 1. Verify Google token
  const googleUser = await verifyGoogleToken(idToken);
  
  // 2. Check if user exists
  let user = await findUserByEmail(email);
  let isNewUser = false;
  
  if (!user) {
    // 3a. Create new account
    user = await createUser({
      email: email,
      firstName: extractFirstName(displayName),
      lastName: extractLastName(displayName),
      avatarUrl: photoUrl,
      isEmailVerified: true, // Google verified
      authProvider: 'google'
    });
    isNewUser = true;
  } else {
    // 3b. Update existing user (optional)
    user = await updateUser(user.id, {
      avatarUrl: photoUrl, // Update profile picture
      lastLoginAt: new Date()
    });
  }
  
  // 4. Generate JWT tokens
  const tokens = generateTokens(user);
  
  // 5. Return response
  return {
    success: true,
    accessToken: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    user: user,
    isNewUser: isNewUser
  };
}
```

## Benefits

### For Users
- ✅ **Faster registration** - No need to fill long forms
- ✅ **No password to remember** - Google handles authentication
- ✅ **One-click sign-in** - Quick access to the app
- ✅ **Secure** - Google's security infrastructure

### For Developers
- ✅ **Simplified flow** - One method handles both registration and login
- ✅ **Less code** - No separate registration logic needed
- ✅ **Better UX** - Users can start using app immediately
- ✅ **Reduced friction** - Fewer steps = more conversions

## Security Considerations

1. **Token Verification**: Backend must verify Google ID tokens server-side
2. **Email Verification**: Google-verified emails are automatically trusted
3. **Account Linking**: Consider allowing users to link Google account to existing email/password account
4. **Duplicate Prevention**: Backend should prevent duplicate accounts (same email)

## Testing

### Test Registration Flow
1. Use a Google account that's never been used with your app
2. Click "Sign up with Google" on registration screen
3. Verify account is created in backend
4. Verify user is logged in immediately
5. Check `isNewUser` flag is `true`

### Test Login Flow
1. Use a Google account that was previously registered
2. Click "Login with Google" on login screen
3. Verify user is logged in (not registered again)
4. Check `isNewUser` flag is `false`

### Test Edge Cases
1. **Existing user on registration screen**: Should login, not create duplicate
2. **Cancelled sign-in**: Should handle gracefully
3. **Network error**: Should show appropriate error message
4. **Invalid token**: Backend should reject and return error

## Troubleshooting

### Issue: "Sign in failed" or "DEVELOPER_ERROR"
- Verify SHA-1 fingerprint in Firebase Console
- Check OAuth client ID configuration
- Ensure `google-services.json` is up to date

### Issue: User not created in backend
- Check backend logs for OAuth endpoint
- Verify backend can verify Google ID tokens
- Ensure backend creates user when `isNewUser` should be true

### Issue: Duplicate accounts created
- Backend should check for existing email before creating
- Consider account linking/migration strategy

## Next Steps

1. ✅ Google Sign-In implemented for login
2. ✅ Google Sign-In implemented for registration
3. ⏳ Test with real Google accounts
4. ⏳ Configure production OAuth credentials
5. ⏳ Add account linking (link Google to existing email account)
6. ⏳ Add Facebook Sign-In (similar implementation)

