# Flutter Integration Guide

This guide shows how to integrate your Flutter app with the NestJS backend.

## 📦 Flutter Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
```

## 🔐 API Service Setup

Create `lib/services/api_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000'; // Change for production
  
  String? _accessToken;
  
  // Load token from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }
  
  // Save token to storage
  Future<void> _saveToken(String token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }
  
  // Clear token
  Future<void> logout() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
  
  // Get headers with auth token
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (includeAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    
    return headers;
  }
  
  // Register user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
        if (name != null) 'name': name,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }
  
  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _saveToken(data['accessToken']);
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }
  
  // Get user features
  Future<Map<String, bool>> getUserFeatures() async {
    final response = await http.get(
      Uri.parse('$baseUrl/features'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Map<String, bool>.from(data['features']);
    } else {
      throw Exception('Failed to get features');
    }
  }
  
  // Get subscription status
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subscriptions/status'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get subscription');
    }
  }
  
  // Create expense
  Future<Map<String, dynamic>> createExpense({
    required double amount,
    required String category,
    String? note,
    String? paymentMethod,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: _getHeaders(),
      body: jsonEncode({
        'amount': amount,
        'category': category,
        if (note != null) 'note': note,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create expense: ${response.body}');
    }
  }
  
  // Get all expenses
  Future<List<dynamic>> getExpenses({
    String? startDate,
    String? endDate,
  }) async {
    String url = '$baseUrl/expenses';
    if (startDate != null && endDate != null) {
      url += '?startDate=$startDate&endDate=$endDate';
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['expenses'];
    } else {
      throw Exception('Failed to get expenses');
    }
  }
  
  // Create split (feature-gated)
  Future<Map<String, dynamic>> createSplit({
    required String expenseId,
    required List<Map<String, dynamic>> splits,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/splits'),
      headers: _getHeaders(),
      body: jsonEncode({
        'expenseId': expenseId,
        'splits': splits,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      throw Exception('Feature not available. Upgrade to PRO to access splits.');
    } else {
      throw Exception('Failed to create split: ${response.body}');
    }
  }
}
```

## 🎨 Feature Provider

Create `lib/providers/feature_provider.dart`:

```dart
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class FeatureProvider with ChangeNotifier {
  final ApiService _apiService;
  Map<String, bool> _features = {};
  bool _isLoading = false;
  
  FeatureProvider(this._apiService);
  
  Map<String, bool> get features => _features;
  bool get isLoading => _isLoading;
  
  // Check if a specific feature is enabled
  bool isFeatureEnabled(String featureName) {
    return _features[featureName] ?? false;
  }
  
  // Load features from backend
  Future<void> loadFeatures() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _features = await _apiService.getUserFeatures();
    } catch (e) {
      print('Error loading features: $e');
      _features = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

## 🚀 Usage Examples

### 1. Initialize in main.dart

```dart
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'providers/feature_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final apiService = ApiService();
  await apiService.init();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(
          create: (_) => FeatureProvider(apiService),
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

### 2. Login Screen

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  Future<void> _login() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // Load user features after login
      final featureProvider = Provider.of<FeatureProvider>(context, listen: false);
      await featureProvider.loadFeatures();
      
      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Feature-Gated UI

```dart
class SplitExpenseButton extends StatelessWidget {
  final String expenseId;
  
  const SplitExpenseButton({required this.expenseId});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<FeatureProvider>(
      builder: (context, featureProvider, child) {
        final isSplitEnabled = featureProvider.isFeatureEnabled('SPLIT');
        
        return ElevatedButton(
          onPressed: isSplitEnabled
              ? () => _showSplitDialog(context)
              : () => _showUpgradeDialog(context),
          child: Text(isSplitEnabled ? 'Split Expense' : 'Split (PRO)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSplitEnabled ? Colors.blue : Colors.grey,
          ),
        );
      },
    );
  }
  
  void _showSplitDialog(BuildContext context) {
    // Show split creation dialog
  }
  
  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade to PRO'),
        content: Text('The split feature is only available for PRO users.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/upgrade');
            },
            child: Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}
```

### 4. Create Expense

```dart
Future<void> createExpense() async {
  final apiService = Provider.of<ApiService>(context, listen: false);
  
  try {
    final expense = await apiService.createExpense(
      amount: 100.50,
      category: 'Food',
      note: 'Lunch at restaurant',
      paymentMethod: 'UPI',
    );
    
    print('Expense created: ${expense['expenseId']}');
  } catch (e) {
    print('Error: $e');
  }
}
```

## 🔧 Environment Configuration

Create `lib/config/env.dart`:

```dart
class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000', // Development
  );
  
  // For production:
  // static const String apiBaseUrl = 'https://api.your-domain.com';
}
```

Update ApiService:

```dart
static const String baseUrl = Env.apiBaseUrl;
```

## 🎯 Error Handling

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

// In ApiService:
Future<T> _handleResponse<T>(http.Response response) async {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    return jsonDecode(response.body);
  } else if (response.statusCode == 401) {
    await logout(); // Token expired
    throw ApiException('Session expired. Please login again.', 401);
  } else if (response.statusCode == 403) {
    throw ApiException('Access denied. Upgrade required.', 403);
  } else {
    throw ApiException(
      'Request failed: ${response.body}',
      response.statusCode,
    );
  }
}
```

## 📱 Testing

1. **Start Backend**:
   ```bash
   cd backend
   npm run start:dev
   ```

2. **Start Flutter App**:
   ```bash
   cd expense-tracker
   flutter run
   ```

3. **Test Authentication**:
   - Register new user
   - Login
   - Check features loaded

4. **Test Feature Flags**:
   - Try using split feature (should fail for FREE)
   - Use admin API to enable split for FREE
   - Try again (should work)

## 🚀 Production Checklist

- [ ] Update `apiBaseUrl` to production URL
- [ ] Implement token refresh logic
- [ ] Add proper error handling
- [ ] Add loading states
- [ ] Implement offline support
- [ ] Add analytics tracking
- [ ] Test on real devices
- [ ] Implement secure storage for tokens

---

**Your Flutter app is now connected to a production-grade SaaS backend!** 🎉
