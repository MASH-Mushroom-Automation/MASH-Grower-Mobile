import 'package:equatable/equatable.dart';

/// Request model for user registration
class RegisterRequestModel extends Equatable {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String username;
  final String? middleName;
  final String? contactNumber;
  
  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.middleName,
    this.contactNumber,
  });
  
  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'email': email.toLowerCase().trim(),
      'password': password,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'username': username.toLowerCase().trim(),
    };
    
    // Add optional fields if provided
    if (middleName != null && middleName!.isNotEmpty) {
      json['middleName'] = middleName!.trim();
    }
    if (contactNumber != null && contactNumber!.isNotEmpty) {
      json['contactNumber'] = contactNumber!.trim();
    }
    
    return json;
  }
  
  @override
  List<Object?> get props => [
        email,
        password,
        firstName,
        lastName,
        username,
        middleName,
        contactNumber,
      ];
}
