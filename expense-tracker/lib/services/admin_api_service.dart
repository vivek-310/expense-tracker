import '../config/api_config.dart';
import 'api_service.dart';
import '../models/admin_user_model.dart';

class AdminApiService {
  // Fetch all users with their expenses
  static Future<List<AdminUser>> getAllUsers() async {
    final response = await ApiService.get(ApiConfig.adminUsers);
    
    // The backend endpoint returns an array of users directly based on our implementation
    final List<dynamic> usersJson = response is List ? response : response['users'] ?? [];

    return usersJson
        .map((json) => AdminUser.fromJson(json as Map<String, dynamic>))
        .toList();
  }
  // Activate user subscription (change plan)
  static Future<void> activateUserSubscription({
    required String userId,
    required String plan, // 'FREE' or 'PRO'
    int months = 12,
  }) async {
    await ApiService.post(
      '${ApiConfig.admin}/subscriptions/activate',
      {
        'userId': userId,
        'plan': plan,
        'months': months,
      },
    );
  }
}
