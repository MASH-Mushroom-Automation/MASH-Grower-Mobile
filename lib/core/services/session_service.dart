import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../constants/storage_keys.dart';

class UserSession {
  final String email;
  final String prefix;
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final String contactNumber;
  final String countryCode;
  final String username;
  final String? profileImagePath;
  final String region;
  final String province;
  final String city;
  final String barangay;
  final String streetAddress;

  UserSession({
    required this.email,
    required this.prefix,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.suffix,
    required this.contactNumber,
    required this.countryCode,
    required this.username,
    this.profileImagePath,
    required this.region,
    required this.province,
    required this.city,
    required this.barangay,
    required this.streetAddress,
  });

  String get fullName {
    final parts = [prefix, firstName, middleName, lastName, suffix]
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.join(' ');
  }

  String get fullAddress {
    final addressParts = [streetAddress, barangay, city, province]
        .where((part) => part.isNotEmpty)
        .toList();
    return addressParts.join(', ');
  }

  String get phoneNumber {
    return '$countryCode$contactNumber';
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'prefix': prefix,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'suffix': suffix,
      'contactNumber': contactNumber,
      'countryCode': countryCode,
      'username': username,
      'profileImagePath': profileImagePath,
      'region': region,
      'province': province,
      'city': city,
      'barangay': barangay,
      'streetAddress': streetAddress,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      email: json['email'] ?? '',
      prefix: json['prefix'] ?? '',
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'] ?? '',
      lastName: json['lastName'] ?? '',
      suffix: json['suffix'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      countryCode: json['countryCode'] ?? '+63',
      username: json['username'] ?? '',
      profileImagePath: json['profileImagePath'],
      region: json['region'] ?? '',
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      barangay: json['barangay'] ?? '',
      streetAddress: json['streetAddress'] ?? '',
    );
  }
}

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  SharedPreferences? _prefs;
  UserSession? _currentSession;
  
  // Storage keys for multiple accounts
  static const String _registeredAccountsKey = 'registered_accounts';
  static const String _currentAccountKey = 'current_account';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSession();
  }

  Future<void> _loadSession() async {
    final sessionData = _prefs?.getString(StorageKeys.userData);
    print('🔍 SessionService - Loading session data: $sessionData');
    if (sessionData != null) {
      try {
        final json = jsonDecode(sessionData);
        _currentSession = UserSession.fromJson(json);
        print('🔍 SessionService - Loaded session: ${_currentSession?.toJson()}');
      } catch (e) {
        print('🔍 SessionService - Error loading session: $e');
        // Invalid session data, clear it
        await clearSession();
      }
    } else {
      print('🔍 SessionService - No session data found');
    }
  }

  UserSession? get currentSession => _currentSession;

  bool get isLoggedIn => _currentSession != null;

  Future<Map<String, dynamic>?> getRegistrationData() async {
    if (_currentSession != null) {
      return _currentSession!.toJson();
    }
    return null;
  }

  // Get all registered accounts
  Future<List<String>> getRegisteredAccounts() async {
    final accountsJson = _prefs?.getString(_registeredAccountsKey);
    if (accountsJson != null) {
      try {
        final List<dynamic> accounts = jsonDecode(accountsJson);
        return accounts.cast<String>();
      } catch (e) {
        print('🔍 SessionService - Error loading registered accounts: $e');
        return [];
      }
    }
    return [];
  }

  // Check if email is registered
  Future<bool> isEmailRegistered(String email) async {
    final registeredAccounts = await getRegisteredAccounts();
    return registeredAccounts.contains(email);
  }

  // Add email to registered accounts (max 3)
  Future<bool> addRegisteredAccount(String email) async {
    final registeredAccounts = await getRegisteredAccounts();
    
    if (registeredAccounts.length >= 3) {
      print('🔍 SessionService - Maximum 3 accounts allowed');
      return false;
    }
    
    if (!registeredAccounts.contains(email)) {
      registeredAccounts.add(email);
      await _prefs?.setString(_registeredAccountsKey, jsonEncode(registeredAccounts));
      print('🔍 SessionService - Added registered account: $email');
      return true;
    }
    
    return true; // Already registered
  }

  // Remove email from registered accounts
  Future<void> removeRegisteredAccount(String email) async {
    final registeredAccounts = await getRegisteredAccounts();
    registeredAccounts.remove(email);
    await _prefs?.setString(_registeredAccountsKey, jsonEncode(registeredAccounts));
    print('🔍 SessionService - Removed registered account: $email');
  }

  // Get account data by email
  Future<UserSession?> getAccountData(String email) async {
    final accountData = _prefs?.getString('account_$email');
    if (accountData != null) {
      try {
        final json = jsonDecode(accountData);
        return UserSession.fromJson(json);
      } catch (e) {
        print('🔍 SessionService - Error loading account data for $email: $e');
      }
    }
    return null;
  }

  // Save account data by email
  Future<void> saveAccountData(String email, UserSession session) async {
    final accountData = jsonEncode(session.toJson());
    await _prefs?.setString('account_$email', accountData);
    print('🔍 SessionService - Saved account data for: $email');
  }

  Future<void> saveSession(UserSession session) async {
    _currentSession = session;
    final sessionData = jsonEncode(session.toJson());
    print('🔍 SessionService - Saving session data: $sessionData');
    await _prefs?.setString(StorageKeys.userData, sessionData);
    print('🔍 SessionService - Session saved successfully');
  }

  Future<void> updateSession({
    String? email,
    String? prefix,
    String? firstName,
    String? middleName,
    String? lastName,
    String? suffix,
    String? contactNumber,
    String? countryCode,
    String? username,
    String? profileImagePath,
    String? region,
    String? province,
    String? city,
    String? barangay,
    String? streetAddress,
  }) async {
    if (_currentSession == null) return;

    final updatedSession = UserSession(
      email: email ?? _currentSession!.email,
      prefix: prefix ?? _currentSession!.prefix,
      firstName: firstName ?? _currentSession!.firstName,
      middleName: middleName ?? _currentSession!.middleName,
      lastName: lastName ?? _currentSession!.lastName,
      suffix: suffix ?? _currentSession!.suffix,
      contactNumber: contactNumber ?? _currentSession!.contactNumber,
      countryCode: countryCode ?? _currentSession!.countryCode,
      username: username ?? _currentSession!.username,
      profileImagePath: profileImagePath ?? _currentSession!.profileImagePath,
      region: region ?? _currentSession!.region,
      province: province ?? _currentSession!.province,
      city: city ?? _currentSession!.city,
      barangay: barangay ?? _currentSession!.barangay,
      streetAddress: streetAddress ?? _currentSession!.streetAddress,
    );

    await saveSession(updatedSession);
  }

  Future<void> clearSession() async {
    _currentSession = null;
    await _prefs?.remove(StorageKeys.userData);
    await _prefs?.remove(StorageKeys.accessToken);
    await _prefs?.remove(StorageKeys.refreshToken);
  }

  // Create session from registration data
  Future<void> createSessionFromRegistration({
    required String email,
    required String prefix,
    required String firstName,
    required String middleName,
    required String lastName,
    required String suffix,
    required String contactNumber,
    required String countryCode,
    required String username,
    String? profileImagePath,
    required String region,
    required String province,
    required String city,
    required String barangay,
    required String streetAddress,
  }) async {
    final session = UserSession(
      email: email,
      prefix: prefix,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      suffix: suffix,
      contactNumber: contactNumber,
      countryCode: countryCode,
      username: username,
      profileImagePath: profileImagePath,
      region: region,
      province: province,
      city: city,
      barangay: barangay,
      streetAddress: streetAddress,
    );

    // Add to registered accounts (max 3)
    final added = await addRegisteredAccount(email);
    if (!added) {
      throw Exception('Maximum 3 accounts allowed');
    }

    // Save account data
    await saveAccountData(email, session);
    
    // Set as current session
    await saveSession(session);
  }

  // Create session from login (only for registered emails)
  Future<void> createSessionFromLogin({
    required String email,
    String? username,
  }) async {
    // Check if email is registered
    final isRegistered = await isEmailRegistered(email);
    if (!isRegistered) {
      throw Exception('Email not registered. Please register first.');
    }

    // Load account data for this email
    final accountData = await getAccountData(email);
    if (accountData != null) {
      print('🔍 SessionService - Loading account data for: $email');
      await saveSession(accountData);
    } else {
      // Fallback to minimal data if account data not found
      final session = UserSession(
        email: email,
        prefix: '',
        firstName: '',
        middleName: '',
        lastName: '',
        suffix: '',
        contactNumber: '',
        countryCode: '+63',
        username: username ?? email.split('@')[0],
        region: '',
        province: '',
        city: '',
        barangay: '',
        streetAddress: '',
      );
      await saveSession(session);
    }
  }
}
