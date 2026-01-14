# Testing WiFi and Bluetooth Scanning Without Raspberry Pi

This guide explains how to test the WiFi and Bluetooth scanning features in the app **without needing a Raspberry Pi device**.

## ✅ What You Can Test

### 1. **WiFi Network Scanning** ✅
- Scan and view all available WiFi networks around you
- See signal strength, security type, and network names
- Works on any Android device with WiFi enabled

### 2. **Bluetooth Device Scanning** ✅
- Scan and view all nearby Bluetooth devices
- See device names, addresses, and signal strength (RSSI)
- Works on any Android device with Bluetooth enabled

### 3. **mDNS Device Discovery** ⚠️
- This will show "No devices found" without a Pi
- This is expected - mDNS only finds devices advertising `_mash-iot._tcp` service
- You can still test the scanning mechanism

---

## 🚀 Quick Start

### Step 1: Run the App
```bash
flutter run
```

### Step 2: Navigate to Connection Screen
1. Open the app
2. Navigate to "Connect to Chamber" or "Devices" screen
3. You'll see three tabs: **Local Network**, **Bluetooth**, **Manual IP**

---

## 📡 Testing WiFi Scanning

### In the "Local Network" Tab:

1. **Automatic Scan on Load**
   - The app automatically scans for:
     - MASH devices (via mDNS) - will show "No devices found" without Pi
     - WiFi networks (for testing) - **This will work!**

2. **View WiFi Networks**
   - Scroll down to see "Available WiFi Networks" section
   - You'll see all nearby WiFi networks with:
     - Network name (SSID)
     - Signal strength (dBm)
     - Security type (WPA, WEP, Open)
     - Lock icon for secured networks

3. **Refresh Networks**
   - Tap the refresh icon next to "Available WiFi Networks"
   - Wait 2-3 seconds for new scan results

### What You'll See:
```
Available WiFi Networks (15)
├─ MyHomeWiFi          -45 dBm  [WPA2]
├─ NeighborNetwork      -67 dBm  [WPA]
├─ PublicWiFi           -72 dBm  [Open]
└─ ...
```

### Permissions Required:
- **Location Permission** (required for WiFi scanning on Android)
  - The app will request this automatically
  - Grant it to enable WiFi scanning

---

## 📶 Testing Bluetooth Scanning

### In the "Bluetooth" Tab:

1. **Grant Permissions**
   - When you open the tab, the app will request:
     - Bluetooth Scan permission
     - Bluetooth Connect permission
     - Location permission (required for BLE scanning)
   - **Grant all permissions** to enable scanning

2. **View Paired Devices**
   - Already paired devices appear at the top
   - Shows devices you've paired in phone settings

3. **Scan for New Devices**
   - Tap the "Scan" button
   - Wait 15 seconds for scan to complete
   - **You'll see ALL nearby Bluetooth devices** (not just MASH devices)
   - Shows:
     - Device name
     - MAC address
     - Signal strength (RSSI)
     - Connection status

### What You'll See:
```
Paired Devices (2)
├─ My Headphones        -45 dBm  [Paired]
└─ Smart Watch          -52 dBm  [Paired]

Available Devices (8)
├─ Bluetooth Speaker    -65 dBm
├─ Car Audio            -72 dBm
├─ Unknown Device       -78 dBm
└─ ...
```

### Debug Mode:
The app is configured to show **ALL Bluetooth devices** (not just MASH devices) for testing:
- Set in `bluetooth_device_service.dart`: `_debugShowAllDevices = true`
- This allows you to see any Bluetooth device nearby

---

## 🧪 Testing Scenarios

### Scenario 1: WiFi Network Discovery
**Goal:** Verify WiFi scanning works

**Steps:**
1. Open "Local Network" tab
2. Wait for automatic scan (or tap refresh)
3. Verify WiFi networks appear in list
4. Check signal strength indicators (green/orange/red)
5. Verify network names and security types are shown

**Expected Result:**
- List of WiFi networks appears
- Networks sorted by signal strength (strongest first)
- Each network shows SSID, signal strength, and security

---

### Scenario 2: Bluetooth Device Discovery
**Goal:** Verify Bluetooth scanning works

**Steps:**
1. Open "Bluetooth" tab
2. Grant all permissions when prompted
3. Tap "Scan" button
4. Wait 15 seconds
5. Verify devices appear in list

**Expected Result:**
- Paired devices shown at top (if any)
- Scanned devices shown below
- Each device shows name, address, and RSSI
- Signal strength color-coded (green = strong, red = weak)

---

### Scenario 3: Permission Handling
**Goal:** Verify permission requests work correctly

**Steps:**
1. Deny permissions initially
2. Try to scan
3. Verify error message appears
4. Grant permissions in app settings
5. Try scanning again

**Expected Result:**
- Clear error messages when permissions denied
- Scanning works after permissions granted
- App handles permission states gracefully

---

### Scenario 4: No Devices Found
**Goal:** Verify empty states display correctly

**Steps:**
1. Turn off WiFi/Bluetooth
2. Try scanning
3. Verify helpful messages appear

**Expected Result:**
- Clear "No devices found" messages
- Helpful troubleshooting tips
- Refresh buttons available

---

## 🔧 Troubleshooting

### WiFi Scanning Not Working

**Problem:** No WiFi networks appear
- **Solution:**
  - Check Location permission is granted
  - Ensure WiFi is enabled on phone
  - Try refreshing the scan
  - Check phone settings > Apps > MASH Grower > Permissions

**Problem:** "WiFi scanning not available"
- **Solution:**
  - Some Android versions limit WiFi scanning
  - Try on a different device
  - Check if phone supports WiFi scanning API

---

### Bluetooth Scanning Not Working

**Problem:** No Bluetooth devices found
- **Solution:**
  - Enable Bluetooth on phone
  - Grant Location permission (required for BLE)
  - Move closer to Bluetooth devices
  - Ensure devices are in discoverable mode
  - Try pairing device in phone settings first

**Problem:** "Bluetooth not available"
- **Solution:**
  - Enable Bluetooth in phone settings
  - Restart Bluetooth adapter
  - Check if device supports Bluetooth

**Problem:** Permissions denied
- **Solution:**
  - Go to Settings > Apps > MASH Grower > Permissions
  - Enable: Bluetooth, Location, Nearby Devices
  - Restart app

---

## 📱 What You Can't Test Without Pi

These features require a Raspberry Pi:

1. **mDNS Device Discovery**
   - Won't find devices (no Pi advertising `_mash-iot._tcp`)
   - This is expected and normal

2. **Device Connection**
   - Can't connect to actual MASH device
   - Can't test sensor data retrieval
   - Can't test actuator control

3. **WiFi Provisioning via Bluetooth**
   - Requires Pi with BLE GATT service
   - Can't test credential sending

---

## 💡 Tips for Testing

1. **Use Multiple Devices**
   - Test on different Android versions
   - Test with different Bluetooth devices nearby
   - Test in different WiFi environments

2. **Test Edge Cases**
   - Turn WiFi/Bluetooth on/off during scan
   - Deny permissions and see error handling
   - Test with no networks/devices nearby

3. **Check Logs**
   - Use `flutter logs` to see detailed scan logs
   - Look for permission errors
   - Check scan result counts

4. **Test Performance**
   - Verify scans complete in reasonable time
   - Check UI doesn't freeze during scans
   - Test refresh functionality

---

## 🎯 Success Criteria

You've successfully tested if:

✅ WiFi networks appear in "Local Network" tab  
✅ Bluetooth devices appear in "Bluetooth" tab  
✅ Signal strengths are displayed correctly  
✅ Permissions are requested properly  
✅ Error messages are clear and helpful  
✅ UI updates smoothly during scans  
✅ Refresh buttons work correctly  

---

## 📝 Notes

- **Bluetooth scanning shows ALL devices** (debug mode enabled)
- **WiFi scanning shows networks around you** (not just connected network)
- **mDNS will show "No devices found"** without Pi (this is normal)
- **Manual IP tab** can be tested with any HTTP server on port 5000

---

## 🔗 Related Files

- `lib/presentation/screens/devices/hybrid_device_connection_screen.dart` - Main UI
- `lib/services/bluetooth_device_service.dart` - Bluetooth scanning logic
- `lib/core/services/device_connection_service.dart` - WiFi connection logic

---

## 🆘 Need Help?

If scanning doesn't work:
1. Check permissions in phone settings
2. Verify WiFi/Bluetooth are enabled
3. Check `flutter logs` for errors
4. Try on a different device
5. Review `TESTING_GUIDE.md` for more details


