import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:flutter/foundation.dart';

// Conditional imports for platform-specific code
import 'package:path_provider/path_provider.dart' if (dart.library.html) 'package:mash_grower_mobile/data/datasources/local/path_provider_stub.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/logger.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(documentsDirectory.path, AppConfig.databaseName);
    
    Logger.info('🗄️ Initializing database at: $dbPath');
    
    return await openDatabase(
      dbPath,
      version: AppConfig.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    Logger.info('🗄️ Creating database tables');
    
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        clerk_user_id TEXT,
        email TEXT NOT NULL,
        first_name TEXT,
        last_name TEXT,
        profile_image_url TEXT,
        role TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    // Devices table
    await db.execute('''
      CREATE TABLE devices (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        name TEXT NOT NULL,
        device_type TEXT,
        status TEXT,
        last_seen INTEGER,
        configuration TEXT,
        created_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Sensor readings table
    await db.execute('''
      CREATE TABLE sensor_readings (
        id TEXT PRIMARY KEY,
        device_id TEXT,
        sensor_type TEXT,
        value REAL,
        quality_indicator TEXT,
        timestamp INTEGER,
        synced INTEGER DEFAULT 0,
        created_at INTEGER,
        FOREIGN KEY (device_id) REFERENCES devices(id)
      )
    ''');

    // Alerts table
    await db.execute('''
      CREATE TABLE alerts (
        id TEXT PRIMARY KEY,
        device_id TEXT,
        alert_type TEXT,
        severity TEXT,
        title TEXT,
        message TEXT,
        acknowledged INTEGER DEFAULT 0,
        resolved INTEGER DEFAULT 0,
        created_at INTEGER,
        FOREIGN KEY (device_id) REFERENCES devices(id)
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        type TEXT,
        title TEXT,
        message TEXT,
        data TEXT,
        read INTEGER DEFAULT 0,
        created_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT,
        entity_id TEXT,
        action TEXT,
        payload TEXT,
        retry_count INTEGER DEFAULT 0,
        created_at INTEGER
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_sensor_readings_device_timestamp ON sensor_readings(device_id, timestamp DESC)');
    await db.execute('CREATE INDEX idx_sensor_readings_timestamp ON sensor_readings(timestamp DESC)');
    await db.execute('CREATE INDEX idx_alerts_device ON alerts(device_id)');
    await db.execute('CREATE INDEX idx_alerts_severity ON alerts(severity)');
    await db.execute('CREATE INDEX idx_notifications_user ON notifications(user_id)');
    await db.execute('CREATE INDEX idx_notifications_read ON notifications(read)');
    await db.execute('CREATE INDEX idx_sync_queue_entity ON sync_queue(entity_type, entity_id)');

    Logger.info('✅ Database tables created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Logger.info('🔄 Upgrading database from version $oldVersion to $newVersion');
    
    // Add migration logic here for future versions
    if (oldVersion < 2) {
      // Example migration for version 2
      // await db.execute('ALTER TABLE users ADD COLUMN new_field TEXT');
    }
  }

  Future<void> _onOpen(Database db) async {
    Logger.info('🗄️ Database opened');
    
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
    
    // Set journal mode to WAL for better performance
    await db.execute('PRAGMA journal_mode = WAL');
    
    // Set synchronous mode to NORMAL for better performance
    await db.execute('PRAGMA synchronous = NORMAL');
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    final id = await db.insert(table, data);
    Logger.databaseResult(1, 'INSERT');
    return id;
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final result = await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    Logger.databaseResult(result.length, 'SELECT');
    return result;
  }

  Future<Map<String, dynamic>?> queryFirst(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final results = await query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    final count = await db.update(table, data, where: where, whereArgs: whereArgs);
    Logger.databaseResult(count, 'UPDATE');
    return count;
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    final count = await db.delete(table, where: where, whereArgs: whereArgs);
    Logger.databaseResult(count, 'DELETE');
    return count;
  }

  // Transaction support
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // Raw query support
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    Logger.databaseQuery(sql, arguments);
    return await db.rawQuery(sql, arguments);
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      Logger.info('🗄️ Database closed');
    }
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('sync_queue');
      await txn.delete('notifications');
      await txn.delete('alerts');
      await txn.delete('sensor_readings');
      await txn.delete('devices');
      await txn.delete('users');
    });
    Logger.info('🗄️ All data cleared');
  }

  // Get database size
  Future<int> getDatabaseSize() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(documentsDirectory.path, AppConfig.databaseName);
    final file = File(dbPath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }
}
