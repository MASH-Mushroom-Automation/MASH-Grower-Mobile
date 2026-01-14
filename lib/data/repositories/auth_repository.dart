import '../datasources/remote/auth_remote_datasource.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/utils/logger.dart';
import '../models/auth/register_request_model.dart';
import '../models/auth/register_response_model.dart';
import '../models/auth/verify_email_request_model.dart';
import '../models/auth/verify_email_response_model.dart';
import '../models/auth/login_request_model.dart';
import '../models/auth/login_response_model.dart';
import '../models/auth/forgot_password_request_model.dart';
import '../models/auth/forgot_password_response_model.dart';
import '../models/auth/reset_password_request_model.dart';
import '../models/auth/reset_password_response_model.dart';
import '../models/auth/oauth_request_model.dart';
import '../models/auth/oauth_response_model.dart';
import '../models/auth/backend_user_model.dart';

/// Authentication repository
/// 
/// This repository handles authentication business logic and coordinates
/// between remote data sources and local storage.
class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;
  
  AuthRepository(this._remoteDataSource, this._secureStorage);
  
  // ========== Registration Flow ==========
  
  /// Register a new user
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _remoteDataSource.register(request);
      return response;
    } catch (e) {
      Logger.error('Repository: Registration failed', e);
      rethrow;
    }
  }
  
  /// Verify email with code
  Future<VerifyEmailResponseModel> verifyEmail(VerifyEmailRequestModel request) async {
    try {
      final response = await _remoteDataSource.verifyEmail(request);
      
      // Save tokens if provided
      if (response.accessToken != null && response.refreshToken != null) {
        await _secureStorage.saveTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );
      }
      
      return response;
    } catch (e) {
      Logger.error('Repository: Email verification failed', e);
      rethrow;
    }
  }
  
  /// Resend verification code
  Future<String> resendVerification(String email) async {
    try {
      final response = await _remoteDataSource.resendVerification(email);
      return response['message'] as String? ?? 'Verification code sent';
    } catch (e) {
      Logger.error('Repository: Failed to resend verification', e);
      rethrow;
    }
  }
  
  // ========== Login/Logout Flow ==========
  
  /// Login user
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _remoteDataSource.login(request);
      
      // Save tokens
      await _secureStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      
      return response;
    } catch (e) {
      Logger.error('Repository: Login failed', e);
      rethrow;
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    try {
      // Call API to logout
      await _remoteDataSource.logout();
      
      // Clear local tokens
      await _secureStorage.clearTokens();
      
      Logger.info('✅ Logged out successfully');
    } catch (e) {
      Logger.error('Repository: Logout failed', e);
      // Still clear tokens even if API call fails
      await _secureStorage.clearTokens();
    }
  }
  
  // ========== Token Management ==========
  
  /// Refresh access token
  Future<bool> refreshToken() async {
    try {
      final currentRefreshToken = await _secureStorage.getRefreshToken();
      if (currentRefreshToken == null) {
        Logger.info('❌ No refresh token available');
        return false;
      }
      
      final tokens = await _remoteDataSource.refreshToken(currentRefreshToken);
      
      await _secureStorage.saveTokens(
        accessToken: tokens['accessToken']!,
        refreshToken: tokens['refreshToken']!,
      );
      
      return true;
    } catch (e) {
      Logger.error('Repository: Token refresh failed', e);
      return false;
    }
  }
  
  /// Verify if current token is valid
  Future<bool> verifyToken() async {
    try {
      final hasTokens = await _secureStorage.hasTokens();
      if (!hasTokens) return false;
      
      return await _remoteDataSource.verifyToken();
    } catch (e) {
      Logger.error('Repository: Token verification failed', e);
      return false;
    }
  }
  
  /// Check if user is logged in (has valid tokens)
  Future<bool> isLoggedIn() async {
    return await _secureStorage.hasTokens();
  }
  
  // ========== User Information ==========
  
  /// Get current user
  Future<BackendUserModel> getCurrentUser() async {
    try {
      return await _remoteDataSource.getCurrentUser();
    } catch (e) {
      Logger.error('Repository: Failed to get current user', e);
      rethrow;
    }
  }
  
  // ========== Password Management ==========
  
  /// Request password reset code
  Future<ForgotPasswordResponseModel> forgotPassword(ForgotPasswordRequestModel request) async {
    try {
      return await _remoteDataSource.forgotPassword(request);
    } catch (e) {
      Logger.error('Repository: Forgot password failed', e);
      rethrow;
    }
  }
  
  /// Reset password with code
  Future<ResetPasswordResponseModel> resetPassword(ResetPasswordRequestModel request) async {
    try {
      return await _remoteDataSource.resetPassword(request);
    } catch (e) {
      Logger.error('Repository: Reset password failed', e);
      rethrow;
    }
  }
  
  // ========== OAuth Authentication ==========
  
  /// Authenticate with OAuth provider (Google, Facebook, etc.)
  Future<OAuthResponseModel> oauthLogin(OAuthRequestModel request) async {
    try {
      final response = await _remoteDataSource.oauthLogin(request);
      
      // Save tokens
      await _secureStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      
      return response;
    } catch (e) {
      Logger.error('Repository: OAuth login failed', e);
      rethrow;
    }
  }
  
  // ========== Auto-Login Support ==========
  
  /// Attempt auto-login on app start
  Future<BackendUserModel?> autoLogin() async {
    try {
      // Check if we have tokens
      final hasTokens = await _secureStorage.hasTokens();
      if (!hasTokens) {
        Logger.info('No tokens found for auto-login');
        return null;
      }
      
      // Verify token is still valid
      final isValid = await verifyToken();
      if (!isValid) {
        Logger.info('Token is invalid, attempting refresh...');
        final refreshed = await refreshToken();
        if (!refreshed) {
          Logger.info('Token refresh failed, clearing tokens');
          await _secureStorage.clearTokens();
          return null;
        }
      }
      
      // Get current user
      final user = await getCurrentUser();
      Logger.info('✅ Auto-login successful');
      return user;
    } catch (e) {
      Logger.error('Auto-login failed', e);
      await _secureStorage.clearTokens();
      return null;
    }
  }
}
