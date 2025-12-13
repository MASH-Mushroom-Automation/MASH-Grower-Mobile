import 'package:equatable/equatable.dart';

/// Backend user model (JWT-based authentication)
/// 
/// This model represents the user data returned from the backend API,
/// distinct from Firebase user model.
class BackendUserModel extends Equatable {
  final String id;
  final String email;
  final String? username; // Made optional
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? contactNumber;
  final String? avatarUrl;
  final bool isEmailVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;
  
  const BackendUserModel({
    required this.id,
    required this.email,
    this.username, // Made optional
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.contactNumber,
    this.avatarUrl,
    required this.isEmailVerified,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
  });
  
  /// Get full name
  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }
  
  /// Get display name (first name or username or email prefix)
  String get displayName => firstName.isNotEmpty 
      ? firstName 
      : username?.isNotEmpty == true 
          ? username! 
          : email.split('@')[0];
  
  /// Create from JSON response
  factory BackendUserModel.fromJson(Map<String, dynamic> json) {
    return BackendUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String? ?? json['email'].split('@')[0], // Fallback to email prefix
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      middleName: json['middleName'] as String?,
      contactNumber: json['contactNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? 
                 json['imageUrl'] as String? ?? 
                 json['avatar_url'] as String? ?? 
                 json['image_url'] as String? ?? 
                 json['profileImageUrl'] as String? ?? 
                 json['profile_image_url'] as String?, // Support multiple field name variations
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (username != null) 'username': username,
      'firstName': firstName,
      'lastName': lastName,
      if (middleName != null) 'middleName': middleName,
      if (contactNumber != null) 'contactNumber': contactNumber,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (preferences != null) 'preferences': preferences,
    };
  }
  
  /// Copy with method for updating user data
  BackendUserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? middleName,
    String? contactNumber,
    String? avatarUrl,
    bool? isEmailVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
  }) {
    return BackendUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      contactNumber: contactNumber ?? this.contactNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
    );
  }
  
  @override
  List<Object?> get props => [
        id,
        email,
        username,
        firstName,
        lastName,
        middleName,
        contactNumber,
        avatarUrl,
        isEmailVerified,
        isActive,
        createdAt,
        updatedAt,
        preferences,
      ];
}
