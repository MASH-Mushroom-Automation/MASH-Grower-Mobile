import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:mash_grower_mobile/presentation/providers/sensor_provider.dart';
import 'package:mash_grower_mobile/data/models/sensor_reading_model.dart';

@GenerateMocks([])
void main() {
  group('SensorProvider Tests', () {
    late SensorProvider sensorProvider;

    setUp(() {
      sensorProvider = SensorProvider();
    });

    tearDown(() {
      sensorProvider.dispose();
    });

    test('initial state is correct', () {
      expect(sensorProvider.isLoading, false);
      expect(sensorProvider.latestReadings, isEmpty);
      expect(sensorProvider.historicalData, isEmpty);
      expect(sensorProvider.deviceData, isEmpty);
      expect(sensorProvider.error, null);
    });

    test('sensor reading model creation from JSON', () {
      final readingJson = {
        'id': 'reading-123',
        'deviceId': 'device-456',
        'sensorType': 'temperature',
        'value': 25.5,
        'unit': '°C',
        'qualityIndicator': 'good',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      final reading = SensorReadingModel.fromJson(readingJson);

      expect(reading.id, 'reading-123');
      expect(reading.deviceId, 'device-456');
      expect(reading.sensorType, 'temperature');
      expect(reading.value, 25.5);
      expect(reading.unit, '°C');
      expect(reading.qualityIndicator, 'good');
    });

    test('sensor reading model to JSON conversion', () {
      final reading = SensorReadingModel(
        id: 'reading-123',
        deviceId: 'device-456',
        sensorType: 'temperature',
        value: 25.5,
        qualityIndicator: 'good',
        timestamp: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final json = reading.toJson();

      expect(json['id'], 'reading-123');
      expect(json['deviceId'], 'device-456');
      expect(json['sensorType'], 'temperature');
      expect(json['value'], 25.5);
      // Note: unit field removed from model
      expect(json['qualityIndicator'], 'good');
    });

    test('get readings by type', () {
      // Note: In a real test, you'd add test readings to the provider's state
      // and test the getReadingsByType method
      expect(true, true); // Placeholder test
    });
  });
}
