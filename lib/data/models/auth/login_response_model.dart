import 'package:equatable/equatable.dart';
import 'backend_user_model.dart';

/// Response model for user login
class LoginResponseModel extends Equatable {
  final bool success;
  final String message;
  final String accessToken;
  final String refreshToken;
  final BackendUserModel user;
  
  const LoginResponseModel({
    required this.success,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
  
  /// Create from JSON response
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Debug: Print the actual JSON to see what backend returns
    print('🔍 Parsing login response JSON: $json');
    
    return LoginResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Login successful',
      accessToken: json['accessToken'] as String? ?? json['access_token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? json['refresh_token'] as String? ?? '',
      user: BackendUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
  
  @override
  List<Object?> get props => [success, message, accessToken, refreshToken, user];
}
