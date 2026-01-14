import 'package:equatable/equatable.dart';

/// Request model for OAuth authentication (Google, Facebook, etc.)
class OAuthRequestModel extends Equatable {
  final String idToken;
  final String? accessToken;
  final String provider; // 'google', 'facebook', 'github', etc.
  final String? email;
  final String? displayName;
  final String? photoUrl;
  
  const OAuthRequestModel({
    required this.idToken,
    this.accessToken,
    required this.provider,
    this.email,
    this.displayName,
    this.photoUrl,
  });
  
  /// Create Google OAuth request
  factory OAuthRequestModel.google({
    required String idToken,
    String? accessToken,
    String? email,
    String? displayName,
    String? photoUrl,
  }) {
    return OAuthRequestModel(
      idToken: idToken,
      accessToken: accessToken,
      provider: 'google',
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
  
  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
      if (accessToken != null) 'accessToken': accessToken,
      'provider': provider,
      if (email != null) 'email': email?.toLowerCase().trim(),
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
  
  @override
  List<Object?> get props => [idToken, accessToken, provider, email, displayName, photoUrl];
}

