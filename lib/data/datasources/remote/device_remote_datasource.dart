import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../../models/device_model.dart';

class DeviceRemoteDataSource {
  final Dio _dio = DioClient.instance.dio;

  Future<List<DeviceModel>> getDevices() async {
    try {
      final response = await _dio.get(ApiEndpoints.devices);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => DeviceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get devices');
      }
    } catch (e) {
      Logger.error('Failed to get devices: $e');
      rethrow;
    }
  }

  Future<DeviceModel> getDevice(String deviceId) async {
    try {
      final response = await _dio.get(ApiEndpoints.deviceById(deviceId));

      if (response.statusCode == 200) {
        return DeviceModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to get device');
      }
    } catch (e) {
      Logger.error('Failed to get device: $e');
      rethrow;
    }
  }

  Future<DeviceModel> createDevice(DeviceModel device) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.devices,
        data: device.toJson(),
      );

      if (response.statusCode == 201) {
        return DeviceModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create device');
      }
    } catch (e) {
      Logger.error('Failed to create device: $e');
      rethrow;
    }
  }

  Future<DeviceModel> updateDevice(String deviceId, DeviceModel device) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.deviceById(deviceId),
        data: device.toJson(),
      );

      if (response.statusCode == 200) {
        return DeviceModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update device');
      }
    } catch (e) {
      Logger.error('Failed to update device: $e');
      rethrow;
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    try {
      final response = await _dio.delete(ApiEndpoints.deviceById(deviceId));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete device');
      }
    } catch (e) {
      Logger.error('Failed to delete device: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDeviceStatus(String deviceId) async {
    try {
      final response = await _dio.get(ApiEndpoints.deviceStatus(deviceId));

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to get device status');
      }
    } catch (e) {
      Logger.error('Failed to get device status: $e');
      rethrow;
    }
  }

  Future<void> sendCommand(String deviceId, String command, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.deviceCommands(deviceId),
        data: {
          'command': command,
          'data': data,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send command');
      }
    } catch (e) {
      Logger.error('Failed to send command: $e');
      rethrow;
    }
  }
}
