import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String? clerkUserId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    this.clerkUserId,
    required this.email,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      clerkUserId: json['clerk_user_id'] as String?,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      role: json['role'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clerk_user_id': clerkUserId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_image_url': profileImageUrl,
      'role': role,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromDatabase(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      clerkUserId: map['clerk_user_id'] as String?,
      email: map['email'] as String,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      profileImageUrl: map['profile_image_url'] as String?,
      role: map['role'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'clerk_user_id': clerkUserId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_image_url': profileImageUrl,
      'role': role,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? id,
    String? clerkUserId,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      clerkUserId: clerkUserId ?? this.clerkUserId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email;
  }

  String get displayName {
    return fullName;
  }

  bool get isAdmin => role == 'admin';
  bool get isSeller => role == 'seller';
  bool get isUser => role == 'user' || role == null;

  @override
  List<Object?> get props => [
        id,
        clerkUserId,
        email,
        firstName,
        lastName,
        profileImageUrl,
        role,
        createdAt,
        updatedAt,
      ];
}
