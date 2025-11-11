import 'package:flutter/material.dart';
import 'dart:async';

import '../../core/services/session_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/models/auth/register_request_model.dart';
import '../../data/models/auth/verify_email_request_model.dart';
import '../../core/utils/logger.dart';

class RegistrationProvider extends ChangeNotifier {
  late final AuthRepository _authRepository;
  
  RegistrationProvider() {
    _initializeAuthRepository();
  }
  
  void _initializeAuthRepository() {
    final dioClient = DioClient();
    final apiClient = ApiClient(dioClient);
    final remoteDataSource = AuthRemoteDataSource(apiClient);
    final secureStorage = SecureStorageService.instance;
    _authRepository = AuthRepository(remoteDataSource, secureStorage);
  }
  
  // Page 1: Email
  String _email = '';
  
  // Page 2: OTP
  String _otp = '';
  bool _isOtpVerified = false;
  
  // Page 3: Profile
  String _prefix = '';
  String _firstName = '';
  String _middleName = '';
  String _lastName = '';
  String _suffix = '';
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
  String get prefix => _prefix;
  String get firstName => _firstName;
  String get middleName => _middleName;
  String get lastName => _lastName;
  String get suffix => _suffix;
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
  
  void setPrefix(String value) {
    _prefix = value;
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

  void setSuffix(String value) {
    _suffix = value;
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
  
  /// Submit registration to backend API
  /// 
  /// This method sends all collected registration data to the backend
  /// in a single API call (POST /api/v1/auth/register).
  /// The backend will return user data and send a 6-digit verification code to the email.
  Future<bool> submitRegistration() async {
    _setLoading(true);
    _clearError();
    
    try {
      Logger.info('📝 Submitting registration for: $_email');
      
      // Build the registration request
      final registerRequest = RegisterRequestModel(
        email: _email,
        password: _password,
        firstName: _firstName,
        lastName: _lastName,
        username: _username,
        middleName: _middleName.isNotEmpty ? _middleName : null,
        contactNumber: _contactNumber.isNotEmpty 
            ? '$_countryCode$_contactNumber' 
            : null,
      );
      
      // Call backend API
      final response = await _authRepository.register(registerRequest);
      
      if (response.success) {
        Logger.info('✅ Registration submitted successfully');
        // Note: User is not fully registered yet - they need to verify email
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      Logger.error('❌ Registration submission failed', e);
      
      // Extract user-friendly error message
      String errorMessage = 'Failed to submit registration. Please try again.';
      if (e.toString().contains('email already exists')) {
        errorMessage = 'This email is already registered.';
      } else if (e.toString().contains('username already exists')) {
        errorMessage = 'This username is already taken.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      }
      
      _setError(errorMessage);
      _setLoading(false);
      return false;
    }
  }
  
  /// Verify the email with the 6-digit code sent by backend
  /// 
  /// This method calls POST /api/v1/auth/verify-email and receives JWT tokens.
  Future<bool> verifyEmailWithCode(String code) async {
    _setLoading(true);
    _clearError();
    
    try {
      Logger.info('📧 Verifying email: $_email with code: $code');
      
      final request = VerifyEmailRequestModel(email: _email, code: code);
      final response = await _authRepository.verifyEmail(request);
      
      if (response.success && response.accessToken != null) {
        Logger.info('✅ Email verified successfully');
        _isOtpVerified = true;
        _stopOtpTimer();
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      Logger.error('❌ Email verification failed', e);
      
      String errorMessage = 'Failed to verify email. Please try again.';
      if (e.toString().contains('invalid') || e.toString().contains('code')) {
        errorMessage = 'Invalid verification code. Please try again.';
      } else if (e.toString().contains('expired')) {
        errorMessage = 'Verification code has expired. Please request a new one.';
      }
      
      _setError(errorMessage);
      _setLoading(false);
      return false;
    }
  }
  
  /// Resend email verification code
  Future<bool> resendEmailVerification() async {
    _clearError();
    
    try {
      Logger.info('📧 Resending verification code to: $_email');
      
      await _authRepository.resendVerification(_email);
      
      // Restart timer
      _otpTimer = 60;
      _startOtpTimer();
      
      return true;
    } catch (e) {
      Logger.error('❌ Failed to resend verification code', e);
      _setError('Failed to resend verification code. Please try again.');
      return false;
    }
  }
  
  // Complete Registration (OLD - KEEP FOR NOW FOR COMPATIBILITY)
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
      print('Prefix: $_prefix');
      print('First Name: $_firstName');
      print('Middle Name: $_middleName');
      print('Last Name: $_lastName');
      print('Suffix: $_suffix');
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
      await sessionService.initialize();
      await sessionService.createSessionFromRegistration(
        email: _email,
        prefix: _prefix,
        firstName: _firstName,
        middleName: _middleName,
        lastName: _lastName,
        suffix: _suffix,
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
    _prefix = '';
    _firstName = '';
    _middleName = '';
    _lastName = '';
    _suffix = '';
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
