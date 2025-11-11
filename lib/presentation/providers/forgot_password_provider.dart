import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/datasources/remote/backend_auth_remote_data_source.dart';
import '../../core/utils/logger.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  final BackendAuthRemoteDataSource _authDataSource = BackendAuthRemoteDataSource();
  
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

  // Send OTP to email (request password reset)
  Future<bool> sendOtp() async {
    if (_email.isEmpty) {
      _setError('Email is required');
      return false;
    }

    _setLoading(true);
    try {
      Logger.info('📧 Requesting password reset for: $_email');
      
      // Call backend API to request password reset
      final success = await _authDataSource.forgotPassword(email: _email);
      
      if (success) {
        // Start OTP timer
        _startOtpTimer();
        _clearError();
        Logger.info('✅ Password reset code sent to: $_email');
        return true;
      } else {
        _setError('Failed to send reset code. Please try again.');
        return false;
      }
    } catch (e) {
      Logger.error('❌ Failed to send reset code', e);
      
      String errorMessage = 'Failed to send reset code. Please try again.';
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection.';
      }
      
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP and reset password
  Future<bool> resetPassword() async {
    if (_otp.isEmpty || _otp.length != 6) {
      _setError('Please enter a valid 6-digit code');
      return false;
    }

    if (_password.isEmpty || _password.length < 8) {
      _setError('Password must be at least 8 characters');
      return false;
    }

    if (_password != _confirmPassword) {
      _setError('Passwords do not match');
      return false;
    }

    _setLoading(true);
    try {
      Logger.info('🔒 Resetting password for: $_email');
      
      // Call backend API to reset password with code
      final success = await _authDataSource.resetPassword(
        email: _email,
        code: _otp,
        newPassword: _password,
      );
      
      if (success) {
        _clearError();
        Logger.info('✅ Password reset successful for: $_email');
        return true;
      } else {
        _setError('Failed to reset password. Please try again.');
        return false;
      }
    } catch (e) {
      Logger.error('❌ Password reset failed', e);
      
      String errorMessage = 'Failed to reset password. Please try again.';
      if (e.toString().contains('Invalid or expired')) {
        errorMessage = 'Invalid or expired reset code. Please request a new one.';
      } else if (e.toString().contains('User not found')) {
        errorMessage = 'No account found with this email.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection.';
      }
      
      _setError(errorMessage);
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
