import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Service to manage recently logged-in accounts for quick sign-in
/// Similar to Facebook's "Recently Logged In" feature
class RecentAccountsService {
  static final RecentAccountsService _instance = RecentAccountsService._internal();
  factory RecentAccountsService() => _instance;
  RecentAccountsService._internal();

  SharedPreferences? _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _recentAccountsKey = 'recent_accounts';
  static const int _maxRecentAccounts = 3; // Maximum 3 recent accounts
  static const String _passwordPrefix = 'saved_password_'; // Prefix for saved passwords

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get list of recent accounts
  Future<List<RecentAccount>> getRecentAccounts() async {
    final accountsJson = _prefs?.getString(_recentAccountsKey);
    if (accountsJson != null) {
      try {
        final List<dynamic> accountsList = jsonDecode(accountsJson);
        return accountsList
            .map((json) => RecentAccount.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error loading recent accounts: $e');
        return [];
      }
    }
    return [];
  }

  /// Add or update a recent account
  Future<void> addRecentAccount({
    required String email,
    required String firstName,
    required String lastName,
    String? profileImageUrl,
    String? password,
    bool rememberPassword = false,
  }) async {
    final accounts = await getRecentAccounts();
    
    // Remove if already exists
    accounts.removeWhere((account) => account.email == email);
    
    // Save password securely if rememberPassword is true
    if (rememberPassword && password != null) {
      await _secureStorage.write(
        key: '$_passwordPrefix$email',
        value: password,
      );
    } else {
      // Clear saved password if not remembering
      await _secureStorage.delete(key: '$_passwordPrefix$email');
    }
    
    // Add to front
    accounts.insert(0, RecentAccount(
      email: email,
      firstName: firstName,
      lastName: lastName,
      profileImageUrl: profileImageUrl,
      lastLoginAt: DateTime.now(),
      hasPasswordSaved: rememberPassword,
    ));
    
    // Keep only max accounts
    if (accounts.length > _maxRecentAccounts) {
      accounts.removeRange(_maxRecentAccounts, accounts.length);
    }
    
    // Save
    final accountsJson = jsonEncode(accounts.map((a) => a.toJson()).toList());
    await _prefs?.setString(_recentAccountsKey, accountsJson);
  }

  /// Remove a recent account
  Future<void> removeRecentAccount(String email) async {
    final accounts = await getRecentAccounts();
    accounts.removeWhere((account) => account.email == email);
    
    // Also remove saved password
    await _secureStorage.delete(key: '$_passwordPrefix$email');
    
    final accountsJson = jsonEncode(accounts.map((a) => a.toJson()).toList());
    await _prefs?.setString(_recentAccountsKey, accountsJson);
  }

  /// Clear all recent accounts
  Future<void> clearRecentAccounts() async {
    // Get all accounts to clear their passwords
    final accounts = await getRecentAccounts();
    for (final account in accounts) {
      await _secureStorage.delete(key: '$_passwordPrefix${account.email}');
    }
    
    await _prefs?.remove(_recentAccountsKey);
  }
  
  /// Get saved password for an account
  Future<String?> getSavedPassword(String email) async {
    try {
      return await _secureStorage.read(key: '$_passwordPrefix$email');
    } catch (e) {
      print('Error reading saved password: $e');
      return null;
    }
  }
}

/// Model for recent account
class RecentAccount {
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final DateTime lastLoginAt;
  final bool hasPasswordSaved;

  RecentAccount({
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    required this.lastLoginAt,
    this.hasPasswordSaved = false,
  });

  String get displayName => '$firstName $lastName';
  
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  factory RecentAccount.fromJson(Map<String, dynamic> json) {
    return RecentAccount(
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      hasPasswordSaved: json['hasPasswordSaved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'hasPasswordSaved': hasPasswordSaved,
    };
  }
}
