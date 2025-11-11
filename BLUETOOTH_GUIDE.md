# Bluetooth Connectivity Guide for MASH Grower Mobile

## Overview

The MASH Grower Mobile app now supports Bluetooth connectivity as a fallback when WiFi is unavailable. This enables:

- **Offline Mode**: Control devices without internet
- **Bluetooth Tethering**: Share mobile internet with IoT device
- **Automatic Fallback**: Seamless switch between WiFi and Bluetooth
- **Direct Connection**: No router or cloud required

## Features

### Connection Modes

1. **WiFi Mode** (Default)
   - Uses local WiFi network
   - Best for online features
   - Requires internet for backend sync

2. **Bluetooth Mode** (Fallback)
   - Direct device-to-device connection
   - Works offline
   - Limited range (~10 meters)

3. **Offline Mode**
   - Bluetooth connection only
   - Local device control
   - No backend sync

## Setup

### 1. Install Dependencies

The required packages are already in `pubspec.yaml`:

```yaml
dependencies:
  flutter_blue_plus: ^1.32.11
  permission_handler: ^11.3.1
```

Run:
```bash
flutter pub get
```

### 2. Platform Configuration

#### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <!-- Bluetooth permissions -->
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
                     android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    
    <!-- For Android 12+ -->
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"
                     android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE"
                     android:maxSdkVersion="30" />
</manifest>
```

#### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to connect to MASH IoT devices</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth to discover and connect to nearby MASH IoT devices</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location permission for Bluetooth scanning</string>
```

## Usage

### Basic Connection

```dart
import 'package:mash_grower_mobile/services/device_connection_manager.dart';

final connectionManager = DeviceConnectionManager();

// Connect to device (tries WiFi first, then Bluetooth)
final connected = await connectionManager.connectToDevice('device-id');

if (connected) {
  print('Connected via ${connectionManager.currentConnectionType}');
}
```

### Bluetooth-Only Connection

```dart
// Prefer Bluetooth over WiFi
final connected = await connectionManager.connectToDevice(
  'device-id',
  preferBluetooth: true,
);
```

### Monitoring Connection Status

```dart
// Listen to connection changes
connectionManager.connectionStatusStream.listen((status) {
  print('Connection type: ${status.type}');
  print('Is connected: ${status.isConnected}');
  print('Has internet: ${status.hasInternet}');
  print('Can access device: ${status.canAccessDevice}');
});
```

### Offline Mode

```dart
// Enable offline mode (Bluetooth only)
final offlineEnabled = await connectionManager.enableOfflineMode();

if (offlineEnabled) {
  // Device is accessible via Bluetooth
  // No internet/backend sync
  final sensorData = await connectionManager.getSensorData();
}
```

### Device Operations

```dart
// Get device status
final status = await connectionManager.getDeviceStatus();

// Get sensor data
final sensorData = await connectionManager.getSensorData();

// Send command
final result = await connectionManager.sendCommand(
  commandType: 'actuator_control',
  data: {'actuator': 'fan', 'state': 'on'},
);
```

## User Interface Integration

### Discovery Screen

```dart
import 'package:mash_grower_mobile/services/bluetooth_device_service.dart';

final bluetoothService = BluetoothDeviceService();

// Start scanning
await bluetoothService.startScanning();

// Listen to discoveries
bluetoothService.devicesStream.listen((devices) {
  // Update UI with discovered devices
  setState(() {
    _devices = devices;
  });
});

// Display devices
ListView.builder(
  itemCount: _devices.length,
  itemBuilder: (context, index) {
    final device = _devices[index];
    return ListTile(
      title: Text(device.name),
      subtitle: Text('Signal: ${device.rssi} dBm'),
      trailing: ElevatedButton(
        onPressed: () => _connectToDevice(device),
        child: Text('Connect'),
      ),
    );
  },
);
```

### Connection Status Indicator

```dart
Widget buildConnectionStatus(ConnectionStatus status) {
  IconData icon;
  Color color;
  String text;
  
  switch (status.type) {
    case ConnectionType.wifi:
      icon = Icons.wifi;
      color = Colors.green;
      text = 'WiFi Connected';
      break;
    case ConnectionType.bluetooth:
      icon = Icons.bluetooth_connected;
      color = Colors.blue;
      text = 'Bluetooth Connected';
      break;
    case ConnectionType.offline:
      icon = Icons.cloud_off;
      color = Colors.orange;
      text = 'Offline Mode';
      break;
    default:
      icon = Icons.signal_wifi_off;
      color = Colors.red;
      text = 'Disconnected';
  }
  
  return Chip(
    avatar: Icon(icon, color: color),
    label: Text(text),
  );
}
```

### Settings Screen

```dart
class ConnectionSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: Text('Prefer Bluetooth'),
          subtitle: Text('Use Bluetooth instead of WiFi when available'),
          value: _preferBluetooth,
          onChanged: (value) {
            setState(() => _preferBluetooth = value);
          },
        ),
        SwitchListTile(
          title: Text('Offline Mode'),
          subtitle: Text('Disable internet features'),
          value: _offlineMode,
          onChanged: (value) async {
            if (value) {
              await connectionManager.enableOfflineMode();
            }
            setState(() => _offlineMode = value);
          },
        ),
        ListTile(
          title: Text('Scan for Bluetooth Devices'),
          trailing: Icon(Icons.bluetooth_searching),
          onTap: () async {
            await bluetoothService.startScanning();
          },
        ),
      ],
    );
  }
}
```

## Best Practices

### 1. Permission Handling

```dart
// Request permissions before scanning
final permissionsGranted = await bluetoothService.requestPermissions();

if (!permissionsGranted) {
  // Show explanation dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Bluetooth Permissions Required'),
      content: Text('Please grant Bluetooth permissions to connect to devices'),
      actions: [
        TextButton(
          onPressed: () => openAppSettings(),
          child: Text('Open Settings'),
        ),
      ],
    ),
  );
}
```

### 2. Battery Optimization

```dart
// Stop scanning when not needed
@override
void dispose() {
  bluetoothService.stopScanning();
  super.dispose();
}

// Use scan timeout
await bluetoothService.startScanning(); // Auto-stops after 15s
```

### 3. Error Handling

```dart
try {
  final connected = await connectionManager.connectToDevice(deviceId);
  if (!connected) {
    _showError('Failed to connect to device');
  }
} catch (e) {
  Logger.error('Connection error: $e');
  _showError('Connection error: ${e.toString()}');
}
```

### 4. Connection Resilience

```dart
// Reconnect on connection loss
connectionManager.connectionStatusStream.listen((status) {
  if (!status.isConnected && _wasConnected) {
    // Attempt reconnection
    _attemptReconnect();
  }
  _wasConnected = status.isConnected;
});

Future<void> _attemptReconnect() async {
  await Future.delayed(Duration(seconds: 5));
  await connectionManager.connectToDevice(_lastDeviceId);
}
```

## Limitations

### Bluetooth Constraints

- **Range**: ~10 meters (30 feet)
- **Speed**: ~1-3 Mbps
- **Latency**: Higher than WiFi
- **Battery**: Moderate drain

### Offline Mode Limitations

- No backend sync
- No cloud features
- No remote notifications
- Local data only

## Troubleshooting

### Bluetooth Not Available

```dart
if (!await bluetoothService.isBluetoothAvailable()) {
  // Check if supported
  if (await FlutterBluePlus.isSupported == false) {
    _showError('Bluetooth not supported on this device');
  } else {
    _showError('Please enable Bluetooth in device settings');
  }
}
```

### Device Not Found

1. Ensure IoT device has Bluetooth enabled
2. Verify device is in discoverable mode
3. Check if device is in range
4. Try re-scanning

### Connection Fails

1. Check Bluetooth permissions
2. Verify device is powered on
3. Remove old pairings and re-pair
4. Restart Bluetooth on both devices

### Data Not Updating

1. Check connection status
2. Verify device is responding
3. Check for timeout errors
4. Try reconnecting

## Testing

### Unit Tests

```dart
test('should connect via Bluetooth when WiFi unavailable', () async {
  when(mockConnectivity.checkConnectivity())
      .thenAnswer((_) async => [ConnectivityResult.none]);
  
  final connected = await connectionManager.connectToDevice('device-id');
  
  expect(connected, true);
  expect(connectionManager.currentConnectionType, ConnectionType.bluetooth);
});
```

### Integration Tests

```dart
testWidgets('should show Bluetooth devices in list', (tester) async {
  await tester.pumpWidget(MyApp());
  
  await tester.tap(find.byIcon(Icons.bluetooth_searching));
  await tester.pumpAndSettle();
  
  expect(find.text('MASH-IoT-Device'), findsOneWidget);
});
```

## Performance Tips

1. **Scan Duration**: Keep scans short (10-15 seconds)
2. **Caching**: Cache discovered devices
3. **Auto-connect**: Save last connected device
4. **Background**: Stop scanning in background
5. **Battery**: Monitor battery usage

## Security

1. **Pairing**: Use secure pairing with PIN
2. **Encryption**: Data is encrypted over Bluetooth
3. **Permissions**: Request minimum necessary permissions
4. **Trust**: Only connect to known devices

## Support

For issues:
1. Check app logs
2. Enable debug mode
3. Verify permissions
4. Test on different devices
