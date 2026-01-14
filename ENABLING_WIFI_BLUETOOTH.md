# Enabling WiFi and Bluetooth for Testing

## Quick Answer

**You need to manually enable WiFi and Bluetooth on your phone.** The app cannot turn them on automatically due to Android security restrictions.

---

## How to Enable

### Enable WiFi

1. **Pull down notification panel** (swipe down from top)
2. **Tap WiFi icon** to enable
   - Or go to **Settings** → **WiFi** → Toggle ON

### Enable Bluetooth

1. **Pull down notification panel** (swipe down from top)
2. **Tap Bluetooth icon** to enable
   - Or go to **Settings** → **Bluetooth** → Toggle ON

---

## What the App Does

### ✅ The App Can:
- **Detect** if WiFi/Bluetooth is enabled
- **Request permissions** (Location, Bluetooth Scan, etc.)
- **Scan** for networks/devices when enabled
- **Show helpful messages** when disabled

### ❌ The App Cannot:
- **Enable WiFi** automatically
- **Enable Bluetooth** automatically
- **Open Settings** directly (limited on Android)

---

## User Experience

### When WiFi is Disabled:

**In "Local Network" Tab:**
- Shows info banner: *"WiFi must be enabled on your phone to scan networks"*
- WiFi network scanning will fail
- You'll see an error message if you try to scan

**What to do:**
1. Enable WiFi in phone settings
2. Return to app
3. Tap refresh to scan again

---

### When Bluetooth is Disabled:

**In "Bluetooth" Tab:**
- Shows warning banner: *"Bluetooth is disabled"*
- Scan button will show error
- You'll see: *"Bluetooth is disabled. Please enable it in Settings."*

**What to do:**
1. Enable Bluetooth in phone settings
2. Return to app
3. Tap "Scan" button again

---

## Error Messages

### WiFi Scanning Errors:

| Error | Meaning | Solution |
|-------|---------|----------|
| "WiFi scanning not available" | WiFi is disabled or no permission | Enable WiFi + grant Location permission |
| "Location permission required" | Missing location permission | Grant in app settings |
| "No WiFi networks found" | WiFi enabled but no networks nearby | Normal - just no networks in range |

### Bluetooth Scanning Errors:

| Error | Meaning | Solution |
|-------|---------|----------|
| "Bluetooth not available" | Bluetooth is disabled | Enable Bluetooth in phone settings |
| "Bluetooth permissions not granted" | Missing permissions | Grant Bluetooth + Location permissions |
| "No Bluetooth devices found" | Bluetooth enabled but no devices nearby | Normal - just no devices in range |

---

## Step-by-Step: First Time Setup

### 1. Enable WiFi
```
Phone Settings → WiFi → Toggle ON
```

### 2. Enable Bluetooth
```
Phone Settings → Bluetooth → Toggle ON
```

### 3. Open App
- Navigate to "Connect to Chamber"

### 4. Grant Permissions
When prompted, grant:
- ✅ **Location** (required for WiFi & Bluetooth scanning)
- ✅ **Bluetooth Scan**
- ✅ **Bluetooth Connect**

### 5. Start Scanning
- **WiFi**: Automatically scans on "Local Network" tab
- **Bluetooth**: Tap "Scan" button on "Bluetooth" tab

---

## Why Manual Enable?

### Android Security Restrictions

Android prevents apps from enabling WiFi/Bluetooth automatically because:
- **Security**: Prevents malicious apps from enabling features
- **Privacy**: User must explicitly enable network features
- **Battery**: Prevents apps from draining battery by enabling radios

### What Apps Can Do

Apps can:
- ✅ Check if WiFi/Bluetooth is enabled
- ✅ Request permissions
- ✅ Use features when enabled
- ❌ Enable WiFi/Bluetooth programmatically (blocked)

---

## Tips

### Quick Access
- Use **notification panel** (swipe down) for fastest access
- Most phones have WiFi/Bluetooth toggles in quick settings

### Keep Enabled
- If testing frequently, keep WiFi/Bluetooth enabled
- Modern phones manage battery efficiently

### Permission Issues
- If scanning doesn't work, check:
  1. WiFi/Bluetooth enabled?
  2. Location permission granted?
  3. Bluetooth permissions granted?
  4. App has necessary permissions in Settings?

---

## Troubleshooting

### "WiFi scanning not available"
1. ✅ Check WiFi is ON
2. ✅ Check Location permission granted
3. ✅ Try refreshing scan
4. ✅ Restart app

### "Bluetooth not available"
1. ✅ Check Bluetooth is ON
2. ✅ Check Location permission granted
3. ✅ Check Bluetooth permissions granted
4. ✅ Try restarting Bluetooth
5. ✅ Restart app

### Still Not Working?
1. Go to **Settings** → **Apps** → **MASH Grower**
2. Check **Permissions** tab
3. Ensure all required permissions are granted
4. Restart app

---

## Summary

**You must manually enable WiFi and Bluetooth** - the app will detect when they're enabled and guide you if they're disabled.

The app provides:
- ✅ Clear error messages
- ✅ Helpful instructions
- ✅ Status indicators
- ✅ Automatic detection

Just enable WiFi/Bluetooth in your phone settings, and the app will work! 🚀


