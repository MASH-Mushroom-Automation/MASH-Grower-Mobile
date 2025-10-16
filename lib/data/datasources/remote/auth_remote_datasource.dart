import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/logger.dart';

class AuthRemoteDataSource {
  final Dio _dio = DioClient.instance.dio;

  Future<Map<String, dynamic>> exchangeToken(String firebaseToken) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.authExchange,
        data: {'firebase_token': firebaseToken},
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Token exchange failed');
      }
    } catch (e) {
      Logger.error('Token exchange failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.authRefresh,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      Logger.error('Token refresh failed: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.authLogout);
    } catch (e) {
      Logger.error('Logout failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiEndpoints.authMe);

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (e) {
      Logger.error('Get current user failed: $e');
      rethrow;
    }
  }
}
