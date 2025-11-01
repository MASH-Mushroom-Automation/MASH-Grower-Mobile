import 'package:equatable/equatable.dart';

/// Response model for reset password
class ResetPasswordResponseModel extends Equatable {
  final bool success;
  final String message;
  
  const ResetPasswordResponseModel({
    required this.success,
    required this.message,
  });
  
  /// Create from JSON response
  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Password reset successful',
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
  
  @override
  List<Object?> get props => [success, message];
}
