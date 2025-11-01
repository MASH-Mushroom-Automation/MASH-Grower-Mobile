/// Base class for all API exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends ApiException {
  NetworkException(super.message, {super.statusCode, super.data});
}

/// Authentication-related exceptions
class AuthException extends ApiException {
  AuthException(super.message, {super.statusCode, super.data});
}

/// Validation-related exceptions
class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;
  
  ValidationException(super.message, {super.statusCode, super.data, this.errors});
}

/// Server-related exceptions
class ServerException extends ApiException {
  ServerException(super.message, {super.statusCode, super.data});
}

/// Rate limiting exceptions
class RateLimitException extends ApiException {
  final DateTime? retryAfter;
  
  RateLimitException(super.message, {super.statusCode, super.data, this.retryAfter});
}

/// Resource not found exceptions
class NotFoundException extends ApiException {
  NotFoundException(super.message, {super.statusCode, super.data});
}

/// Permission-related exceptions
class ForbiddenException extends ApiException {
  ForbiddenException(super.message, {super.statusCode, super.data});
}

/// Timeout exceptions
class TimeoutException extends ApiException {
  TimeoutException(super.message, {super.statusCode, super.data});
}

/// Bad request exceptions
class BadRequestException extends ApiException {
  BadRequestException(super.message, {super.statusCode, super.data});
}

/// Conflict exceptions (e.g., duplicate email)
class ConflictException extends ApiException {
  ConflictException(super.message, {super.statusCode, super.data});
}

/// Unauthorized exceptions (401)
class UnauthorizedException extends AuthException {
  UnauthorizedException(super.message, {super.statusCode, super.data});
}

/// Token expired exceptions
class TokenExpiredException extends AuthException {
  TokenExpiredException(super.message, {super.statusCode, super.data});
}
