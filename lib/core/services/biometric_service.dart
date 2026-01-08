import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';
import '../utils/logger.dart';

/// Service for handling biometric authentication
/// Supports fingerprint, face ID, and iris scanning
class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    if (kIsWeb) return false;
    
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      Logger.error('Failed to check device support: $e');
      return false;
    }
  }

  /// Check if biometric authentication is available on device
  Future<bool> canCheckBiometrics() async {
    if (kIsWeb) return false;
    
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      Logger.error('Failed to check biometrics: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) return [];
    
    try {
      final types = await _localAuth.getAvailableBiometrics();
      Logger.info('Available biometrics: $types');
      return types;
    } catch (e) {
      Logger.error('Failed to get available biometrics: $e');
      return [];
    }
  }

  /// Check if user has enabled biometric login
  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: StorageKeys.biometricEnabled);
      return enabled == 'true';
    } catch (e) {
      Logger.error('Failed to check biometric enabled status: $e');
      return false;
    }
  }

  /// Enable biometric authentication for quick login
  /// Requires user to authenticate first
  /// Optionally stores credentials for auto-login
  Future<bool> enableBiometricAuth({
    String reason = 'Enable biometric authentication for quick access',
    String? email,
    String? password,
  }) async {
    if (kIsWeb) {
      Logger.info('Biometric auth not supported on web');
      return false;
    }
    
    try {
      final isAvailable = await canCheckBiometrics();
      if (!isAvailable) {
        Logger.info('Biometric authentication not available');
        return false;
      }

      final isAuthenticated = await authenticate(reason: reason);

      if (isAuthenticated) {
        await _secureStorage.write(key: StorageKeys.biometricEnabled, value: 'true');
        
        // Store credentials if provided
        if (email != null && password != null) {
          await storeBiometricCredentials(email, password);
        }
        
        Logger.info('Biometric authentication enabled');
        return true;
      }
      
      return false;
    } catch (e) {
      Logger.error('Failed to enable biometric auth: $e');
      return false;
    }
  }

  /// Store credentials for biometric login
  Future<void> storeBiometricCredentials(String email, String password) async {
    try {
      // Store as colon-separated string for easy retrieval
      final credentials = '$email:$password';
      await _secureStorage.write(key: StorageKeys.biometricCredentials, value: credentials);
      Logger.info('Biometric credentials stored securely');
    } catch (e) {
      Logger.error('Failed to store biometric credentials: $e');
    }
  }

  /// Retrieve stored credentials after successful biometric authentication
  Future<Map<String, String>?> retrieveBiometricCredentials() async {
    try {
      final credentials = await _secureStorage.read(key: StorageKeys.biometricCredentials);
      if (credentials == null) return null;
      
      // Parse stored credentials
      final parts = credentials.split(':');
      if (parts.length == 2) {
        return {'email': parts[0], 'password': parts[1]};
      }
      return null;
    } catch (e) {
      Logger.error('Failed to retrieve biometric credentials: $e');
      return null;
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometricAuth() async {
    try {
      await _secureStorage.delete(key: StorageKeys.biometricEnabled);
      await _secureStorage.delete(key: StorageKeys.biometricCredentials);
      Logger.info('Biometric authentication disabled and credentials cleared');
    } catch (e) {
      Logger.error('Failed to disable biometric auth: $e');
    }
  }

  /// Authenticate user with biometrics
  Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    bool biometricOnly = true,
    bool stickyAuth = true,
  }) async {
    if (kIsWeb) {
      Logger.info('Biometric auth not supported on web');
      return false;
    }
    
    try {
      final isAvailable = await canCheckBiometrics();
      if (!isAvailable) {
        Logger.info('Biometric authentication not available');
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: stickyAuth,
        ),
      );

      if (isAuthenticated) {
        Logger.info('Biometric authentication successful');
      }
      
      return isAuthenticated;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        Logger.error('Biometric authentication not available: ${e.message}');
      } else if (e.code == 'NotEnrolled') {
        Logger.error('No biometrics enrolled: ${e.message}');
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        Logger.error('Biometric authentication locked: ${e.message}');
      } else {
        Logger.error('Biometric authentication error: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      Logger.error('Biometric authentication failed: $e');
      return false;
    }
  }

  /// Get user-friendly description of available biometrics
  Future<String> getBiometricDescription() async {
    if (kIsWeb) return 'Not available on web';
    
    try {
      final biometrics = await getAvailableBiometrics();
      
      if (biometrics.isEmpty) {
        return 'No biometric authentication available';
      }
      
      if (biometrics.contains(BiometricType.face)) {
        return 'Face ID';
      }
      
      if (biometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      }
      
      if (biometrics.contains(BiometricType.iris)) {
        return 'Iris scan';
      }
      
      if (biometrics.contains(BiometricType.strong)) {
        return 'Biometric authentication';
      }
      
      return 'Biometric authentication';
    } catch (e) {
      Logger.error('Failed to get biometric description: $e');
      return 'Biometric authentication';
    }
  }

  /// Check if device has any biometric hardware
  Future<bool> hasBiometricHardware() async {
    if (kIsWeb) return false;
    
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) return false;
      
      final biometrics = await getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      Logger.error('Failed to check biometric hardware: $e');
      return false;
    }
  }
}
