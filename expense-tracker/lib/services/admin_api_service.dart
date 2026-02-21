import '../config/api_config.dart';
import 'api_service.dart';

class AdminApiService {
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
