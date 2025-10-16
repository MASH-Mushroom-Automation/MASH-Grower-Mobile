import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../../models/sensor_reading_model.dart';

class SensorRemoteDataSource {
  final Dio _dio = DioClient.instance.dio;

  Future<List<SensorReadingModel>> getLatestReadings(String deviceId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.sensorLatest(deviceId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => SensorReadingModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get latest readings');
      }
    } catch (e) {
      Logger.error('Failed to get latest readings: $e');
      rethrow;
    }
  }

  Future<List<SensorReadingModel>> getHistoricalData(
    String deviceId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.millisecondsSinceEpoch;
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.millisecondsSinceEpoch;
      }

      final response = await _dio.get(
        ApiEndpoints.sensorHistory(deviceId),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => SensorReadingModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get historical data');
      }
    } catch (e) {
      Logger.error('Failed to get historical data: $e');
      rethrow;
    }
  }

  Future<List<SensorReadingModel>> getDeviceData(String deviceId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.sensorDataByDevice(deviceId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => SensorReadingModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get device data');
      }
    } catch (e) {
      Logger.error('Failed to get device data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSensorAnalytics(String deviceId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.sensorAnalytics(deviceId),
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to get sensor analytics');
      }
    } catch (e) {
      Logger.error('Failed to get sensor analytics: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSensorTrends(String deviceId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.sensorTrends(deviceId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get sensor trends');
      }
    } catch (e) {
      Logger.error('Failed to get sensor trends: $e');
      rethrow;
    }
  }

  Future<List<String>> getSensorTypes() async {
    try {
      final response = await _dio.get(ApiEndpoints.sensorTypes);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.cast<String>();
      } else {
        throw Exception('Failed to get sensor types');
      }
    } catch (e) {
      Logger.error('Failed to get sensor types: $e');
      rethrow;
    }
  }

  Future<void> syncReadings(List<SensorReadingModel> readings) async {
    try {
      final data = readings.map((reading) => reading.toJson()).toList();
      
      final response = await _dio.post(
        ApiEndpoints.sensorData,
        data: {'readings': data},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to sync readings');
      }
      
      Logger.info('Synced ${readings.length} sensor readings');
    } catch (e) {
      Logger.error('Failed to sync readings: $e');
      rethrow;
    }
  }

  Future<void> calibrateSensor(String deviceId, String sensorType, Map<String, dynamic> calibrationData) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.sensorCalibrate(deviceId),
        data: {
          'sensor_type': sensorType,
          'calibration_data': calibrationData,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to calibrate sensor');
      }
      
      Logger.info('Sensor $sensorType calibrated for device $deviceId');
    } catch (e) {
      Logger.error('Failed to calibrate sensor: $e');
      rethrow;
    }
  }
}
