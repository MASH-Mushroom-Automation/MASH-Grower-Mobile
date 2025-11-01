import 'package:equatable/equatable.dart';

/// Response model for forgot password
class ForgotPasswordResponseModel extends Equatable {
  final bool success;
  final String message;
  
  const ForgotPasswordResponseModel({
    required this.success,
    required this.message,
  });
  
  /// Create from JSON response
  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Reset code sent to your email',
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
