import 'package:equatable/equatable.dart';

/// Request model for email verification
class VerifyEmailRequestModel extends Equatable {
  final String email;
  final String code;
  
  const VerifyEmailRequestModel({
    required this.email,
    required this.code,
  });
  
  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email.toLowerCase().trim(),
      'code': code.trim(),
    };
  }
  
  @override
  List<Object?> get props => [email, code];
}
