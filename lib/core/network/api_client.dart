import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'exceptions.dart';
import '../utils/logger.dart';

/// High-level API client for making HTTP requests
/// 
/// This class provides a simplified interface for making API calls
/// and handles error mapping to custom exception classes.
class ApiClient {
  final DioClient _dioClient;
  
  ApiClient(this._dioClient);
  
  Dio get _dio => _dioClient.dio;
  
  /// Make a GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Make a POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      Logger.info('🌐 POST Request: $path');
      Logger.info('📤 Request Data: $data');
      
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      Logger.info('✅ POST Response: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      Logger.error('❌ POST Error: ${e.type}', e);
      Logger.error('Error Message: ${e.message}');
      Logger.error('Error Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      Logger.error('❌ Unexpected POST Error: $e', e);
      Logger.error('Stack Trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Make a PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Make a PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Make a DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Handle Dio errors and map them to custom exceptions
  ApiException _handleError(DioException error) {
    Logger.error('API Error: ${error.message}', error);
    
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    
    // Extract error message from response
    String message = _extractErrorMessage(data) ?? 'An error occurred';
    
    // Map status codes to custom exceptions
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          'Request timeout. Please check your connection and try again.',
          statusCode: statusCode,
          data: data,
        );
        
      case DioExceptionType.connectionError:
        return NetworkException(
          'Connection error. Please check your internet connection.',
          statusCode: statusCode,
          data: data,
        );
        
      case DioExceptionType.badResponse:
        return _handleBadResponse(statusCode, message, data);
        
      case DioExceptionType.cancel:
        return ApiException('Request was cancelled', statusCode: statusCode, data: data);
        
      case DioExceptionType.badCertificate:
        return NetworkException(
          'Certificate error. Please check your connection security.',
          statusCode: statusCode,
          data: data,
        );
        
      case DioExceptionType.unknown:
        return ApiException(
          message.isEmpty ? 'Unknown error occurred' : message,
          statusCode: statusCode,
          data: data,
        );
    }
  }
  
  /// Handle bad HTTP response status codes
  ApiException _handleBadResponse(int? statusCode, String message, dynamic data) {
    switch (statusCode) {
      case 400:
        // Check if it's a validation error
        if (data is Map && data.containsKey('errors')) {
          return ValidationException(
            message,
            statusCode: statusCode,
            data: data,
            errors: _extractValidationErrors(data['errors']),
          );
        }
        return BadRequestException(message, statusCode: statusCode, data: data);
        
      case 401:
        return UnauthorizedException(
          message.isEmpty ? 'Unauthorized. Please login again.' : message,
          statusCode: statusCode,
          data: data,
        );
        
      case 403:
        return ForbiddenException(
          message.isEmpty ? 'Forbidden. You don\'t have permission.' : message,
          statusCode: statusCode,
          data: data,
        );
        
      case 404:
        return NotFoundException(
          message.isEmpty ? 'Resource not found.' : message,
          statusCode: statusCode,
          data: data,
        );
        
      case 409:
        return ConflictException(
          message.isEmpty ? 'Conflict. Resource already exists.' : message,
          statusCode: statusCode,
          data: data,
        );
        
      case 429:
        return RateLimitException(
          message.isEmpty ? 'Too many requests. Please try again later.' : message,
          statusCode: statusCode,
          data: data,
          retryAfter: _extractRetryAfter(data),
        );
        
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message.isEmpty ? 'Server error. Please try again later.' : message,
          statusCode: statusCode,
          data: data,
        );
        
      default:
        return ApiException(
          message.isEmpty ? 'HTTP $statusCode error occurred.' : message,
          statusCode: statusCode,
          data: data,
        );
    }
  }
  
  /// Extract error message from response data
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    
    if (data is Map) {
      // Try common error message fields
      if (data.containsKey('message')) return data['message'] as String?;
      if (data.containsKey('error')) {
        final error = data['error'];
        if (error is String) return error;
        if (error is Map && error.containsKey('message')) {
          return error['message'] as String?;
        }
      }
      if (data.containsKey('detail')) return data['detail'] as String?;
    }
    
    if (data is String) return data;
    
    return null;
  }
  
  /// Extract validation errors from response
  Map<String, List<String>>? _extractValidationErrors(dynamic errors) {
    if (errors == null) return null;
    
    if (errors is Map) {
      final Map<String, List<String>> result = {};
      errors.forEach((key, value) {
        if (value is List) {
          result[key as String] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          result[key as String] = [value];
        }
      });
      return result;
    }
    
    return null;
  }
  
  /// Extract retry-after time from response
  DateTime? _extractRetryAfter(dynamic data) {
    if (data is Map && data.containsKey('retryAfter')) {
      final retryAfter = data['retryAfter'];
      if (retryAfter is int) {
        return DateTime.now().add(Duration(seconds: retryAfter));
      } else if (retryAfter is String) {
        return DateTime.tryParse(retryAfter);
      }
    }
    return null;
  }
}
