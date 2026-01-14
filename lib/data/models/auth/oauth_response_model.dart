import 'package:equatable/equatable.dart';
import 'backend_user_model.dart';

/// Response model for OAuth authentication
class OAuthResponseModel extends Equatable {
  final bool success;
  final String message;
  final String accessToken;
  final String refreshToken;
  final BackendUserModel user;
  final bool isNewUser; // Indicates if this is a newly registered user
  
  const OAuthResponseModel({
    required this.success,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.isNewUser = false,
  });
  
  /// Create from JSON response
  factory OAuthResponseModel.fromJson(Map<String, dynamic> json) {
    return OAuthResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Authentication successful',
      accessToken: json['accessToken'] as String? ?? json['access_token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? json['refresh_token'] as String? ?? '',
      user: BackendUserModel.fromJson(json['user'] as Map<String, dynamic>),
      isNewUser: json['isNewUser'] as bool? ?? false,
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
      'isNewUser': isNewUser,
    };
  }
  
  @override
  List<Object?> get props => [success, message, accessToken, refreshToken, user, isNewUser];
}


