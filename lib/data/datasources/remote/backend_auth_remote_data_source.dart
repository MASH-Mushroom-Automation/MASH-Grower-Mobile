import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../../models/api_response_model.dart';
import '../../models/backend_user_model.dart';

/// Backend Authentication Remote Data Source
/// Handles all authentication-related API calls to the Railway backend
class BackendAuthRemoteDataSource {
  final DioClient _dioClient = DioClient();

  /// Register a new user
  /// POST /api/v1/auth/register
  /// Returns: User object and verification details
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      Logger.info('📝 Registering user: $email');

      final response = await _dioClient.dio.post(
        ApiEndpoints.authRegister,
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (apiResponse.success) {
        Logger.info('✅ Registration successful: ${apiResponse.data['message']}');
        return apiResponse.data as Map<String, dynamic>;
      }

      throw Exception(apiResponse.message ?? 'Registration failed');
    } on DioException catch (e) {
      Logger.error('❌ Registration failed', e);
      
      // Handle specific error cases
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Email already exists';
        throw Exception(message);
      } else if (e.response?.statusCode == 429) {
        throw Exception('Too many registration attempts. Please try again later.');
      }
      
      throw Exception('Registration failed. Please check your internet connection and try again.');
    } catch (e) {
      Logger.error('❌ Unexpected registration error', e);
      throw Exception('Registration failed. Please try again.');
    }
  }

  /// Verify email with 6-digit code (PRIMARY METHOD FOR MOBILE)
  /// POST /api/v1/auth/verify-email-code
  /// Returns: User object and JWT tokens (auto-login)
  Future<Map<String, dynamic>> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      Logger.info('✉️ Verifying email code for: $email');

      final response = await _dioClient.dio.post(
        ApiEndpoints.authVerifyEmailCode,
        data: {
          'email': email,
          'code': code,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (apiResponse.success) {
        Logger.info('✅ Email verified successfully');
        return apiResponse.data as Map<String, dynamic>;
      }

      throw Exception(apiResponse.message ?? 'Verification failed');
    } on DioException catch (e) {
      Logger.error('❌ Email verification failed', e);
      
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Invalid verification code';
        throw Exception(message);
      } else if (e.response?.statusCode == 429) {
        throw Exception('Too many verification attempts. Please request a new code.');
      }
      
      throw Exception('Verification failed. Please try again.');
    } catch (e) {
      Logger.error('❌ Unexpected verification error', e);
      throw Exception('Verification failed. Please try again.');
    }
  }

  /// Resend 6-digit verification code
  /// POST /api/v1/auth/resend-verification-code
  Future<Map<String, dynamic>> resendVerificationCode({
    required String email,
  }) async {
    try {
      Logger.info('🔄 Resending verification code to: $email');

      final response = await _dioClient.dio.post(
        ApiEndpoints.authResendVerificationCode,
        data: {'email': email},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (apiResponse.success) {
        Logger.info('✅ Verification code resent');
        return apiResponse.data as Map<String, dynamic>;
      }

      throw Exception(apiResponse.message ?? 'Failed to resend code');
    } on DioException catch (e) {
      Logger.error('❌ Resend verification failed', e);
      
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Cannot resend code yet. Please wait.';
        throw Exception(message);
      } else if (e.response?.statusCode == 429) {
        throw Exception('Too many requests. Please wait a minute and try again.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Failed to send verification code. Please try again later.');
      }
      
      throw Exception('Failed to resend code. Please try again.');
    } catch (e) {
      Logger.error('❌ Unexpected resend error', e);
      throw Exception('Failed to resend code. Please try again.');
    }
  }

  /// Login with email and password
  /// POST /api/v1/auth/login
  /// Returns: JWT tokens and user profile
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('🔑 Logging in user: $email');

      final response = await _dioClient.dio.post(
        ApiEndpoints.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (apiResponse.success) {
        Logger.info('✅ Login successful');
        return apiResponse.data as Map<String, dynamic>;
      }

      throw Exception(apiResponse.message ?? 'Login failed');
    } on DioException catch (e) {
      Logger.error('❌ Login failed', e);
      
      if (e.response?.statusCode == 401) {
        final message = e.response?.data['message'] ?? 'Invalid email or password';
        final action = e.response?.data['action'];
        
        // Check if email not verified
        if (action != null && action.contains('resend-verification')) {
          throw Exception('Email not verified. Please check your email for the verification code.');
        }
        
        throw Exception(message);
      } else if (e.response?.statusCode == 429) {
        throw Exception('Too many login attempts. Please try again later.');
      }
      
      throw Exception('Login failed. Please check your internet connection and try again.');
    } catch (e) {
      Logger.error('❌ Unexpected login error', e);
      throw Exception('Login failed. Please try again.');
    }
  }

  /// Request password reset (sends code to email)
  /// POST /api/v1/auth/forgot-password
  Future<bool> forgotPassword({required String email}) async {
    try {
      Logger.info('📧 Requesting password reset for: $email');

      final response = await _dioClient.dio.post(
        ApiEndpoints.authForgotPassword,
        data: {'email': email},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (apiResponse.success) {
        Logger.info('✅ Password reset email sent');
        return true;
      }

      return false;
    } on DioException catch (e) {
      Logger.error('❌ Password reset request failed', e);
      
      // For security, always return success to prevent email enumeration
      // The backend also returns success even if email doesn't exist
      return true;
    } catch (e) {
      Logger.error('❌ Unexpected password reset error', e);
      // Return true for security
      return true;
    }
  }

  /// Reset password with code
  /// POST /api/v1/auth/reset-password
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      Logger.info('🔐 Resetting password for: $email');

      final response = await _dioClient.dio.post(
        ApiEndpoints.authResetPassword,
        data: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (apiResponse.success) {
        Logger.info('✅ Password reset successful');
        return true;
      }

      throw Exception(apiResponse.message ?? 'Password reset failed');
    } on DioException catch (e) {
      Logger.error('❌ Password reset failed', e);
      
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Invalid reset code or code expired';
        throw Exception(message);
      } else if (e.response?.statusCode == 429) {
        throw Exception('Too many reset attempts. Please try again later.');
      }
      
      throw Exception('Password reset failed. Please try again.');
    } catch (e) {
      Logger.error('❌ Unexpected password reset error', e);
      throw Exception('Password reset failed. Please try again.');
    }
  }

  /// Refresh access token
  /// POST /api/v1/auth/refresh-token
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      Logger.info('🔄 Refreshing access token');

      final response = await _dioClient.dio.post(
        ApiEndpoints.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (apiResponse.success) {
        Logger.info('✅ Token refreshed');
        return apiResponse.data as Map<String, dynamic>;
      }

      throw Exception('Token refresh failed');
    } on DioException catch (e) {
      Logger.error('❌ Token refresh failed', e);
      throw Exception('Session expired. Please login again.');
    } catch (e) {
      Logger.error('❌ Unexpected token refresh error', e);
      throw Exception('Session expired. Please login again.');
    }
  }

  /// Logout user (invalidate tokens)
  /// POST /api/v1/auth/logout
  Future<bool> logout() async {
    try {
      Logger.info('👋 Logging out user');

      await _dioClient.dio.post(ApiEndpoints.authLogout);
      
      Logger.info('✅ Logout successful');
      return true;
    } catch (e) {
      Logger.error('❌ Logout failed', e);
      // Return true anyway for local cleanup
      return true;
    }
  }

  /// Get current user profile
  /// GET /api/v1/auth/me
  Future<BackendUserModel> getCurrentUser() async {
    try {
      Logger.info('👤 Fetching current user profile');

      final response = await _dioClient.dio.get(ApiEndpoints.authMe);

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (apiResponse.success) {
        final user = BackendUserModel.fromJson(apiResponse.data);
        Logger.info('✅ User profile fetched: ${user.displayName}');
        return user;
      }

      throw Exception('Failed to fetch user profile');
    } on DioException catch (e) {
      Logger.error('❌ Failed to fetch user profile', e);
      throw Exception('Failed to fetch user profile. Please try again.');
    } catch (e) {
      Logger.error('❌ Unexpected error fetching user profile', e);
      throw Exception('Failed to fetch user profile. Please try again.');
    }
  }
}
