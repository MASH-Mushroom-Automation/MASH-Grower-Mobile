import 'package:flutter/material.dart';
import 'dart:async';

import '../../core/services/session_service.dart';

class RegistrationProvider extends ChangeNotifier {
  // Page 1: Email
  String _email = '';
  
  // Page 2: OTP
  String _otp = '';
  bool _isOtpVerified = false;
  
  // Page 3: Profile
  String _firstName = '';
  String _middleName = '';
  String _lastName = '';
  String _contactNumber = '';
  String _countryCode = '+63';
  bool _phoneOtpVerified = false;
  
  // Page 4: Account
  String _username = '';
  String _region = '';
  String _province = '';
  String _city = '';
  String _barangay = '';
  String _streetAddress = '';
  String? _profileImagePath;
  
  // Page 5: Password
  String _password = '';
  String _confirmPassword = '';
  
  // Loading states
  bool _isLoading = false;
  String? _error;
  
  // OTP Timer
  int _otpTimer = 60;
  Timer? _timer;
  
  // Getters
  String get email => _email;
  String get otp => _otp;
  bool get isOtpVerified => _isOtpVerified;
  String get firstName => _firstName;
  String get middleName => _middleName;
  String get lastName => _lastName;
  String get contactNumber => _contactNumber;
  String get countryCode => _countryCode;
  String get username => _username;
  String get region => _region;
  String get province => _province;
  String get city => _city;
  String get barangay => _barangay;
  String get streetAddress => _streetAddress;
  String? get profileImagePath => _profileImagePath;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get otpTimer => _otpTimer;
  bool get phoneOtpVerified => _phoneOtpVerified;
  
  // Setters
  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }
  
  void setOtp(String value) {
    _otp = value;
    notifyListeners();
  }
  
  void setFirstName(String value) {
    _firstName = value;
    notifyListeners();
  }
  
  void setMiddleName(String value) {
    _middleName = value;
    notifyListeners();
  }
  
  void setLastName(String value) {
    _lastName = value;
    notifyListeners();
  }
  
  void setContactNumber(String value) {
    _contactNumber = value;
    notifyListeners();
  }
  
  void setCountryCode(String value) {
    _countryCode = value;
    notifyListeners();
  }
  
  void setPhoneOtpVerified(bool value) {
    _phoneOtpVerified = value;
    notifyListeners();
  }
  
  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }
  
  void setRegion(String value) {
    _region = value;
    notifyListeners();
  }
  
  void setProvince(String value) {
    _province = value;
    notifyListeners();
  }
  
  void setCity(String value) {
    _city = value;
    notifyListeners();
  }
  
  void setBarangay(String value) {
    _barangay = value;
    notifyListeners();
  }
  
  void setStreetAddress(String value) {
    _streetAddress = value;
    notifyListeners();
  }
  
  void setProfileImagePath(String? value) {
    _profileImagePath = value;
    notifyListeners();
  }
  
  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }
  
  void setConfirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }
  
  // Send OTP
  Future<bool> sendOtp() async {
    _setLoading(true);
    _clearError();
    
    try {
      // TODO: Backend Integration - Send OTP to email
      // await apiService.sendOtp(_email);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Start OTP timer
      _startOtpTimer();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to send OTP. Please try again.');
      _setLoading(false);
      return false;
    }
  }
  
  // Verify OTP
  Future<bool> verifyOtp() async {
    _setLoading(true);
    _clearError();
    
    try {
      // TODO: Backend Integration - Verify OTP
      // final result = await apiService.verifyOtp(_email, _otp);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo, accept any 6-digit OTP
      if (_otp.length == 6) {
        _isOtpVerified = true;
        _stopOtpTimer();
        _setLoading(false);
        return true;
      }
      
      _setError('Invalid OTP. Please try again.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to verify OTP. Please try again.');
      _setLoading(false);
      return false;
    }
  }
  
  // Resend OTP
  Future<bool> resendOtp() async {
    _clearError();
    
    try {
      // TODO: Backend Integration - Resend OTP
      // await apiService.sendOtp(_email);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Restart timer
      _otpTimer = 60;
      _startOtpTimer();
      
      return true;
    } catch (e) {
      _setError('Failed to resend OTP. Please try again.');
      return false;
    }
  }

  // Public controls for OTP timer (used by phone verification step)
  void startOtpTimer() {
    _startOtpTimer();
  }

  void resetOtpTimer() {
    _otpTimer = 60;
    _startOtpTimer();
  }
  
  // Complete Registration
  Future<bool> completeRegistration() async {
    _setLoading(true);
    _clearError();
    
    try {
      // TODO: Backend Integration - Create user account
      // final userData = {
      //   'email': _email,
      //   'firstName': _firstName,
      //   'middleName': _middleName,
      //   'lastName': _lastName,
      //   'contactNumber': '$_countryCode$_contactNumber',
      //   'username': _username,
      //   'address': {
      //     'region': _region,
      //     'province': _province,
      //     'city': _city,
      //     'barangay': _barangay,
      //     'street': _streetAddress,
      //   },
      //   'password': _password,
      // };
      // 
      // if (_profileImagePath != null) {
      //   userData['profileImage'] = _profileImagePath;
      // }
      // 
      // await apiService.createAccount(userData);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Save session data
      print('=== REGISTRATION DATA ===');
      print('Email: $_email');
      print('First Name: $_firstName');
      print('Middle Name: $_middleName');
      print('Last Name: $_lastName');
      print('Contact: $_countryCode$_contactNumber');
      print('Username: $_username');
      print('Region: $_region');
      print('Province: $_province');
      print('City: $_city');
      print('Barangay: $_barangay');
      print('Street: $_streetAddress');
      print('Profile Image: $_profileImagePath');
      print('========================');
      
      final sessionService = SessionService();
      await sessionService.createSessionFromRegistration(
        email: _email,
        firstName: _firstName,
        middleName: _middleName,
        lastName: _lastName,
        contactNumber: _contactNumber,
        countryCode: _countryCode,
        username: _username,
        profileImagePath: _profileImagePath,
        region: _region,
        province: _province,
        city: _city,
        barangay: _barangay,
        streetAddress: _streetAddress,
      );
      
      print('Session saved successfully!');
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to create account. Please try again.');
      _setLoading(false);
      return false;
    }
  }
  
  // OTP Timer
  void _startOtpTimer() {
    _otpTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpTimer > 0) {
        _otpTimer--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }
  
  void _stopOtpTimer() {
    _timer?.cancel();
    _otpTimer = 0;
    notifyListeners();
  }
  
  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String message) {
    _error = message;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Reset all data
  void reset() {
    _email = '';
    _otp = '';
    _isOtpVerified = false;
    _firstName = '';
    _middleName = '';
    _lastName = '';
    _contactNumber = '';
    _countryCode = '+639';
    _username = '';
    _region = '';
    _province = '';
    _city = '';
    _barangay = '';
    _streetAddress = '';
    _profileImagePath = null;
    _password = '';
    _confirmPassword = '';
    _isLoading = false;
    _error = null;
    _stopOtpTimer();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
