import 'user_model.dart';

class AuthResponse {
  final String accessToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      return AuthResponse(
        accessToken: json['accessToken']?.toString() ?? json['access_token']?.toString() ?? '',
        user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      );
    } catch (e) {
      throw Exception('Failed to parse auth response: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'user': user.toJson(),
    };
  }
}
