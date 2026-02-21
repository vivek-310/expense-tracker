import '../config/api_config.dart';
import '../models/expense_model.dart';
import 'api_service.dart';

class ExpenseApiService {
  // Create expense
  static Future<Expense> createExpense(Expense expense) async {
    final body = <String, dynamic>{
      'amount': expense.amount,
      'category': expense.category,
      'paymentMethod': expense.paymentMethod ?? 'UPI',
      // Don't send date - backend generates it automatically
    };

    // Add optional fields only if they're not null
    if (expense.note != null && expense.note!.isNotEmpty) {
      body['note'] = expense.note!;
    }
    if (expense.merchantName != null && expense.merchantName!.isNotEmpty) {
      body['merchantName'] = expense.merchantName!;
    }
    if (expense.upiId != null && expense.upiId!.isNotEmpty) {
      body['upiId'] = expense.upiId!;
    }

    final response = await ApiService.post(ApiConfig.expenses, body);
    return Expense.fromApiJson(response);
  }

  // Get all expenses
  static Future<List<Expense>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String endpoint = ApiConfig.expenses;
    
    if (startDate != null || endDate != null) {
      final queryParams = <String>[];
      if (startDate != null) {
        queryParams.add('startDate=${startDate.toIso8601String()}');
      }
      if (endDate != null) {
        queryParams.add('endDate=${endDate.toIso8601String()}');
      }
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await ApiService.get(endpoint);
    final List<dynamic> expensesJson = response['expenses'] ?? response;
    return expensesJson.map((json) => Expense.fromApiJson(json)).toList();
  }

  // Update expense
  static Future<Expense> updateExpense(String expenseId, Expense expense) async {
    final response = await ApiService.patch(
      '${ApiConfig.expenses}/$expenseId',
      {
        'amount': expense.amount,
        'category': expense.category,
        'note': expense.note,
        'paymentMethod': expense.paymentMethod,
        'date': expense.date.toIso8601String(),
      },
    );

    return Expense.fromApiJson(response);
  }

  // Delete expense
  static Future<void> deleteExpense(String expenseId) async {
    await ApiService.delete('${ApiConfig.expenses}/$expenseId');
  }
}
