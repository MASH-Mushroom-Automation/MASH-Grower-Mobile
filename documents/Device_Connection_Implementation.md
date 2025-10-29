# MASH Device Connection Implementation Guide

## Overview

This document describes the complete implementation of the device connection system between the MASH Mobile App and IoT Device. The system supports WiFi provisioning, local discovery, and communication.

## Architecture

### Components

#### IoT Device (Raspberry Pi)
1. **Network Manager** (`src/utils/network_manager.py`)
   - Scans for WiFi networks
   - Connects to WiFi networks
   - Manages network interface

2. **Provisioning Manager** (`src/utils/provisioning_manager.py`)
   - Creates SoftAP (Access Point) for provisioning
   - Manages provisioning mode state
   - Uses NetworkManager (nmcli) for AP creation

3. **API Server** (`src/api/api_server.py`)
   - Provides local REST API endpoints
   - Serves WiFi configuration endpoints
   - Returns sensor data and device status

4. **mDNS Service** (`src/discovery/mdns_service.py`)
   - Broadcasts device presence on local network
   - Enables automatic discovery by mobile app

#### Mobile App (Flutter)
1. **Local Device Client** (`lib/services/local_device_client.dart`)
   - HTTP client for local device communication
   - Supports both provisioning and normal modes
   - Handles WiFi scanning and configuration

2. **mDNS Discovery Service** (`lib/services/mdns_discovery_service.dart`)
   - Discovers devices on local network
   - Uses multicast DNS protocol
   - Returns discovered device information

3. **Device Provisioning Service** (`lib/services/device_provisioning_service.dart`)
   - Orchestrates complete provisioning flow
   - Manages state transitions
   - Registers device with backend

## Connection Flow

### Phase 1: First-Time Setup (Provisioning)

#### Step 1: Device Powers On
```
Device Boot → Check WiFi Connection → Enter Provisioning Mode (if not connected)
                                    ↓
                              Create SoftAP (SSID: MASH-Chamber-XXXX)
                                    ↓
                              Start Local API Server (192.168.4.1:5000)
```

**IoT Device:**
- Starts in provisioning mode if no WiFi connection exists
- Creates Access Point: `MASH-Chamber-<device-id>`
- IP Address: `192.168.4.1`
- API available at: `http://192.168.4.1:5000/api/v1`

**Endpoints Available:**
- `GET /api/v1/wifi/scan` - Scan for WiFi networks
- `POST /api/v1/wifi/config` - Configure WiFi credentials
- `GET /api/v1/provisioning/info` - Get device info
- `GET /api/v1/status` - Get device status

#### Step 2: User Connects to Device WiFi
```
User → Phone WiFi Settings → Connect to "MASH-Chamber-XXXX"
                                    ↓
                              Mobile App Detects Connection
```

**Mobile App:**
- User manually connects to device's WiFi network
- App detects connection to provisioning network
- Verifies connection to device API

**Code:**
```dart
// Verify provisioning connection
final connected = await provisioningService.verifyProvisioningConnection();
```

#### Step 3: Scan for Available WiFi Networks
```
Mobile App → GET http://192.168.4.1:5000/api/v1/wifi/scan
                                    ↓
            Device Scans WiFi Networks (nmcli)
                                    ↓
            Returns List of Networks to App
```

**Request:**
```http
GET /api/v1/wifi/scan HTTP/1.1
Host: 192.168.4.1:5000
```

**Response:**
```json
{
  "success": true,
  "networks": [
    {
      "ssid": "Home WiFi",
      "signal": 85,
      "security": "WPA2",
      "frequency": "2.4 GHz"
    }
  ],
  "timestamp": "2025-10-29T10:00:00Z"
}
```

**Code:**
```dart
// Scan WiFi networks
final networks = await provisioningService.scanWiFiNetworks();
```

#### Step 4: Configure WiFi
```
User Selects Network + Enters Password
                ↓
POST http://192.168.4.1:5000/api/v1/wifi/config
                ↓
Device Connects to Home WiFi (nmcli)
                ↓
Device Stops Provisioning Mode
                ↓
Device Starts mDNS Service
```

**Request:**
```http
POST /api/v1/wifi/config HTTP/1.1
Host: 192.168.4.1:5000
Content-Type: application/json

{
  "ssid": "Home WiFi",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Connecting to Home WiFi",
  "timestamp": "2025-10-29T10:01:00Z"
}
```

**Code:**
```python
# IoT Device
success = network_manager.connect_to_wifi(ssid, password)
if success:
    provisioning_manager.stop_provisioning_mode()
    mdns_service.start()
```

#### Step 5: Discover Device on Network
```
Device Connects to WiFi → Gets IP (e.g., 192.168.1.100)
                                    ↓
                         Starts mDNS Broadcasting
                                    ↓
Mobile App Starts mDNS Discovery
                                    ↓
        Finds Device at New IP Address
```

**mDNS Service Info:**
- Service Type: `_mash-iot._tcp.local.`
- Service Name: `<device-id>._mash-iot._tcp.local.`
- Port: 5000
- Properties:
  - `device_id`: Unique device identifier
  - `name`: Device friendly name
  - `type`: "mash-iot-device"
  - `api_version`: "v1"

**Code:**
```dart
// Mobile App Discovery
await mdnsService.startDiscovery();

// Listen for discovered devices
mdnsService.devicesStream.listen((devices) {
  if (devices.isNotEmpty) {
    final device = devices.first;
    print('Found device at ${device.ipAddress}');
  }
});
```

#### Step 6: Register with Backend
```
Mobile App → POST /api/devices (Backend API)
                                    ↓
                Backend Stores Device Record
                                    ↓
                Returns Device Model to App
```

**Request to Backend:**
```http
POST /api/v1/devices HTTP/1.1
Host: backend-api-url
Authorization: Bearer <token>
Content-Type: application/json

{
  "id": "mash-device-001",
  "user_id": "user123",
  "name": "My MASH Chamber",
  "device_type": "grow_chamber",
  "status": "online",
  "configuration": {
    "ip_address": "192.168.1.100",
    "port": 5000
  }
}
```

### Phase 2: Normal Operation

#### Local Communication
```
Mobile App (Same WiFi) → Direct HTTP to Device
                                    ↓
        http://192.168.1.100:5000/api/v1/sensors/latest
                                    ↓
                Device Returns Sensor Data
```

**Benefits:**
- Low latency (~10-50ms)
- Works offline (no internet required)
- Real-time data updates
- Direct device control

**Endpoints:**
- `GET /api/v1/sensors/latest` - Get latest sensor readings
- `GET /api/v1/status` - Get device status
- `POST /api/v1/commands/<command>` - Send commands

#### Cloud Communication
```
Mobile App (Remote) → Backend API → MQTT/WebSocket → Device
                                    ↓
                Device Receives Command
                                    ↓
                Executes and Sends Response
```

**Use Cases:**
- User is away from home
- Multiple users need access
- Historical data queries
- Device management

## API Reference

### IoT Device Local API

#### Base URL (Provisioning)
```
http://192.168.4.1:5000/api/v1
```

#### Base URL (Normal)
```
http://<device-ip>:5000/api/v1
```

#### Endpoints

**WiFi Management (Provisioning Only)**

```http
# Scan WiFi Networks
GET /wifi/scan

Response:
{
  "success": true,
  "networks": [
    {
      "ssid": "string",
      "signal": 0-100,
      "security": "string",
      "frequency": "string"
    }
  ]
}

# Configure WiFi
POST /wifi/config
Content-Type: application/json

{
  "ssid": "string",
  "password": "string"
}

Response:
{
  "success": true,
  "message": "Connecting to <ssid>"
}

# Get Provisioning Info
GET /provisioning/info

Response:
{
  "success": true,
  "data": {
    "active": true,
    "ssid": "MASH-Chamber-XXXX",
    "ip_address": "192.168.4.1",
    "device_id": "string",
    "network_connected": false
  }
}
```

**Device Status & Sensors**

```http
# Get Device Status
GET /status

Response:
{
  "running": true,
  "timestamp": "ISO-8601",
  "config": {...},
  "sensor_manager": {...},
  "network": {
    "connected": true,
    "connection": {
      "ssid": "string",
      "ip_address": "string"
    }
  }
}

# Get Latest Sensor Data
GET /sensors/latest

Response:
{
  "temperature": 26.5,
  "humidity": 85.2,
  "co2": 12000,
  "timestamp": "ISO-8601"
}
```

**Device Commands**

```http
# Send Command
POST /commands/<command_type>
Content-Type: application/json

{
  "param1": "value1"
}

Response:
{
  "success": true,
  "result": {...}
}

# Example Commands:
POST /commands/sensor_config
{
  "read_interval": 60
}

POST /commands/device_reboot
{
  "delay": 5
}
```

## Mobile App Usage

### Basic Provisioning Flow

```dart
import 'package:mash_grower_mobile/services/device_provisioning_service.dart';

// Initialize service
final provisioningService = DeviceProvisioningService();

// Complete provisioning flow
final device = await provisioningService.provisionDevice(
  ssid: 'Home WiFi',
  password: 'password123',
  userId: 'user_123',
  deviceName: 'My Chamber',
);

if (device != null) {
  print('Device provisioned: ${device.id}');
}
```

### Discover Local Devices

```dart
// Discover devices on local network
final devices = await provisioningService.discoverLocalDevices();

for (final device in devices) {
  print('Found: ${device.displayName} at ${device.ipAddress}');
}
```

### Connect to Device

```dart
import 'package:mash_grower_mobile/services/local_device_client.dart';

// Create client for local device
final client = LocalDeviceClient.local('192.168.1.100');

// Get sensor data
final sensorData = await client.getSensorData();
print('Temperature: ${sensorData['temperature']}°C');

// Send command
await client.sendCommand(
  commandType: 'sensor_config',
  data: {'read_interval': 30},
);
```

## Troubleshooting

### Device Not Found in Provisioning Mode

**Symptoms:**
- Mobile app cannot connect to `192.168.4.1`
- Device WiFi network not visible

**Solutions:**
1. Ensure device is in provisioning mode:
   ```bash
   python main.py --provision
   ```

2. Check device WiFi status:
   ```bash
   nmcli connection show
   ```

3. Verify SoftAP is running:
   ```bash
   nmcli device status
   ```

### Device Not Discovered After WiFi Configuration

**Symptoms:**
- Device connected to WiFi but not discovered via mDNS
- Mobile app timeout during discovery

**Solutions:**
1. Check device network connection:
   ```bash
   nmcli connection show --active
   ```

2. Verify mDNS service is running:
   ```bash
   systemctl status avahi-daemon
   ```

3. Manually check device IP:
   ```bash
   ip addr show wlan0
   ```

4. Test API manually:
   ```bash
   curl http://<device-ip>:5000/api/v1/status
   ```

### Connection Drops During Provisioning

**Symptoms:**
- App loses connection to device during WiFi configuration

**Expected Behavior:**
- This is normal! Device disconnects from provisioning AP to connect to home WiFi
- App should wait and discover device on new network

**Solution:**
- App automatically handles this with timeout and retry logic
- Wait 30-60 seconds for device to reconnect

## Security Considerations

### Provisioning Security
- Provisioning mode creates open or WPA2-secured AP
- Only active when device has no WiFi connection
- Automatically disabled after successful configuration
- Local API accessible only on provisioning network

### Production Recommendations
1. Use HTTPS for API (self-signed cert acceptable for local)
2. Implement device authentication token
3. Enable WPA2 password for provisioning AP
4. Set provisioning timeout (auto-disable after 15 minutes)

## Performance

### Latency Metrics
- **Local API (Same WiFi):** ~10-50ms
- **Backend API (Remote):** ~200-500ms (depends on internet)
- **mDNS Discovery:** ~2-5 seconds
- **WiFi Configuration:** ~10-30 seconds

### Bandwidth Usage
- **Sensor Data:** ~100 bytes per reading
- **Command:** ~50-200 bytes
- **Discovery:** ~1 KB
- **WiFi Scan:** ~2-5 KB

## Testing

### IoT Device Testing

```bash
# Test in mock mode (no hardware required)
python main.py --mock --debug

# Test provisioning mode
python main.py --provision --mock

# Check device status
python main.py --status
```

### Mobile App Testing

```dart
// Use mock data for UI testing
final client = LocalDeviceClient.provisioning();

// Test connection
final connected = await client.testConnection();

// Mock WiFi networks
final networks = await client.scanWiFiNetworks();
```

## Requirements

### IoT Device (Raspberry Pi)
- Python 3.9+
- NetworkManager (nmcli)
- Avahi daemon (for mDNS)
- Flask (for API server)
- Zeroconf (for mDNS)

**Installation:**
```bash
# Install system dependencies
sudo apt-get install network-manager avahi-daemon

# Install Python dependencies
pip install -r requirements.txt
```

### Mobile App
- Flutter 3.5.0+
- Dart 3.5.0+
- multicast_dns: ^0.3.2
- dio: ^5.7.0
- provider: ^6.1.2

**Installation:**
```bash
flutter pub get
```

## Next Steps

1. **Implement Backend Registration:**
   - Complete device registration with backend API
   - Store device credentials securely
   - Sync device configuration

2. **Add Security Layer:**
   - Implement device authentication
   - Add HTTPS support for local API
   - Secure provisioning AP with password

3. **Enhanced Discovery:**
   - Add Bluetooth LE for discovery (as backup)
   - Implement QR code provisioning
   - Support multiple device discovery

4. **Offline Capabilities:**
   - Local data caching
   - Offline command queuing
   - Sync when connection restored

5. **User Experience:**
   - Add progress indicators
   - Improve error messages
   - Add help documentation in-app

## References

- [NetworkManager Documentation](https://networkmanager.dev/)
- [mDNS/Zeroconf Protocol](https://tools.ietf.org/html/rfc6762)
- [Flutter multicast_dns Package](https://pub.dev/packages/multicast_dns)
- [MASH Project Documentation](./README.md)
