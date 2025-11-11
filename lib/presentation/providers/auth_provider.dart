import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/utils/logger.dart';
import '../../core/services/session_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/validators.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/backend_auth_remote_data_source.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/models/backend_user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  final BackendAuthRemoteDataSource _backendAuthDataSource = BackendAuthRemoteDataSource();
  
  late final AuthRepository _authRepository;
  BackendUserModel? _backendUser;

  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  AuthProvider() {
    _initializeAuthRepository();
    _initializeAuth();
  }
  
  void _initializeAuthRepository() {
    final dioClient = DioClient();
    final apiClient = ApiClient(dioClient);
    final authRemoteDataSource = AuthRemoteDataSource(apiClient);
    final secureStorage = SecureStorageService.instance;
    _authRepository = AuthRepository(authRemoteDataSource, secureStorage);
  }

  Future<void> _initializeAuth() async {
    _setLoading(true);
    try {
      // Check if user is already logged in
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await _loadUserFromStorage();
        if (_user != null) {
          _isAuthenticated = true;
          Logger.authLogin('Firebase (existing session)');
        }
      } else {
        // Check if we have session data from registration
        final sessionService = SessionService();
        await sessionService.initialize();
        final sessionData = await sessionService.getRegistrationData();
        
        if (sessionData != null) {
          Logger.info('🔍 Auth Init - Found session data: $sessionData');
          
          // Create user from session data
          _user = UserModel(
            id: 'session-user-${DateTime.now().millisecondsSinceEpoch}',
            email: sessionData['email'] ?? 'user@example.com',
            firstName: sessionData['firstName'] ?? 'User',
            lastName: sessionData['lastName'] ?? 'Name',
            profileImageUrl: sessionData['profileImagePath'],
            role: 'grower',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          // Store mock tokens
          await _secureStorage.write(key: StorageKeys.accessToken, value: 'session-access-token');
          await _secureStorage.write(key: StorageKeys.refreshToken, value: 'session-refresh-token');
          
          _isAuthenticated = true;
          Logger.authLogin('Session Data (auto-login)');
        }
      }
    } catch (e) {
      Logger.error('Auth initialization failed: $e');
      _setError('Failed to initialize authentication');
    } finally {
      _setLoading(false);
    }
  }

  /// Backend API Login (redirects to direct method)
  /// 
  /// Authenticates user with backend API and stores JWT tokens
  Future<bool> loginWithBackend(String email, String password) async {
    // Use the new direct backend method instead
    return await loginWithBackendDirect(email, password);
  }

  /// OLD Firebase-based login (kept for backward compatibility)
  Future<bool> signInWithEmail(String email, String password) async {
    // Redirect to backend login
    return await loginWithBackend(email, password);
  }

  Future<bool> signUpWithEmail(String email, String password, String firstName, String lastName) async {
    _setLoading(true);
    _clearError();

    try {
      // Normalize email to lowercase
      final normalizedEmail = Validators.normalizeEmail(email);

      // Check if email is already registered
      final sessionService = SessionService();
      await sessionService.initialize();

      final isAlreadyRegistered = await sessionService.isEmailRegistered(normalizedEmail);
      if (isAlreadyRegistered) {
        _setError('Email already registered. Please login instead.');
        return false;
      }

      Logger.info('🔓 Registration attempt for new email: $normalizedEmail');

      // Save registration data
      await sessionService.createSessionFromRegistration(
        email: normalizedEmail,
        prefix: '',
        firstName: firstName,
        middleName: '',
        lastName: lastName,
        suffix: '',
        contactNumber: '',
        countryCode: '+63',
        username: normalizedEmail.split('@')[0],
        region: '',
        province: '',
        city: '',
        barangay: '',
        streetAddress: '',
      );

      // Create user with provided data
      _user = UserModel(
        id: 'user-$normalizedEmail',
        email: normalizedEmail,
        firstName: firstName,
        lastName: lastName,
        profileImageUrl: null,
        role: 'grower',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Store mock tokens
      await _secureStorage.write(key: StorageKeys.accessToken, value: 'demo-access-token');
      await _secureStorage.write(key: StorageKeys.refreshToken, value: 'demo-refresh-token');

      _isAuthenticated = true;
      Logger.authLogin('New User Registration - $normalizedEmail');
      return true;

    } catch (e) {
      Logger.error('Email sign up failed: $e');
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      // BYPASS: Accept Google sign-in for demo purposes
      Logger.info('🔓 BYPASS: Accepting Google sign-in for demo');
      
      // Create a mock user
      _user = UserModel(
        id: 'demo-google-user-${DateTime.now().millisecondsSinceEpoch}',
        email: 'demo@gmail.com',
        firstName: 'Google',
        lastName: 'Demo User',
        profileImageUrl: null,
        role: 'grower',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Store mock tokens
      await _secureStorage.write(key: StorageKeys.accessToken, value: 'demo-google-access-token');
      await _secureStorage.write(key: StorageKeys.refreshToken, value: 'demo-google-refresh-token');
      
      // Save session data
      final sessionService = SessionService();
      await sessionService.createSessionFromLogin(
        email: 'demo@gmail.com',
        username: 'GoogleUser',
      );
      
      _isAuthenticated = true;
      Logger.authLogin('Demo Google Authentication');
      return true;
      
    } catch (e) {
      Logger.error('Google sign in failed: $e');
      _setError('Google Sign-In failed');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    // Skip biometric authentication on web
    if (kIsWeb) {
      _setError('Biometric authentication not available on web');
      return false;
    }
    
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        _setError('Biometric authentication not available');
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        await _loadUserFromStorage();
        if (_user != null) {
          _isAuthenticated = true;
          Logger.authLogin('Biometric');
          return true;
        }
      }
      return false;
    } catch (e) {
      Logger.error('Biometric authentication failed: $e');
      _setError('Biometric authentication failed');
      return false;
    }
  }

  Future<void> enableBiometricAuth() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        _setError('Biometric authentication not available');
        return;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric authentication for quick access',
      );

      if (isAuthenticated) {
        await _secureStorage.write(key: StorageKeys.biometricEnabled, value: 'true');
        Logger.info('Biometric authentication enabled');
      }
    } catch (e) {
      Logger.error('Failed to enable biometric auth: $e');
      _setError('Failed to enable biometric authentication');
    }
  }

  /// Backend API Logout
  /// 
  /// Logs out user and clears JWT tokens
  Future<void> logout() async {
    _setLoading(true);
    try {
      Logger.info('🚪 Logging out user...');
      
      // Call backend logout API
      await _authRepository.logout();
      
      // Sign out from Firebase (if still using it)
      try {
        await _firebaseAuth.signOut();
      } catch (e) {
        Logger.error('Firebase signOut failed (non-critical)', e);
      }
      
      // Clear stored tokens (done by AuthRepository, but double-check)
      await _secureStorage.delete(key: StorageKeys.accessToken);
      await _secureStorage.delete(key: StorageKeys.refreshToken);
      await _secureStorage.delete(key: StorageKeys.userData);
      
      // Clear session data
      final sessionService = SessionService();
      await sessionService.clearSession();
      
      // Clear local data
      await _authLocalDataSource.clearUserData();
      
      // Clear state
      _user = null;
      _backendUser = null;
      _isAuthenticated = false;
      _clearError();
      
      Logger.authLogout();
      Logger.info('✅ User logged out successfully');
    } catch (e) {
      Logger.error('❌ Logout failed', e);
      _setError('Failed to sign out');
    } finally {
      _setLoading(false);
    }
  }

  /// OLD Firebase-based signOut (kept for backward compatibility)
  Future<void> signOut() async {
    // Redirect to backend logout
    await logout();
  }

  // DEPRECATED: Old Firebase token exchange (no longer used with backend API)
  // Future<void> _exchangeFirebaseToken() async {
  //   try {
  //     final firebaseUser = _firebaseAuth.currentUser;
  //     if (firebaseUser == null) return;

  //     final token = await firebaseUser.getIdToken();
  //     if (token == null) {
  //       _setError('Failed to get authentication token');
  //       return;
  //     }
  //     // OLD: final userData = await _authRemoteDataSource.exchangeToken(token);
  //     
  //     // Store tokens
  //     // await _secureStorage.write(key: StorageKeys.accessToken, value: userData['access_token']);
  //     // await _secureStorage.write(key: StorageKeys.refreshToken, value: userData['refresh_token']);
  //     
  //     // Store user data
  //     // final user = UserModel.fromJson(userData['user']);
  //     // await _authLocalDataSource.saveUser(user);
  //     // _user = user;
  //     // _isAuthenticated = true;
  //     
  //   } catch (e) {
  //     Logger.error('Token exchange failed: $e');
  //     _setError('Authentication failed');
  //   }
  // }

  Future<void> _loadUserFromStorage() async {
    try {
      final userData = await _authLocalDataSource.getUser();
      if (userData != null) {
        _user = userData;
        _isAuthenticated = true;
      }
    } catch (e) {
      Logger.error('Failed to load user from storage: $e');
    }
  }

  // DEPRECATED: Old manual token refresh (now handled by DioClient interceptor)
  // Future<void> refreshToken() async {
  //   try {
  //     final refreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);
  //     if (refreshToken == null) {
  //       await signOut();
  //       return;
  //     }

  //     // OLD: final newTokens = await _authRemoteDataSource.refreshToken(refreshToken);
  //     // await _secureStorage.write(key: StorageKeys.accessToken, value: newTokens['access_token']);
  //     // await _secureStorage.write(key: StorageKeys.refreshToken, value: newTokens['refresh_token']);
  //     
  //     // Logger.authTokenRefresh();
  //   } catch (e) {
  //     Logger.error('Token refresh failed: $e');
  //     await signOut();
  //   }
  // }

  // ==================== NEW BACKEND DIRECT METHODS ====================
  
  /// Direct backend login (bypasses old repository pattern)
  Future<bool> loginWithBackendDirect(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      Logger.info('🔐 Direct backend login attempt: $email');
      
      // Call backend API directly - returns Map<String, dynamic>
      final response = await _backendAuthDataSource.login(
        email: email,
        password: password,
      );
      
      // Parse response data
      final user = BackendUserModel.fromJson(response['user']);
      final accessToken = response['tokens']['accessToken'] as String;
      final refreshToken = response['tokens']['refreshToken'] as String;
      
      // Store JWT tokens in secure storage
      await _secureStorage.write(
        key: StorageKeys.accessToken,
        value: accessToken,
      );
      await _secureStorage.write(
        key: StorageKeys.refreshToken,
        value: refreshToken,
      );
      
      // Store backend user
      _backendUser = user;
      
      // Convert to UserModel for backward compatibility
      _user = UserModel(
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        profileImageUrl: user.avatarUrl,
        role: user.role,
        createdAt: DateTime.parse(user.createdAt),
        updatedAt: user.updatedAt != null ? DateTime.parse(user.updatedAt!) : null,
      );
      
      // Save user locally
      await _authLocalDataSource.saveUser(_user!);
      
      _isAuthenticated = true;
      Logger.info('✅ Direct backend login successful: ${user.displayName}');
      return true;

    } catch (e) {
      Logger.error('❌ Direct backend login failed', e);
      
      // Extract user-friendly error message
      String errorMessage = 'Login failed. Please check your credentials.';
      if (e.toString().contains('invalid credentials') || e.toString().contains('Invalid email or password')) {
        errorMessage = 'Invalid email or password.';
      } else if (e.toString().contains('email not verified') || e.toString().contains('Email not verified')) {
        errorMessage = 'Please verify your email before logging in.';
      } else if (e.toString().contains('account locked')) {
        errorMessage = 'Your account has been locked. Please contact support.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection.';
      }
      
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Request password reset code (sends 6-digit code to email)
  Future<bool> forgotPasswordWithBackend(String email) async {
    _setLoading(true);
    _clearError();

    try {
      Logger.info('📧 Requesting password reset for: $email');
      
      // Returns bool (always true for security)
      final success = await _backendAuthDataSource.forgotPassword(email: email);
      
      if (success) {
        Logger.info('✅ Password reset code sent to: $email');
        return true;
      } else {
        _setError('Failed to send reset code. Please try again.');
        return false;
      }

    } catch (e) {
      Logger.error('❌ Forgot password failed', e);
      
      String errorMessage = 'Failed to send reset code. Please try again.';
      if (e.toString().contains('User not found')) {
        errorMessage = 'No account found with this email.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection.';
      }
      
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password with verification code
  Future<bool> resetPasswordWithBackend(String email, String code, String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      Logger.info('🔒 Resetting password for: $email');
      
      // Returns bool
      final success = await _backendAuthDataSource.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      
      if (success) {
        Logger.info('✅ Password reset successful for: $email');
        return true;
      } else {
        _setError('Failed to reset password. Please try again.');
        return false;
      }

    } catch (e) {
      Logger.error('❌ Password reset failed', e);
      
      String errorMessage = 'Failed to reset password. Please try again.';
      if (e.toString().contains('Invalid or expired')) {
        errorMessage = 'Invalid or expired reset code. Please request a new one.';
      } else if (e.toString().contains('User not found')) {
        errorMessage = 'No account found with this email.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection.';
      }
      
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get current user profile from backend
  Future<BackendUserModel?> getCurrentUserFromBackend() async {
    try {
      Logger.info('👤 Fetching current user from backend');
      
      // Returns BackendUserModel?
      final user = await _backendAuthDataSource.getCurrentUser();
      
      _backendUser = user;
      
      // Update local UserModel
      _user = UserModel(
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        profileImageUrl: user.avatarUrl,
        role: user.role,
        createdAt: DateTime.parse(user.createdAt),
        updatedAt: user.updatedAt != null ? DateTime.parse(user.updatedAt!) : null,
      );
      
      await _authLocalDataSource.saveUser(_user!);
      notifyListeners();
      
      Logger.info('✅ User profile updated: ${user.displayName}');
      
      return user;
    } catch (e) {
      Logger.error('❌ Failed to get current user', e);
      return null;
    }
  }

  // ==================== HELPER METHODS ====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
