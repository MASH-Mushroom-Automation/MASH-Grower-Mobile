import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/logger.dart';
import '../config/api_config.dart';
import '../constants/api_endpoints.dart';
import '../constants/storage_keys.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  static Dio? _dio;

  DioClient._internal();

  factory DioClient() => _instance;

  static DioClient get instance => _instance;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Connectivity _connectivity = Connectivity();

  Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  Dio _createDio() {
    final dio = Dio();
    
    // Base options
    dio.options = BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Interceptors
    dio.interceptors.addAll([
      _AuthInterceptor(_secureStorage),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
      _ConnectivityInterceptor(_connectivity),
    ]);

    return dio;
  }

  // Update base URL (useful for switching between dev/prod)
  void updateBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
    Logger.info('🌐 Base URL updated to: $baseUrl');
  }

  // Clear all interceptors and recreate Dio
  void reset() {
    _dio = null;
    Logger.info('🔄 Dio client reset');
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  _AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add auth token to requests
    final token = await _secureStorage.read(key: StorageKeys.accessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add correlation ID for request tracking
    final correlationId = DateTime.now().millisecondsSinceEpoch.toString();
    options.headers['X-Request-ID'] = correlationId;
    options.headers['X-Correlation-ID'] = correlationId;
    
    Logger.networkRequest(
      options.method,
      '${options.baseUrl}${options.path}',
      options.headers,
      options.data,
    );
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 errors by refreshing token
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry the original request
        final options = err.requestOptions;
        final token = await _secureStorage.read(key: StorageKeys.accessToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          try {
            final response = await DioClient.instance.dio.fetch(options);
            handler.resolve(response);
            return;
          } catch (e) {
            // If retry fails, continue with original error
          }
        }
      }
    }
    
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);
      if (refreshToken == null) {
        Logger.error('No refresh token available');
        return false;
      }

      Logger.info('🔄 Attempting to refresh access token...');
      
      // Use a fresh Dio instance to avoid interceptor loops
      final freshDio = Dio(BaseOptions(
        baseUrl: ApiConfig.apiBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await freshDio.post(
        ApiEndpoints.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        // Extract token from backend response structure
        final data = response.data['data'];
        final newAccessToken = data['accessToken'] ?? data['token'];
        final newRefreshToken = data['refreshToken'];
        
        if (newAccessToken != null) {
          await _secureStorage.write(key: StorageKeys.accessToken, value: newAccessToken);
          
          if (newRefreshToken != null) {
            await _secureStorage.write(key: StorageKeys.refreshToken, value: newRefreshToken);
          }
          
          Logger.info('✅ Access token refreshed successfully');
          return true;
        }
      }
    } catch (e) {
      Logger.error('❌ Token refresh failed', e);
      // Clear tokens on refresh failure
      await _secureStorage.delete(key: StorageKeys.accessToken);
      await _secureStorage.delete(key: StorageKeys.refreshToken);
    }
    return false;
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Logger.networkRequest(
      options.method,
      '${options.baseUrl}${options.path}',
      options.headers,
      options.data,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.networkResponse(
      response.statusCode ?? 0,
      '${response.requestOptions.baseUrl}${response.requestOptions.path}',
      response.data,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Logger.networkResponse(
      err.response?.statusCode ?? 0,
      '${err.requestOptions.baseUrl}${err.requestOptions.path}',
      err.response?.data,
    );
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = 'An error occurred';
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              message = 'Bad request. Please check your input.';
              break;
            case 401:
              message = 'Unauthorized. Please login again.';
              break;
            case 403:
              message = 'Forbidden. You don\'t have permission.';
              break;
            case 404:
              message = 'Resource not found.';
              break;
            case 429:
              message = 'Too many requests. Please try again later.';
              break;
            case 500:
              message = 'Server error. Please try again later.';
              break;
            default:
              message = 'HTTP $statusCode error occurred.';
          }
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet connection.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Certificate error. Please check your connection.';
        break;
      case DioExceptionType.unknown:
        message = 'Unknown error occurred.';
        break;
    }

    // Create a custom error with the message
    final customError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: message,
    );

    handler.next(customError);
  }
}

class _ConnectivityInterceptor extends Interceptor {
  final Connectivity _connectivity;

  _ConnectivityInterceptor(this._connectivity);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final connectivityResults = await _connectivity.checkConnectivity();
    if (connectivityResults.contains(ConnectivityResult.none)) {
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'No internet connection',
      ));
      return;
    }
    handler.next(options);
  }
}
