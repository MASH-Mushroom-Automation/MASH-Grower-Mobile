// Web-specific database helper using IndexedDB via shared_preferences
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../core/config/app_config.dart';
import '../../../core/utils/logger.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  SharedPreferences? _prefs;

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  Future<SharedPreferences> get database async {
    _prefs ??= await _initDatabase();
    return _prefs!;
  }

  Future<SharedPreferences> _initDatabase() async {
    Logger.info('🗄️ Initializing web storage for web platform');
    
    final prefs = await SharedPreferences.getInstance();
    await _createTables();
    return prefs;
  }

  Future<void> _createTables() async {
    // For web, we'll use SharedPreferences keys to simulate database tables
    Logger.info('🗄️ Creating web storage structure');
    
    // Initialize empty collections if they don't exist
    final prefs = await SharedPreferences.getInstance();
    
    if (!prefs.containsKey('users')) {
      await prefs.setString('users', jsonEncode([]));
    }
    if (!prefs.containsKey('devices')) {
      await prefs.setString('devices', jsonEncode([]));
    }
    if (!prefs.containsKey('sensor_readings')) {
      await prefs.setString('sensor_readings', jsonEncode([]));
    }
    if (!prefs.containsKey('alerts')) {
      await prefs.setString('alerts', jsonEncode([]));
    }
    if (!prefs.containsKey('notifications')) {
      await prefs.setString('notifications', jsonEncode([]));
    }
    if (!prefs.containsKey('sync_queue')) {
      await prefs.setString('sync_queue', jsonEncode([]));
    }
    
    Logger.info('🗄️ Web storage structure created successfully');
  }

  // Web-specific data operations using SharedPreferences
  Future<List<Map<String, dynamic>>> getUsers() async {
    final prefs = await database;
    final usersJson = prefs.getString('users') ?? '[]';
    return List<Map<String, dynamic>>.from(jsonDecode(usersJson));
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await database;
    final users = await getUsers();
    users.add(user);
    await prefs.setString('users', jsonEncode(users));
  }

  Future<List<Map<String, dynamic>>> getDevices() async {
    final prefs = await database;
    final devicesJson = prefs.getString('devices') ?? '[]';
    return List<Map<String, dynamic>>.from(jsonDecode(devicesJson));
  }

  Future<void> saveDevice(Map<String, dynamic> device) async {
    final prefs = await database;
    final devices = await getDevices();
    devices.add(device);
    await prefs.setString('devices', jsonEncode(devices));
  }

  Future<List<Map<String, dynamic>>> getSensorReadings() async {
    final prefs = await database;
    final readingsJson = prefs.getString('sensor_readings') ?? '[]';
    return List<Map<String, dynamic>>.from(jsonDecode(readingsJson));
  }

  Future<void> saveSensorReading(Map<String, dynamic> reading) async {
    final prefs = await database;
    final readings = await getSensorReadings();
    readings.add(reading);
    await prefs.setString('sensor_readings', jsonEncode(readings));
  }

  // Get database size (web-specific implementation)
  Future<int> getDatabaseSize() async {
    // For web, we can't easily get file size, return 0
    return 0;
  }

  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await database;
    await prefs.setString('users', jsonEncode([]));
    await prefs.setString('devices', jsonEncode([]));
    await prefs.setString('sensor_readings', jsonEncode([]));
    await prefs.setString('alerts', jsonEncode([]));
    await prefs.setString('notifications', jsonEncode([]));
    await prefs.setString('sync_queue', jsonEncode([]));
    Logger.info('🗄️ All data cleared');
  }

  // Close database (no-op for web)
  Future<void> close() async {
    // No-op for web platform
    Logger.info('🗄️ Web storage cleanup completed');
  }
}
