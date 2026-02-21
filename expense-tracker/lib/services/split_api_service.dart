import '../config/api_config.dart';
import '../models/split_model.dart';
import 'api_service.dart';

class SplitApiService {
  // Create a new split — backend returns the created Split object
  static Future<ExpenseSplit> createSplit(
    String expenseId,
    List<ExpenseSplitDetail> splits,
  ) async {
    final response = await ApiService.post(
      ApiConfig.splits,
      {
        'expenseId': expenseId,
        'splits': splits.map((s) => s.toJson()).toList(),
      },
    );

    return ExpenseSplit.fromJson(response as Map<String, dynamic>);
  }

  // Get split for an expense — backend returns a single Split object or null
  static Future<ExpenseSplit?> getSplitsByExpense(String expenseId) async {
    try {
      final response = await ApiService.get('${ApiConfig.splits}/$expenseId');
      if (response == null) return null;
      return ExpenseSplit.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // Settle a split
  static Future<void> settleSplit(String expenseId, String friendId) async {
    await ApiService.patch(
      '${ApiConfig.splits}/$expenseId/$friendId/settle',
      {},
    );
  }
}
