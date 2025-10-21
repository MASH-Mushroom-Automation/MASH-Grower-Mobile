import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/utils/logger.dart';
import '../../core/services/session_service.dart';
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
      // BYPASS: Accept any credentials for demo purposes
      Logger.info('🔓 BYPASS: Accepting any credentials for demo - Email: $email');
      
      // Create a mock user with the provided email
      _user = UserModel(
        id: 'demo-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        firstName: 'Demo',
        lastName: 'User',
        profileImageUrl: null,
        role: 'grower',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Store mock tokens
      await _secureStorage.write(key: StorageKeys.accessToken, value: 'demo-access-token');
      await _secureStorage.write(key: StorageKeys.refreshToken, value: 'demo-refresh-token');
      
      // Save session data
      final sessionService = SessionService();
      await sessionService.createSessionFromLogin(
        email: email,
        username: email.split('@')[0],
      );
      
      _isAuthenticated = true;
      Logger.authLogin('Demo Authentication - Any credentials accepted');
      return true;
      
    } catch (e) {
      Logger.error('Email sign in failed: $e');
      _setError('Invalid email or password');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmail(String email, String password, String firstName, String lastName) async {
    _setLoading(true);
    _clearError();

    try {
      // Create Firebase user
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update Firebase user profile
        await credential.user!.updateDisplayName('$firstName $lastName');
        
        // Exchange Firebase token for backend JWT
        await _exchangeFirebaseToken();
        Logger.authLogin('Email/Password (new user)');
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Email sign up failed: $e');
      _setError('Failed to create account');
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
