import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/utils/logger.dart';
import '../../models/user_model.dart';
import '../local/database_helper.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> saveUser(UserModel user) async {
    try {
      // Save to secure storage
      await _secureStorage.write(key: StorageKeys.userData, value: user.toJson().toString());
      
      // Save to database
      await _databaseHelper.insert('users', user.toDatabase());
      
      Logger.info('User data saved locally');
    } catch (e) {
      Logger.error('Failed to save user data: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUser() async {
    try {
      // Try to get from database first
      final userData = await _databaseHelper.queryFirst('users');
      if (userData != null) {
        return UserModel.fromDatabase(userData);
      }
      
      // Fallback to secure storage
      final userJson = await _secureStorage.read(key: StorageKeys.userData);
      if (userJson != null) {
        // Parse JSON string back to Map
        final userMap = Map<String, dynamic>.from(userJson as Map);
        return UserModel.fromJson(userMap);
      }
      
      return null;
    } catch (e) {
      Logger.error('Failed to get user data: $e');
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      // Update in secure storage
      await _secureStorage.write(key: StorageKeys.userData, value: user.toJson().toString());
      
      // Update in database
      await _databaseHelper.update(
        'users',
        user.toDatabase(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      
      Logger.info('User data updated locally');
    } catch (e) {
      Logger.error('Failed to update user data: $e');
      rethrow;
    }
  }

  Future<void> clearUserData() async {
    try {
      // Clear from secure storage
      await _secureStorage.delete(key: StorageKeys.userData);
      
      // Clear from database
      await _databaseHelper.delete('users');
      
      Logger.info('User data cleared locally');
    } catch (e) {
      Logger.error('Failed to clear user data: $e');
      rethrow;
    }
  }

  Future<bool> hasUser() async {
    try {
      final user = await getUser();
      return user != null;
    } catch (e) {
      Logger.error('Failed to check if user exists: $e');
      return false;
    }
  }
}
