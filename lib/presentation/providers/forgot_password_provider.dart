import 'dart:async';
import 'package:flutter/material.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  String _email = '';
  String _otp = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isLoading = false;
  String? _error;
  int _otpTimer = 60; // 60 seconds countdown for OTP resend
  Timer? _timer;

  // Getters
  String get email => _email;
  String get otp => _otp;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get otpTimer => _otpTimer;

  // Setters
  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setOtp(String otp) {
    _otp = otp;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setConfirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    notifyListeners();
  }

  // Send OTP to email
  Future<bool> sendOtp() async {
    if (_email.isEmpty) {
      _setError('Email is required');
      return false;
    }

    _setLoading(true);
    try {
      // TODO: Implement actual API call to send OTP
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // Start OTP timer
      _startOtpTimer();
      
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to send OTP. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP
  Future<bool> verifyOtp() async {
    if (_otp.isEmpty || _otp.length != 6) {
      _setError('Please enter a valid OTP');
      return false;
    }

    _setLoading(true);
    try {
      // TODO: Implement actual API call to verify OTP
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // For demo purposes, accept any 6-digit OTP
      _clearError();
      return true;
    } catch (e) {
      _setError('Invalid OTP. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Resend OTP
  Future<bool> resendOtp() async {
    if (_otpTimer > 0) {
      return false; // Cannot resend yet
    }

    return sendOtp();
  }

  // Reset Password
  Future<bool> resetPassword() async {
    if (_password.isEmpty) {
      _setError('Password is required');
      return false;
    }

    if (_password != _confirmPassword) {
      _setError('Passwords do not match');
      return false;
    }

    _setLoading(true);
    try {
      // TODO: Implement actual API call to reset password
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to reset password. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Start OTP timer
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

  // Reset provider state
  void reset() {
    _email = '';
    _otp = '';
    _password = '';
    _confirmPassword = '';
    _isLoading = false;
    _error = null;
    _otpTimer = 0;
    _timer?.cancel();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
