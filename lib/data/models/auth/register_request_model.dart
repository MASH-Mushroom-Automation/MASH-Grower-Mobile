import 'package:equatable/equatable.dart';

/// Request model for user registration
/// Matches backend RegisterDto (email, password, firstName, lastName, username)
class RegisterRequestModel extends Equatable {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String username;
  
  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.username,
  });
  
  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email.toLowerCase().trim(),
      'password': password,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'username': username.toLowerCase().trim(),
    };
  }
  
  @override
  List<Object?> get props => [
        email,
        password,
        firstName,
        lastName,
        username,
      ];
}
