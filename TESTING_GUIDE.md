# Testing Guide: WiFi and Bluetooth Connections

This guide explains how to test WiFi and Bluetooth connections in the MASH Grower Mobile app.

## Table of Contents
1. [Unit Tests](#unit-tests)
2. [Widget Tests](#widget-tests)
3. [Integration Tests](#integration-tests)
4. [Manual Testing](#manual-testing)
5. [Mock Device Testing](#mock-device-testing)
6. [Troubleshooting](#troubleshooting)

---

## Unit Tests

Unit tests verify individual components in isolation.

### Running Unit Tests

```bash
# Run all unit tests
flutter test test/unit/

# Run specific test file
flutter test test/unit/bluetooth_device_service_test.dart
flutter test test/unit/device_connection_service_test.dart
```

### Test Files

- `test/unit/bluetooth_device_service_test.dart` - Bluetooth service logic
- `test/unit/device_connection_service_test.dart` - WiFi connection service
- `test/widget/hybrid_device_connection_screen_test.dart` - UI component tests

**Note:** Unit tests for Bluetooth/WiFi require mocking `FlutterBluePlus` and `Dio` for full coverage.

---

## Widget Tests

Widget tests verify UI components render correctly.

### Running Widget Tests

```bash
flutter test test/widget/
```

### What's Tested

- Tab navigation (Local Network, Bluetooth, Manual IP)
- Form validation (IP address format, port range)
- UI state changes (scanning, connecting, error states)

---

## Integration Tests

Integration tests verify the app works with real hardware.

### Prerequisites

1. **Physical Android device** (Bluetooth requires real hardware)
2. **Raspberry Pi 3** with MASH firmware running
3. **Same WiFi network** for WiFi tests
4. **Bluetooth enabled** on both devices

### Running Integration Tests

```bash
# Run on connected device
flutter test integration_test/wifi_bluetooth_connection_test.dart

# Or use integration_test driver
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/wifi_bluetooth_connection_test.dart
```

### Test Scenarios

1. **WiFi Discovery (mDNS)**
   - Device discovers Pi on local network
   - Shows device in list
   - Can connect via discovered IP

2. **WiFi Manual Connection**
   - Enter Pi's IP address manually
   - Connect successfully
   - Get device status

3. **Bluetooth Scanning**
   - Scan finds Pi
   - Shows signal strength (RSSI)
   - Can pair with device

4. **Bluetooth WiFi Provisioning**
   - Connect via BLE
   - Send WiFi credentials
   - Device switches to WiFi

---

## Manual Testing

Manual testing is the most reliable way to verify connections work end-to-end.

### WiFi Connection Testing

#### Step 1: Prepare Raspberry Pi
```bash
# On Raspberry Pi, ensure:
# 1. mDNS service is running (_mash-iot._tcp)
# 2. HTTP API server is running on port 5000
# 3. Device is on same WiFi network as phone
```

#### Step 2: Test mDNS Discovery
1. Open app on phone
2. Navigate to "Connect to Chamber"
3. Go to "Local Network" tab
4. Tap "Scan" (auto-scans on load)
5. **Expected:** Pi appears in device list with IP address

#### Step 3: Test Connection
1. Tap on discovered device
2. **Expected:** 
   - Shows "Connecting..." indicator
   - Success message: "Connected via local network!"
   - Returns to previous screen
   - Device shows as connected

#### Step 4: Test Manual IP
1. Go to "Manual IP" tab
2. Enter Pi's IP (e.g., `192.168.1.100`)
3. Enter port (default: `5000`)
4. Tap "Connect"
5. **Expected:** Same as Step 3

#### Step 5: Verify Connection
1. Check device status
2. View sensor data
3. Control actuators
4. **Expected:** All operations work via WiFi

### Bluetooth Connection Testing

#### Step 1: Prepare Raspberry Pi
```bash
# On Raspberry Pi, ensure:
# 1. Bluetooth is enabled
# 2. Device is in discoverable mode
# 3. BLE GATT service is running for WiFi provisioning
```

#### Step 2: Grant Permissions
1. Open app on phone
2. Navigate to "Connect to Chamber"
3. Go to "Bluetooth" tab
4. **Expected:** App requests Bluetooth and Location permissions
5. Grant all permissions

#### Step 3: Test Scanning
1. Tap "Scan" button
2. Wait 15 seconds
3. **Expected:**
   - Shows "Scanning..." indicator
   - Pi appears in "Available Devices" section
   - Shows signal strength (RSSI)
   - Shows device name and address

#### Step 4: Test Pairing (if needed)
1. If device not paired, pair in phone's Bluetooth settings first
2. **Expected:** Paired devices appear in "Paired Devices" section

#### Step 5: Test WiFi Provisioning
1. Tap on discovered/paired device
2. **Expected:** Dialog asks "Configure WiFi?"
3. Tap "Configure WiFi"
4. **Expected:** Navigates to BLE WiFi Provisioning screen
5. Select WiFi network and enter password
6. **Expected:**
   - Credentials sent via BLE
   - Pi connects to WiFi
   - Success message shown
   - Device connected

#### Step 6: Verify Connection
1. After provisioning, device should be on WiFi
2. Check if device appears in "Local Network" tab
3. **Expected:** Device discoverable via mDNS

### Testing Error Scenarios

#### WiFi Errors
- **No devices found:** Check Pi is on same network, mDNS running
- **Connection failed:** Check Pi IP, port, firewall settings
- **Timeout:** Check network latency, Pi response time

#### Bluetooth Errors
- **Bluetooth not available:** Enable Bluetooth on phone
- **Permissions denied:** Grant in phone settings
- **Device not found:** Ensure Pi is discoverable, move closer
- **Connection failed:** Check Pi BLE service, try pairing first

---

## Mock Device Testing

Use `MockDeviceService` to test without hardware.

### Using Mock Service

```dart
import 'package:mash_grower_mobile/core/services/mock_device_service.dart';

final mockService = MockDeviceService();

// Connect to mock device
await mockService.connectToDevice(
  deviceId: 'test-device',
  deviceName: 'Test Chamber',
);

// Get mock sensor data
final data = await mockService.getSensorData();
```

### Benefits

- Test app logic without Pi
- Faster development cycle
- Test error scenarios easily
- CI/CD friendly

### Limitations

- Doesn't test actual WiFi/Bluetooth
- Doesn't test network protocols
- Doesn't test hardware compatibility

---

## Troubleshooting

### WiFi Issues

**Problem:** No devices found via mDNS
- **Solution:** 
  - Verify Pi and phone on same WiFi
  - Check mDNS service running: `systemctl status avahi-daemon`
  - Try manual IP connection instead

**Problem:** Connection timeout
- **Solution:**
  - Check Pi firewall: `sudo ufw status`
  - Verify port 5000 is open
  - Test with curl: `curl http://<pi-ip>:5000/api/status`

**Problem:** Invalid IP format error
- **Solution:**
  - Use format: `192.168.1.100` (not `192.168.1.100:5000`)
  - Port is separate field

### Bluetooth Issues

**Problem:** Bluetooth scan finds no devices
- **Solution:**
  - Enable Bluetooth on phone
  - Grant Location permission (required for BLE scan on Android)
  - Ensure Pi is in discoverable mode
  - Move devices closer (< 10 meters)

**Problem:** Permission denied
- **Solution:**
  - Go to phone Settings > Apps > MASH Grower > Permissions
  - Enable: Bluetooth, Location, Nearby Devices
  - Restart app

**Problem:** BLE connection fails
- **Solution:**
  - Check Pi BLE service is running
  - Try pairing device in phone settings first
  - Restart Bluetooth on both devices

### General Issues

**Problem:** Tests fail in CI/CD
- **Solution:**
  - Use mock services for unit tests
  - Integration tests require physical devices
  - Consider using Firebase Test Lab or similar

**Problem:** App crashes during scan
- **Solution:**
  - Check logs: `flutter logs`
  - Verify permissions granted
  - Check device compatibility

---

## Test Checklist

### WiFi Connection
- [ ] mDNS discovery finds Pi
- [ ] Manual IP connection works
- [ ] Device status retrieved
- [ ] Sensor data received
- [ ] Actuator control works
- [ ] Error handling works (wrong IP, timeout)

### Bluetooth Connection
- [ ] Permissions requested correctly
- [ ] Scan finds Pi
- [ ] Signal strength displayed
- [ ] Pairing works
- [ ] BLE connection established
- [ ] WiFi provisioning works
- [ ] Error handling works (no BT, no device)

### Integration
- [ ] Bluetooth → WiFi provisioning flow
- [ ] WiFi connection after provisioning
- [ ] Fallback between WiFi and Bluetooth
- [ ] Connection persistence
- [ ] Reconnection after disconnect

---

## Next Steps

1. **Add more unit tests** with mocked dependencies
2. **Expand integration tests** for edge cases
3. **Add performance tests** for connection speed
4. **Add security tests** for credential handling
5. **Document Pi setup** for test environment

---

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Integration Testing Guide](https://docs.flutter.dev/testing/integration-tests)
- [Flutter Blue Plus Documentation](https://pub.dev/packages/flutter_blue_plus)
- [mDNS Documentation](https://pub.dev/packages/multicast_dns)

