import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static const String _tokenKey = 'auth_token';

  // Get stored auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save auth token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Clear auth token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await getToken();
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout. Please check your internet connection.');
        },
      );

      return _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('Cannot connect to server. Please check your network.');
      }
      rethrow;
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await getToken();
      final tokenPreview = token != null && token.length > 20 
          ? '${token.substring(0, 20)}...' 
          : token ?? 'NONE';
      print('🔵 [API] POST $endpoint - Token: $tokenPreview');
      
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout. Please check your internet connection.');
        },
      );

      print('🔵 [API] POST $endpoint - Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('🔴 [API] POST $endpoint - Error: $e');
      if (e.toString().contains('SocketException')) {
        throw Exception('Cannot connect to server. Please check your network.');
      }
      rethrow;
    }
  }

  // PATCH request
  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // DELETE request
  static Future<void> delete(String endpoint) async {
    final token = await getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Request failed');
    }
  }

  // Handle API response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Request failed');
    }
  }
}
