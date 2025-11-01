import 'package:equatable/equatable.dart';

/// Request model for forgot password
class ForgotPasswordRequestModel extends Equatable {
  final String email;
  
  const ForgotPasswordRequestModel({required this.email});
  
  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email.toLowerCase().trim(),
    };
  }
  
  @override
  List<Object?> get props => [email];
}
