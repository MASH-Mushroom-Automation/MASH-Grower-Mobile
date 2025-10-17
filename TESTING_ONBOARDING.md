# Testing Onboarding Screen

## How to See Onboarding Again

The onboarding screen only shows on the first app launch. Once completed, it sets a flag in SharedPreferences and won't show again.

### Method 1: Clear App Data (Recommended for Testing)

#### On Android:
1. Go to **Settings** → **Apps** → **M.A.S.H. Grower**
2. Tap **Storage**
3. Tap **Clear Data** or **Clear Storage**
4. Restart the app

#### On iOS:
1. Uninstall the app
2. Reinstall the app

#### On Web/Desktop:
1. Open browser DevTools (F12)
2. Go to **Application** tab → **Local Storage**
3. Find and delete the `onboarding_completed` key
4. Refresh the page

### Method 2: Add a Reset Button (For Development)

You can temporarily add a button to reset the onboarding flag:

```dart
// Add this to your settings or debug screen
ElevatedButton(
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_completed');
    // Restart app or navigate to splash
  },
  child: const Text('Reset Onboarding'),
)
```

### Method 3: Programmatic Reset

Add this code to `main.dart` temporarily for testing:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TEMPORARY: Reset onboarding for testing
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('onboarding_completed');
  
  // ... rest of your main() code
}
```

**Remember to remove this code before production!**

## Onboarding Flow

1. **App Start** → Checks `onboarding_completed` flag
2. **If false** → Shows Onboarding Screen (5 pages)
3. **User completes** → Sets flag to `true`
4. **Navigates to** → Registration Flow
5. **Next launch** → Skips onboarding, goes to Login

## Current Implementation

The onboarding check is in `lib/app.dart`:

```dart
void _checkOnboardingStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final completed = prefs.getBool('onboarding_completed') ?? false;
  setState(() {
    _onboardingCompleted = completed;
    _onboardingChecked = true;
  });
}
```

If `onboarding_completed` is `false` or doesn't exist, the onboarding screen will show.

## Testing Checklist

- [ ] Fresh install shows onboarding
- [ ] All 5 onboarding pages display correctly
- [ ] Skip button works (appears after page 1)
- [ ] Page indicators animate correctly
- [ ] "Get Started" button on last page works
- [ ] After completion, flag is set
- [ ] Next app launch skips onboarding
- [ ] Goes directly to login screen
