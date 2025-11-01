import 'package:equatable/equatable.dart';

/// Request model for user login
class LoginRequestModel extends Equatable {
  final String email;
  final String password;
  
  const LoginRequestModel({
    required this.email,
    required this.password,
  });
  
  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email.toLowerCase().trim(),
      'password': password,
    };
  }
  
  @override
  List<Object?> get props => [email, password];
}
