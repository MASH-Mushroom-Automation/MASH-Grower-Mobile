import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../../models/auth/register_request_model.dart';
import '../../models/auth/register_response_model.dart';
import '../../models/auth/verify_email_request_model.dart';
import '../../models/auth/verify_email_response_model.dart';
import '../../models/auth/login_request_model.dart';
import '../../models/auth/login_response_model.dart';
import '../../models/auth/forgot_password_request_model.dart';
import '../../models/auth/forgot_password_response_model.dart';
import '../../models/auth/reset_password_request_model.dart';
import '../../models/auth/reset_password_response_model.dart';
import '../../models/auth/backend_user_model.dart';

/// Remote data source for authentication operations
/// 
/// This class handles all authentication-related API calls
/// including registration, login, email verification, and password management.
class AuthRemoteDataSource {
  final ApiClient _apiClient;
  
  AuthRemoteDataSource(this._apiClient);
  
  /// Register a new user
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      Logger.info('📝 Registering user: ${request.email}');
      
      final response = await _apiClient.post(
        ApiEndpoints.authRegister,
        data: request.toJson(),
      );
      
      Logger.info('✅ Registration successful');
      return RegisterResponseModel.fromJson(response.data);
    } catch (e) {
      Logger.error('❌ Registration failed', e);
      rethrow;
    }
  }
  
  /// Verify user email with code
  Future<VerifyEmailResponseModel> verifyEmail(VerifyEmailRequestModel request) async {
    try {
      Logger.info('📧 Verifying email: ${request.email}');
      
      final response = await _apiClient.post(
        ApiEndpoints.authVerifyEmail,
        data: request.toJson(),
      );
      
      Logger.info('✅ Email verification successful');
      return VerifyEmailResponseModel.fromJson(response.data);
    } catch (e) {
      Logger.error('❌ Email verification failed', e);
      rethrow;
    }
  }
  
  /// Resend verification code
  Future<Map<String, dynamic>> resendVerification(String email) async {
    try {
      Logger.info('📧 Resending verification code to: $email');
      
      final response = await _apiClient.post(
        ApiEndpoints.authResendVerification,
        data: {'email': email.toLowerCase().trim()},
      );
      
      Logger.info('✅ Verification code resent');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      Logger.error('❌ Failed to resend verification code', e);
      rethrow;
    }
  }
  
  /// Login user
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      Logger.info('🔐 Logging in user: ${request.email}');
      print('🔐 Logging in user: ${request.email}');
      
      Logger.info('🌐 Login endpoint: ${ApiEndpoints.authLogin}');
      print('🌐 Login endpoint: ${ApiEndpoints.authLogin}');
      
      Logger.info('📤 Login request data: ${request.toJson()}');
      print('📤 Login request data: ${request.toJson()}');
      
      final response = await _apiClient.post(
        ApiEndpoints.authLogin,
        data: request.toJson(),
      );
      
      // Log the actual response for debugging
      Logger.info('📦 Login API Response: ${response.data}');
      print('📦 Login API Response: ${response.data}');
      Logger.info('✅ Login API call successful');
      
      // Extract the actual data from the wrapped response
      final responseData = response.data;
      final loginData = responseData['data'] ?? responseData;
      
      Logger.info('📦 Extracted login data: $loginData');
      print('📦 Extracted login data: $loginData');
      
      return LoginResponseModel.fromJson(loginData);
    } catch (e, stackTrace) {
      Logger.error('❌ Login failed', e);
      print('❌ Login failed: $e');
      Logger.error('Error type: ${e.runtimeType}');
      print('Error type: ${e.runtimeType}');
      Logger.error('Error details: $e');
      print('Error details: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    try {
      Logger.info('🚪 Logging out user');
      
      await _apiClient.post(ApiEndpoints.authLogout);
      
      Logger.info('✅ Logout successful');
    } catch (e) {
      Logger.error('❌ Logout failed', e);
      // Don't rethrow - logout should succeed even if API call fails
    }
  }
  
  /// Refresh access token
  Future<Map<String, String>> refreshToken(String refreshToken) async {
    try {
      Logger.info('🔄 Refreshing access token');
      
      final response = await _apiClient.post(
        ApiEndpoints.authRefresh,
        data: {'refreshToken': refreshToken},
      );
      
      Logger.info('✅ Token refresh successful');
      
      final data = response.data as Map<String, dynamic>;
      return {
        'accessToken': data['accessToken'] as String,
        'refreshToken': data['refreshToken'] as String,
      };
    } catch (e) {
      Logger.error('❌ Token refresh failed', e);
      rethrow;
    }
  }
  
  /// Verify token validity
  Future<bool> verifyToken() async {
    try {
      Logger.info('🔍 Verifying token');
      
      final response = await _apiClient.get(ApiEndpoints.authVerify);
      
      Logger.info('✅ Token is valid');
      return response.data['valid'] as bool? ?? false;
    } catch (e) {
      Logger.error('❌ Token verification failed', e);
      return false;
    }
  }
  
  /// Get current user information
  Future<BackendUserModel> getCurrentUser() async {
    try {
      Logger.info('👤 Fetching current user');
      
      final response = await _apiClient.get(ApiEndpoints.authMe);
      
      Logger.info('✅ User fetched successfully');
      return BackendUserModel.fromJson(response.data['user'] as Map<String, dynamic>);
    } catch (e) {
      Logger.error('❌ Failed to fetch user', e);
      rethrow;
    }
  }
  
  /// Request password reset code
  Future<ForgotPasswordResponseModel> forgotPassword(ForgotPasswordRequestModel request) async {
    try {
      Logger.info('🔑 Requesting password reset for: ${request.email}');
      
      final response = await _apiClient.post(
        ApiEndpoints.authForgotPassword,
        data: request.toJson(),
      );
      
      Logger.info('✅ Password reset code sent');
      return ForgotPasswordResponseModel.fromJson(response.data);
    } catch (e) {
      Logger.error('❌ Failed to request password reset', e);
      rethrow;
    }
  }
  
  /// Reset password with code
  Future<ResetPasswordResponseModel> resetPassword(ResetPasswordRequestModel request) async {
    try {
      Logger.info('🔐 Resetting password for: ${request.email}');
      
      final response = await _apiClient.post(
        ApiEndpoints.authResetPassword,
        data: request.toJson(),
      );
      
      Logger.info('✅ Password reset reset successful');
      return ResetPasswordResponseModel.fromJson(response.data);
    } catch (e) {
      Logger.error('❌ Password reset failed', e);
      rethrow;
    }
  }
}
