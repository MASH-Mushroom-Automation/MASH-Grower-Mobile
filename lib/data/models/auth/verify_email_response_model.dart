import 'package:equatable/equatable.dart';
import 'backend_user_model.dart';

/// Response model for email verification
class VerifyEmailResponseModel extends Equatable {
  final bool success;
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final BackendUserModel? user;
  
  const VerifyEmailResponseModel({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });
  
  /// Create from JSON response
  factory VerifyEmailResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Email verified successfully',
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] != null 
          ? BackendUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (accessToken != null) 'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (user != null) 'user': user!.toJson(),
    };
  }
  
  @override
  List<Object?> get props => [success, message, accessToken, refreshToken, user];
}
