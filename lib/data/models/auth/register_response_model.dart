import 'package:equatable/equatable.dart';
import 'backend_user_model.dart';

/// Response model for user registration
class RegisterResponseModel extends Equatable {
  final bool success;
  final String message;
  final BackendUserModel? user;
  final Map<String, dynamic>? data;
  
  const RegisterResponseModel({
    required this.success,
    required this.message,
    this.user,
    this.data,
  });
  
  /// Create from JSON response
  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Registration successful',
      user: json['user'] != null 
          ? BackendUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (user != null) 'user': user!.toJson(),
      if (data != null) 'data': data,
    };
  }
  
  @override
  List<Object?> get props => [success, message, user, data];
}
