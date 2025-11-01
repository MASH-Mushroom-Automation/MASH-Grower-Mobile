import 'package:equatable/equatable.dart';

/// Request model for reset password
class ResetPasswordRequestModel extends Equatable {
  final String email;
  final String code;
  final String newPassword;
  
  const ResetPasswordRequestModel({
    required this.email,
    required this.code,
    required this.newPassword,
  });
  
  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email.toLowerCase().trim(),
      'code': code.trim(),
      'newPassword': newPassword,
    };
  }
  
  @override
  List<Object?> get props => [email, code, newPassword];
}
