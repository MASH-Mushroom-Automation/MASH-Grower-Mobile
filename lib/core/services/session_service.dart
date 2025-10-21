import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../constants/storage_keys.dart';

class UserSession {
  final String email;
  final String firstName;
  final String middleName;
  final String lastName;
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
    required this.firstName,
    required this.middleName,
    required this.lastName,
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
    final parts = [firstName, middleName, lastName]
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
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
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
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'] ?? '',
      lastName: json['lastName'] ?? '',
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

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSession();
  }

  Future<void> _loadSession() async {
    final sessionData = _prefs?.getString(StorageKeys.userData);
    if (sessionData != null) {
      try {
        final json = jsonDecode(sessionData);
        _currentSession = UserSession.fromJson(json);
      } catch (e) {
        // Invalid session data, clear it
        await clearSession();
      }
    }
  }

  UserSession? get currentSession => _currentSession;

  bool get isLoggedIn => _currentSession != null;

  Future<void> saveSession(UserSession session) async {
    _currentSession = session;
    final sessionData = jsonEncode(session.toJson());
    await _prefs?.setString(StorageKeys.userData, sessionData);
  }

  Future<void> updateSession({
    String? email,
    String? firstName,
    String? middleName,
    String? lastName,
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
      firstName: firstName ?? _currentSession!.firstName,
      middleName: middleName ?? _currentSession!.middleName,
      lastName: lastName ?? _currentSession!.lastName,
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
    required String firstName,
    required String middleName,
    required String lastName,
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
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
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

    await saveSession(session);
  }

  // Create session from login (with minimal data)
  Future<void> createSessionFromLogin({
    required String email,
    String? username,
  }) async {
    final session = UserSession(
      email: email,
      firstName: '',
      middleName: '',
      lastName: '',
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
