import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to manage recently logged-in accounts for quick sign-in
/// Similar to Facebook's "Recently Logged In" feature
class RecentAccountsService {
  static final RecentAccountsService _instance = RecentAccountsService._internal();
  factory RecentAccountsService() => _instance;
  RecentAccountsService._internal();

  SharedPreferences? _prefs;
  
  static const String _recentAccountsKey = 'recent_accounts';
  static const int _maxRecentAccounts = 3; // Maximum 3 recent accounts

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
  }) async {
    final accounts = await getRecentAccounts();
    
    // Remove if already exists
    accounts.removeWhere((account) => account.email == email);
    
    // Add to front
    accounts.insert(0, RecentAccount(
      email: email,
      firstName: firstName,
      lastName: lastName,
      profileImageUrl: profileImageUrl,
      lastLoginAt: DateTime.now(),
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
    
    final accountsJson = jsonEncode(accounts.map((a) => a.toJson()).toList());
    await _prefs?.setString(_recentAccountsKey, accountsJson);
  }

  /// Clear all recent accounts
  Future<void> clearRecentAccounts() async {
    await _prefs?.remove(_recentAccountsKey);
  }
}

/// Model for recent account
class RecentAccount {
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final DateTime lastLoginAt;

  RecentAccount({
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    required this.lastLoginAt,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }
}
