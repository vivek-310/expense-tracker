import '../config/api_config.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthApiService {
  // Login
  static Future<AuthResponse> login(String email, String password) async {
    final response = await ApiService.post(
      ApiConfig.login,
      {
        'email': email,
        'password': password,
      },
    );

    final authResponse = AuthResponse.fromJson(response);
    await ApiService.saveToken(authResponse.accessToken);
    return authResponse;
  }

  // Register
  static Future<AuthResponse> register(
    String email,
    String password,
    String name,
  ) async {
    print('🔵 [AUTH] Starting registration...');
    final response = await ApiService.post(
      ApiConfig.register,
      {
        'email': email,
        'password': password,
        'name': name,
      },
    );

    print('🔵 [AUTH] Got registration response: ${response.keys}');
    final authResponse = AuthResponse.fromJson(response);
    final tokenPreview = authResponse.accessToken.length > 20 
        ? '${authResponse.accessToken.substring(0, 20)}...' 
        : authResponse.accessToken;
    print('🔵 [AUTH] Parsed token: $tokenPreview (length: ${authResponse.accessToken.length})');
    
    await ApiService.saveToken(authResponse.accessToken);
    
    // Verify token was saved
    final savedToken = await ApiService.getToken();
    print('🔵 [AUTH] Token saved and verified: ${savedToken != null ? "YES" : "NO"}');
    if (savedToken != null) {
      print('🔵 [AUTH] Saved token matches: ${savedToken == authResponse.accessToken}');
    }
    
    return authResponse;
  }

  // Get profile
  static Future<User> getProfile() async {
    final response = await ApiService.get(ApiConfig.profile);
    return User.fromJson(response);
  }

  // Logout
  static Future<void> logout() async {
    await ApiService.clearToken();
  }
}
