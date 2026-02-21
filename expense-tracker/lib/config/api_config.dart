class ApiConfig {
  // Backend API base URL
  // For mobile testing, use your computer's local IP address
  // Find your IP: Open CMD and type `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
  // Example: static const String baseUrl = 'http://192.168.1.100:3000';
  
  // static const String baseUrl = 'http://192.168.1.39:3000'; // Your computer's IP (won't work due to AP Isolation)
  static const String baseUrl = 'http://localhost:3000'; // Using ADB port forwarding
  
  // API endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';
  
  static const String expenses = '/expenses';
  static const String features = '/features';
  static const String subscriptions = '/subscriptions';
  static const String splits = '/splits';
  static const String admin = '/admin';
}
