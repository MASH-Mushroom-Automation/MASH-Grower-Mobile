import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/utils/logger.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/validators.dart';
import '../../data/models/user_model.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/local/auth_local_datasource.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final AuthRemoteDataSource _authRemoteDataSource = AuthRemoteDataSource();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();

  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  AuthProvider() {
    _initializeAuth();
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

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Normalize email to lowercase
      final normalizedEmail = Validators.normalizeEmail(email);

      // Check if email is registered
      final sessionService = SessionService();
      await sessionService.initialize();

      final isRegistered = await sessionService.isEmailRegistered(normalizedEmail);
      if (!isRegistered) {
        _setError('Email not registered. Please register first.');
        return false;
      }

      Logger.info('🔓 Login attempt for registered email: $normalizedEmail');

      // Load account data for this email
      final accountData = await sessionService.getAccountData(normalizedEmail);
      if (accountData == null) {
        _setError('Account data not found. Please register again.');
        return false;
      }

      // Create user from account data
      _user = UserModel(
        id: 'user-${accountData.email}',
        email: accountData.email,
        firstName: accountData.firstName,
        lastName: accountData.lastName,
        profileImageUrl: accountData.profileImagePath,
        role: 'grower',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Store mock tokens
      await _secureStorage.write(key: StorageKeys.accessToken, value: 'demo-access-token');
      await _secureStorage.write(key: StorageKeys.refreshToken, value: 'demo-refresh-token');

      // Load session data
      await sessionService.createSessionFromLogin(
        email: normalizedEmail,
        username: accountData.username,
      );

      _isAuthenticated = true;
      Logger.authLogin('Registered User Login - $normalizedEmail');
      return true;

    } catch (e) {
      Logger.error('Email sign in failed: $e');
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
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

  Future<void> signOut() async {
    _setLoading(true);
    try {
      // Sign out from Firebase
      await _firebaseAuth.signOut();
      
      // Clear stored tokens
      await _secureStorage.delete(key: StorageKeys.accessToken);
      await _secureStorage.delete(key: StorageKeys.refreshToken);
      await _secureStorage.delete(key: StorageKeys.userData);
      
      // Clear session data
      final sessionService = SessionService();
      await sessionService.clearSession();
      
      // Clear local data
      await _authLocalDataSource.clearUserData();
      
      _user = null;
      _isAuthenticated = false;
      _clearError();
      
      Logger.authLogout();
    } catch (e) {
      Logger.error('Sign out failed: $e');
      _setError('Failed to sign out');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _exchangeFirebaseToken() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return;

      final token = await firebaseUser.getIdToken();
      if (token == null) {
        _setError('Failed to get authentication token');
        return;
      }
      final userData = await _authRemoteDataSource.exchangeToken(token);
      
      // Store tokens
      await _secureStorage.write(key: StorageKeys.accessToken, value: userData['access_token']);
      await _secureStorage.write(key: StorageKeys.refreshToken, value: userData['refresh_token']);
      
      // Store user data
      final user = UserModel.fromJson(userData['user']);
      await _authLocalDataSource.saveUser(user);
      _user = user;
      _isAuthenticated = true;
      
    } catch (e) {
      Logger.error('Token exchange failed: $e');
      _setError('Authentication failed');
    }
  }

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

  Future<void> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);
      if (refreshToken == null) {
        await signOut();
        return;
      }

      final newTokens = await _authRemoteDataSource.refreshToken(refreshToken);
      await _secureStorage.write(key: StorageKeys.accessToken, value: newTokens['access_token']);
      await _secureStorage.write(key: StorageKeys.refreshToken, value: newTokens['refresh_token']);
      
      Logger.authTokenRefresh();
    } catch (e) {
      Logger.error('Token refresh failed: $e');
      await signOut();
    }
  }

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
