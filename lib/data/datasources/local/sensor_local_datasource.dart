import '../local/database_helper.dart';
import '../../models/sensor_reading_model.dart';
import '../../../core/utils/logger.dart';

class SensorLocalDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> saveReading(SensorReadingModel reading) async {
    try {
      await _databaseHelper.insert('sensor_readings', reading.toDatabase());
      Logger.databaseResult(1, 'INSERT');
    } catch (e) {
      Logger.error('Failed to save sensor reading: $e');
      rethrow;
    }
  }

  Future<void> saveReadings(List<SensorReadingModel> readings) async {
    try {
      await _databaseHelper.transaction((txn) async {
        for (final reading in readings) {
          await txn.insert('sensor_readings', reading.toDatabase());
        }
      });
      Logger.databaseResult(readings.length, 'BATCH INSERT');
    } catch (e) {
      Logger.error('Failed to save sensor readings: $e');
      rethrow;
    }
  }

  Future<List<SensorReadingModel>> getLatestReadings(String deviceId) async {
    try {
      final results = await _databaseHelper.query(
        'sensor_readings',
        where: 'device_id = ?',
        whereArgs: [deviceId],
        orderBy: 'timestamp DESC',
        limit: 10,
      );

      return results.map((map) => SensorReadingModel.fromDatabase(map)).toList();
    } catch (e) {
      Logger.error('Failed to get latest readings: $e');
      return [];
    }
  }

  Future<List<SensorReadingModel>> getHistoricalData(
    String deviceId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String whereClause = 'device_id = ?';
      List<dynamic> whereArgs = [deviceId];

      if (startDate != null) {
        whereClause += ' AND timestamp >= ?';
        whereArgs.add(startDate.millisecondsSinceEpoch);
      }

      if (endDate != null) {
        whereClause += ' AND timestamp <= ?';
        whereArgs.add(endDate.millisecondsSinceEpoch);
      }

      final results = await _databaseHelper.query(
        'sensor_readings',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
      );

      return results.map((map) => SensorReadingModel.fromDatabase(map)).toList();
    } catch (e) {
      Logger.error('Failed to get historical data: $e');
      return [];
    }
  }

  Future<List<SensorReadingModel>> getDeviceData(String deviceId) async {
    try {
      final results = await _databaseHelper.query(
        'sensor_readings',
        where: 'device_id = ?',
        whereArgs: [deviceId],
        orderBy: 'timestamp DESC',
      );

      return results.map((map) => SensorReadingModel.fromDatabase(map)).toList();
    } catch (e) {
      Logger.error('Failed to get device data: $e');
      return [];
    }
  }

  Future<List<SensorReadingModel>> getReadingsByType(String deviceId, String sensorType) async {
    try {
      final results = await _databaseHelper.query(
        'sensor_readings',
        where: 'device_id = ? AND sensor_type = ?',
        whereArgs: [deviceId, sensorType],
        orderBy: 'timestamp DESC',
      );

      return results.map((map) => SensorReadingModel.fromDatabase(map)).toList();
    } catch (e) {
      Logger.error('Failed to get readings by type: $e');
      return [];
    }
  }

  Future<List<SensorReadingModel>> getUnsyncedReadings() async {
    try {
      final results = await _databaseHelper.query(
        'sensor_readings',
        where: 'synced = 0',
        orderBy: 'timestamp ASC',
      );

      return results.map((map) => SensorReadingModel.fromDatabase(map)).toList();
    } catch (e) {
      Logger.error('Failed to get unsynced readings: $e');
      return [];
    }
  }

  Future<void> markAsSynced(List<SensorReadingModel> readings) async {
    try {
      final ids = readings.map((r) => r.id).toList();
      
      await _databaseHelper.update(
        'sensor_readings',
        {'synced': 1},
        where: 'id IN (${ids.map((_) => '?').join(',')})',
        whereArgs: ids,
      );
      
      Logger.info('Marked ${readings.length} readings as synced');
    } catch (e) {
      Logger.error('Failed to mark readings as synced: $e');
      rethrow;
    }
  }

  Future<void> deleteOldReadings(int daysToKeep) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      final deletedCount = await _databaseHelper.delete(
        'sensor_readings',
        where: 'timestamp < ?',
        whereArgs: [cutoffDate.millisecondsSinceEpoch],
      );
      
      Logger.info('Deleted $deletedCount old sensor readings');
    } catch (e) {
      Logger.error('Failed to delete old readings: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> getAverageValues(String deviceId, String sensorType, {int hours = 24}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(hours: hours));
      
      final results = await _databaseHelper.rawQuery(
        '''
        SELECT sensor_type, AVG(value) as avg_value
        FROM sensor_readings 
        WHERE device_id = ? AND sensor_type = ? AND timestamp >= ?
        GROUP BY sensor_type
        ''',
        [deviceId, sensorType, cutoffDate.millisecondsSinceEpoch],
      );

      final averages = <String, double>{};
      for (final row in results) {
        averages[row['sensor_type'] as String] = (row['avg_value'] as num).toDouble();
      }

      return averages;
    } catch (e) {
      Logger.error('Failed to get average values: $e');
      return {};
    }
  }

  Future<List<SensorReadingModel>> getReadingsInRange(
    String deviceId,
    String sensorType,
    double minValue,
    double maxValue,
  ) async {
    try {
      final results = await _databaseHelper.query(
        'sensor_readings',
        where: 'device_id = ? AND sensor_type = ? AND value >= ? AND value <= ?',
        whereArgs: [deviceId, sensorType, minValue, maxValue],
        orderBy: 'timestamp DESC',
      );

      return results.map((map) => SensorReadingModel.fromDatabase(map)).toList();
    } catch (e) {
      Logger.error('Failed to get readings in range: $e');
      return [];
    }
  }

  Future<void> clearDeviceData(String deviceId) async {
    try {
      await _databaseHelper.delete(
        'sensor_readings',
        where: 'device_id = ?',
        whereArgs: [deviceId],
      );
      
      Logger.info('Cleared all data for device $deviceId');
    } catch (e) {
      Logger.error('Failed to clear device data: $e');
      rethrow;
    }
  }

  Future<int> getDataCount(String deviceId) async {
    try {
      final results = await _databaseHelper.query(
        'sensor_readings',
        where: 'device_id = ?',
        whereArgs: [deviceId],
      );

      return results.length;
    } catch (e) {
      Logger.error('Failed to get data count: $e');
      return 0;
    }
  }
}
