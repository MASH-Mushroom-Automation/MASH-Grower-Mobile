import 'package:equatable/equatable.dart';

/// Standard API Response wrapper for backend responses
/// Follows the structure: { success, statusCode, data, timestamp, path, correlationId }
class ApiResponse<T> extends Equatable {
  final bool success;
  final int statusCode;
  final T? data;
  final String? message;
  final String timestamp;
  final String path;
  final String correlationId;

  const ApiResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.message,
    required this.timestamp,
    required this.path,
    required this.correlationId,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] as String?,
      timestamp: json['timestamp'] as String,
      path: json['path'] as String,
      correlationId: json['correlationId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'statusCode': statusCode,
      'data': data,
      'message': message,
      'timestamp': timestamp,
      'path': path,
      'correlationId': correlationId,
    };
  }

  @override
  List<Object?> get props => [
        success,
        statusCode,
        data,
        message,
        timestamp,
        path,
        correlationId,
      ];
}

/// Auth Token Response Model
/// Used for login and token refresh responses
class AuthTokenResponse extends Equatable {
  final String token;
  final String? refreshToken;
  final int? expiresIn;
  final String? tokenType;

  const AuthTokenResponse({
    required this.token,
    this.refreshToken,
    this.expiresIn,
    this.tokenType = 'Bearer',
  });

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      token: json['token'] as String? ?? json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: json['expiresIn'] as int?,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'tokenType': tokenType,
    };
  }

  @override
  List<Object?> get props => [token, refreshToken, expiresIn, tokenType];
}

/// Verification Response Model
/// Used for email verification responses
class VerificationResponse extends Equatable {
  final bool sent;
  final String? method;
  final String expiresIn;
  final String email;

  const VerificationResponse({
    required this.sent,
    this.method,
    required this.expiresIn,
    required this.email,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      sent: json['sent'] as bool,
      method: json['method'] as String?,
      expiresIn: json['expiresIn'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sent': sent,
      'method': method,
      'expiresIn': expiresIn,
      'email': email,
    };
  }

  @override
  List<Object?> get props => [sent, method, expiresIn, email];
}
