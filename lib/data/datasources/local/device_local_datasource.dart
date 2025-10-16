import '../local/database_helper.dart';
import '../../models/device_model.dart';
import '../../../core/utils/logger.dart';

class DeviceLocalDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> saveDevice(DeviceModel device) async {
    try {
      await _databaseHelper.insert('devices', device.toDatabase());
      Logger.databaseResult(1, 'INSERT');
    } catch (e) {
      Logger.error('Failed to save device: $e');
      rethrow;
    }
  }

  Future<void> saveDevices(List<DeviceModel> devices) async {
    try {
      await _databaseHelper.transaction((txn) async {
        for (final device in devices) {
          await txn.insert('devices', device.toDatabase());
        }
      });
      Logger.databaseResult(devices.length, 'BATCH INSERT');
    } catch (e) {
      Logger.error('Failed to save devices: $e');
      rethrow;
    }
  }

  Future<List<DeviceModel>> getDevices() async {
    try {
      final results = await _databaseHelper.query(
        'devices',
        orderBy: 'created_at DESC',
      );

      return results.map((map) => DeviceModel.fromDatabase(map)).toList();
    } catch (e) {
      Logger.error('Failed to get devices: $e');
      return [];
    }
  }

  Future<DeviceModel?> getDevice(String deviceId) async {
    try {
      final result = await _databaseHelper.queryFirst(
        'devices',
        where: 'id = ?',
        whereArgs: [deviceId],
      );

      return result != null ? DeviceModel.fromDatabase(result) : null;
    } catch (e) {
      Logger.error('Failed to get device: $e');
      return null;
    }
  }

  Future<void> updateDevice(DeviceModel device) async {
    try {
      await _databaseHelper.update(
        'devices',
        device.toDatabase(),
        where: 'id = ?',
        whereArgs: [device.id],
      );
      Logger.databaseResult(1, 'UPDATE');
    } catch (e) {
      Logger.error('Failed to update device: $e');
      rethrow;
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    try {
      await _databaseHelper.delete(
        'devices',
        where: 'id = ?',
        whereArgs: [deviceId],
      );
      Logger.databaseResult(1, 'DELETE');
    } catch (e) {
      Logger.error('Failed to delete device: $e');
      rethrow;
    }
  }

  Future<List<DeviceModel>> getDevicesByUser(String userId) async {
    try {
      final results = await _databaseHelper.query(
        'devices',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return results.map((map) => DeviceModel.fromDatabase(map)).toList();
    } catch (e) {
      Logger.error('Failed to get devices by user: $e');
      return [];
    }
  }

  Future<List<DeviceModel>> getOnlineDevices() async {
    try {
      final results = await _databaseHelper.query(
        'devices',
        where: 'status = ?',
        whereArgs: ['online'],
        orderBy: 'last_seen DESC',
      );

      return results.map((map) => DeviceModel.fromDatabase(map)).toList();
    } catch (e) {
      Logger.error('Failed to get online devices: $e');
      return [];
    }
  }

  Future<void> updateDeviceStatus(String deviceId, String status) async {
    try {
      await _databaseHelper.update(
        'devices',
        {
          'status': status,
          'last_seen': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [deviceId],
      );
      Logger.databaseResult(1, 'UPDATE STATUS');
    } catch (e) {
      Logger.error('Failed to update device status: $e');
      rethrow;
    }
  }

  Future<void> clearDevices() async {
    try {
      await _databaseHelper.delete('devices');
      Logger.info('Cleared all devices');
    } catch (e) {
      Logger.error('Failed to clear devices: $e');
      rethrow;
    }
  }
}
