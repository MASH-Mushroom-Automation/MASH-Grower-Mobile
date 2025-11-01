import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';
import '../utils/logger.dart';

/// Secure storage service for managing sensitive data
/// 
/// This service provides a centralized way to store and retrieve
/// sensitive information like JWT tokens, using FlutterSecureStorage.
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  static SecureStorageService get instance => _instance;
  
  SecureStorageService._internal();
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  
  // ========== JWT Token Management ==========
  
  /// Save access token
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: StorageKeys.accessToken, value: token);
      Logger.info('🔐 Access token saved');
    } catch (e) {
      Logger.error('❌ Failed to save access token', e);
      rethrow;
    }
  }
  
  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: StorageKeys.accessToken);
    } catch (e) {
      Logger.error('❌ Failed to read access token', e);
      return null;
    }
  }
  
  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: StorageKeys.refreshToken, value: token);
      Logger.info('🔐 Refresh token saved');
    } catch (e) {
      Logger.error('❌ Failed to save refresh token', e);
      rethrow;
    }
  }
  
  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: StorageKeys.refreshToken);
    } catch (e) {
      Logger.error('❌ Failed to read refresh token', e);
      return null;
    }
  }
  
  /// Save both tokens at once
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        saveAccessToken(accessToken),
        saveRefreshToken(refreshToken),
      ]);
      Logger.info('🔐 Tokens saved successfully');
    } catch (e) {
      Logger.error('❌ Failed to save tokens', e);
      rethrow;
    }
  }
  
  /// Clear all tokens
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: StorageKeys.accessToken),
        _storage.delete(key: StorageKeys.refreshToken),
      ]);
      Logger.info('🗑️ Tokens cleared');
    } catch (e) {
      Logger.error('❌ Failed to clear tokens', e);
      rethrow;
    }
  }
  
  /// Check if user has valid tokens
  Future<bool> hasTokens() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      return accessToken != null && refreshToken != null;
    } catch (e) {
      Logger.error('❌ Failed to check tokens', e);
      return false;
    }
  }
  
  // ========== General Storage Methods ==========
  
  /// Save a string value
  Future<void> saveString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      Logger.info('💾 Value saved for key: $key');
    } catch (e) {
      Logger.error('❌ Failed to save value for key: $key', e);
      rethrow;
    }
  }
  
  /// Get a string value
  Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      Logger.error('❌ Failed to read value for key: $key', e);
      return null;
    }
  }
  
  /// Delete a value
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      Logger.info('🗑️ Value deleted for key: $key');
    } catch (e) {
      Logger.error('❌ Failed to delete value for key: $key', e);
      rethrow;
    }
  }
  
  /// Delete all values
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      Logger.info('🗑️ All secure storage cleared');
    } catch (e) {
      Logger.error('❌ Failed to clear all secure storage', e);
      rethrow;
    }
  }
  
  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      Logger.error('❌ Failed to check if key exists: $key', e);
      return false;
    }
  }
  
  /// Get all keys
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      Logger.error('❌ Failed to read all values', e);
      return {};
    }
  }
}
