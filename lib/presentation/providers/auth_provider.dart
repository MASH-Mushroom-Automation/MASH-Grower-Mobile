import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/utils/logger.dart';
import '../../core/services/session_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/recent_accounts_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/validators.dart';
import '../../data/models/user_model.dart';
import '../../data/models/auth/backend_user_model.dart';
import '../../data/models/auth/login_request_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/local/auth_local_datasource.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  
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
      // Check if user has valid backend JWT tokens
      final accessToken = await _secureStorage.read(key: StorageKeys.accessToken);
      
      if (accessToken != null && accessToken.isNotEmpty) {
        // Try to load user from storage
        await _loadUserFromStorage();
        if (_user != null) {
          _isAuthenticated = true;
          Logger.info('Restored authenticated session from stored tokens');
        } else {
          // Token exists but no user data, clear tokens
          await _secureStorage.delete(key: StorageKeys.accessToken);
          await _secureStorage.delete(key: StorageKeys.refreshToken);
          Logger.info('Cleared invalid tokens');
        }
      } else {
        // No tokens found, user must authenticate
        Logger.info('No authenticated user found');
      }
    } catch (e) {
      Logger.error('Auth initialization failed: $e');
      _setError('Failed to initialize authentication');
    } finally {
      _setLoading(false);
    }
  }

  /// Backend API Login
  /// 
  /// Authenticates user with backend API and stores JWT tokens
  Future<bool> loginWithBackend(String email, String password, {bool rememberPassword = false}) async {
    _setLoading(true);
    _clearError();

    try {
      // Normalize email to lowercase
      final normalizedEmail = Validators.normalizeEmail(email);

      Logger.info('Backend Login attempt for: $normalizedEmail');
      print('Backend Login attempt for: $normalizedEmail'); // Console print

      // Create login request
      final loginRequest = LoginRequestModel(
        email: normalizedEmail,
        password: password,
      );

      Logger.info('Calling auth repository login...');
      print('Calling auth repository login...'); // Console print
      
      // Call backend API
      final response = await _authRepository.login(loginRequest);

      Logger.info('Got response from auth repository');
      print('Got response from auth repository'); // Console print
      print('Response success: ${response.success}');
      print('Response user: ${response.user}');
      print('Response message: ${response.message}');

      if (response.success && response.user != null) {
        // Store backend user data
        _backendUser = response.user;
        
        // Create user model from backend user
        _user = UserModel(
          id: response.user!.id,
          email: response.user!.email,
          firstName: response.user!.firstName,
          lastName: response.user!.lastName,
          profileImageUrl: response.user!.avatarUrl,
          role: 'grower',
          createdAt: response.user!.createdAt,
          updatedAt: response.user!.updatedAt,
        );

        // JWT tokens are already stored by AuthRepository
        _isAuthenticated = true;
        
        // Save to recent accounts for quick sign-in
        try {
          final recentAccountsService = RecentAccountsService();
          await recentAccountsService.initialize();
          await recentAccountsService.addRecentAccount(
            email: response.user!.email,
            firstName: response.user!.firstName,
            lastName: response.user!.lastName,
            profileImageUrl: response.user!.avatarUrl,
            password: password,
            rememberPassword: rememberPassword,
          );
        } catch (e) {
          Logger.error('Failed to save recent account: $e');
        }
        
        Logger.authLogin('Backend API Login - $normalizedEmail');
        Logger.info('✅ User logged in: ${response.user!.displayName}');
        
        // Set loading to false before notifying listeners
        _isLoading = false;
        
        // Notify listeners to update UI immediately
        notifyListeners();
        
        return true;
      } else {
        _setError(response.message);
        return false;
      }

    } catch (e, stackTrace) {
      Logger.error('❌ Backend login failed', e);
      print('❌ ERROR in loginWithBackend: $e');
      print('Stack trace: $stackTrace');
      
      // Extract user-friendly error message
      String errorMessage = 'Login failed. Please check your credentials.';
      if (e.toString().contains('invalid credentials')) {
        errorMessage = 'Invalid email or password.';
      } else if (e.toString().contains('email not verified')) {
        errorMessage = 'Please verify your email before logging in.';
      } else if (e.toString().contains('account locked')) {
        errorMessage = 'Your account has been locked. Please contact support.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      }
      
      print('Setting error message: $errorMessage');
      _setError(errorMessage);
      _isLoading = false;
      return false;
    }
  }

  /// OLD Firebase-based login (kept for backward compatibility)
  Future<bool> signInWithEmail(String email, String password, {bool rememberPassword = false}) async {
    // Redirect to backend login
    return await loginWithBackend(email, password, rememberPassword: rememberPassword);
  }

  /// DEPRECATED: Old mock registration method
  /// This method is no longer used. Registration now goes through RegistrationProvider.submitRegistration()
  /// which calls the backend API directly.
  Future<bool> signUpWithEmail(String email, String password, String firstName, String lastName) async {
    _setLoading(true);
    _clearError();

    try {
      // Normalize email to lowercase
      final normalizedEmail = Validators.normalizeEmail(email);

      Logger.info('Mock registration (deprecated) for: $normalizedEmail');
      Logger.warning('This method should not be used. Use RegistrationProvider.submitRegistration() instead.');

      // Create user with provided data (mock only)
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
      Logger.authLogin('Mock Registration (Deprecated) - $normalizedEmail');
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
      Logger.info('Google sign-in not implemented');
      _setError('Google Sign-In is not available. Please use email/password login.');
      return false;
      
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
      Logger.info('Logging out user...');
      
      // Try to call backend logout API (may fail due to CORS on web)
      try {
        await _authRepository.logout();
      } catch (e) {
        Logger.error('Backend logout failed (continuing with local cleanup): $e');
        print('Backend logout failed (continuing with local cleanup): $e');
        // Continue with local cleanup even if backend call fails
      }
      
      // Sign out from Firebase (if still using it)
      try {
        await _firebaseAuth.signOut();
      } catch (e) {
        Logger.error('Firebase signOut failed (non-critical)', e);
      }
      
      // Clear stored tokens
      try {
        await _secureStorage.delete(key: StorageKeys.accessToken);
        await _secureStorage.delete(key: StorageKeys.refreshToken);
        await _secureStorage.delete(key: StorageKeys.userData);
      } catch (e) {
        Logger.error('Failed to clear secure storage: $e');
      }
      
      // Clear session data
      try {
        final sessionService = SessionService();
        await sessionService.clearSession();
      } catch (e) {
        Logger.error('Failed to clear session: $e');
      }
      
      // Clear local data
      try {
        await _authLocalDataSource.clearUserData();
      } catch (e) {
        Logger.error('Failed to clear local data: $e');
      }
      
      // Clear state
      _user = null;
      _backendUser = null;
      _isAuthenticated = false;
      _clearError();
      
      Logger.authLogout();
      Logger.info('User logged out successfully');
    } catch (e) {
      Logger.error('Logout failed', e);
      // Don't set error - we still want to clear the user state
      _user = null;
      _backendUser = null;
      _isAuthenticated = false;
      _clearError();
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
