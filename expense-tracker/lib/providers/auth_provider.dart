import 'package:flutter/foundation.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Check if user is already logged in (on app start)
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        // Token exists, verify it by fetching profile
        _currentUser = await AuthApiService.getProfile();
        _isAuthenticated = true;
      }
    } catch (e) {
      // Token invalid or expired
      _isAuthenticated = false;
      _currentUser = null;
      await ApiService.clearToken();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final AuthResponse response = await AuthApiService.login(email, password);
      _currentUser = response.user;
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final AuthResponse response = await AuthApiService.register(email, password, name);
      _currentUser = response.user;
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    print('🔴 [AUTH] Logout started');
    _isLoading = true;
    notifyListeners();
    
    try {
      await AuthApiService.logout();
      print('🔴 [AUTH] Token cleared');
    } catch (e) {
      print('🔴 [AUTH] Logout error: $e');
    } finally {
      _currentUser = null;
      _isAuthenticated = false;
      _isLoading = false;
      print('🔴 [AUTH] Logout complete - isLoading: $_isLoading, isAuthenticated: $_isAuthenticated');
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
