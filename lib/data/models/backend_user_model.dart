import 'package:equatable/equatable.dart';

/// Backend User Model matching the Railway API response structure
class BackendUserModel extends Equatable {
  final String id;
  final String? clerkId;
  final String email;
  final String? username;
  final String firstName;
  final String lastName;
  final String? imageUrl;
  final String? avatarUrl;
  final bool emailVerified;
  final String role;
  final bool? isActive;
  final String createdAt;
  final String? updatedAt;
  final String? lastLoginAt;

  const BackendUserModel({
    required this.id,
    this.clerkId,
    required this.email,
    this.username,
    required this.firstName,
    required this.lastName,
    this.imageUrl,
    this.avatarUrl,
    required this.emailVerified,
    required this.role,
    this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory BackendUserModel.fromJson(Map<String, dynamic> json) {
    return BackendUserModel(
      id: json['id'] as String,
      clerkId: json['clerkId'] as String?,
      email: json['email'] as String,
      username: json['username'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      imageUrl: json['imageUrl'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      role: json['role'] as String? ?? 'USER',
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
      lastLoginAt: json['lastLoginAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clerkId': clerkId,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'imageUrl': imageUrl ?? avatarUrl,
      'emailVerified': emailVerified,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLoginAt': lastLoginAt,
    };
  }

  /// Display name for UI (uses username or full name)
  String get displayName => username ?? fullName;

  /// Full name combining first and last name
  String get fullName => '$firstName $lastName';

  /// Profile image URL (prefers imageUrl over avatarUrl)
  String get profileImage => imageUrl ?? avatarUrl ?? '';

  /// Check if user has completed profile
  bool get hasCompletedProfile => username != null && profileImage.isNotEmpty;

  /// Copy with method for updating fields
  BackendUserModel copyWith({
    String? id,
    String? clerkId,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? imageUrl,
    String? avatarUrl,
    bool? emailVerified,
    String? role,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    String? lastLoginAt,
  }) {
    return BackendUserModel(
      id: id ?? this.id,
      clerkId: clerkId ?? this.clerkId,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      imageUrl: imageUrl ?? this.imageUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clerkId,
        email,
        username,
        firstName,
        lastName,
        imageUrl,
        avatarUrl,
        emailVerified,
        role,
        isActive,
        createdAt,
        updatedAt,
        lastLoginAt,
      ];

  @override
  String toString() {
    return 'BackendUserModel(id: $id, email: $email, displayName: $displayName, emailVerified: $emailVerified, role: $role)';
  }
}
