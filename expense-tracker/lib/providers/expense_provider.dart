import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../services/expense_api_service.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all expenses from API
  Future<void> loadExpenses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await ExpenseApiService.getExpenses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load expenses: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new expense
  Future<void> addExpense(Expense expense) async {
    try {
      await ExpenseApiService.createExpense(expense);
      // Reload all expenses from backend to ensure sync
      await loadExpenses();
    } catch (e) {
      _errorMessage = 'Failed to add expense: $e';
      notifyListeners();
      rethrow; // Rethrow so UI can show error
    }
  }

  // Update expense
  Future<void> updateExpense(Expense expense) async {
    try {
      if (expense.expenseId == null) {
        throw Exception('Expense ID is required for update');
      }
      await ExpenseApiService.updateExpense(expense.expenseId!, expense);
      final index = _expenses.indexWhere((e) => e.expenseId == expense.expenseId);
      if (index != -1) {
        _expenses[index] = expense;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update expense: $e';
      notifyListeners();
    }
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await ExpenseApiService.deleteExpense(expenseId);
      _expenses.removeWhere((expense) => expense.expenseId == expenseId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete expense: $e';
      notifyListeners();
    }
  }

  // Get expenses by category
  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  // Get expenses for today
  List<Expense> getTodayExpenses() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _expenses.where((expense) {
      return expense.date.isAfter(today) && expense.date.isBefore(tomorrow);
    }).toList();
  }

  // Get expenses for current week
  List<Expense> getWeekExpenses() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    return _expenses.where((expense) {
      return expense.date.isAfter(weekStartDay);
    }).toList();
  }

  // Get expenses for current month
  List<Expense> getMonthExpenses() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    return _expenses.where((expense) {
      return expense.date.isAfter(monthStart);
    }).toList();
  }

  // ─── PERSONAL SHARE SPENDING (only your share after splits) ───────────

  /// Total of YOUR SHARE across ALL expenses ever
  double getTotalSpending() {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.personalShare);
  }

  /// Your share spent today
  double getTodaySpending() {
    return getTodayExpenses().fold(0.0, (sum, expense) => sum + expense.personalShare);
  }

  /// Your share spent this week
  double getWeekSpending() {
    return getWeekExpenses().fold(0.0, (sum, expense) => sum + expense.personalShare);
  }

  /// Your share spent this month
  double getMonthSpending() {
    return getMonthExpenses().fold(0.0, (sum, expense) => sum + expense.personalShare);
  }

  // ─── TOTAL (GROSS) SPENDING (full transaction amounts) ────────────────

  /// Sum of FULL AMOUNTS for the month (before splits)
  double getMonthGrossSpending() {
    return getMonthExpenses().fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Sum of FULL AMOUNTS for today
  double getTodayGrossSpending() {
    return getTodayExpenses().fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // ─── CATEGORY SPENDING ────────────────────────────────────────────────

  /// By-category spending using personalShare
  Map<String, double> getSpendingByCategory() {
    Map<String, double> categoryTotals = {};
    
    for (var expense in _expenses) {
      categoryTotals[expense.category] = 
        (categoryTotals[expense.category] ?? 0) + expense.personalShare;
    }
    
    return categoryTotals;
  }

  // ─── MONTH-BASED ANALYTICS ────────────────────────────────────────────

  /// All unique months that have expenses
  List<DateTime> getMonthsWithExpenses() {
    Set<String> monthKeys = {};
    List<DateTime> months = [];
    
    for (var expense in _expenses) {
      final monthKey = '${expense.date.year}-${expense.date.month}';
      if (!monthKeys.contains(monthKey)) {
        monthKeys.add(monthKey);
        months.add(DateTime(expense.date.year, expense.date.month, 1));
      }
    }
    
    // Sort months in descending order (most recent first)
    months.sort((a, b) => b.compareTo(a));
    return months;
  }

  /// Expenses for a specific month
  List<Expense> getExpensesForMonth(DateTime month) {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 1);
    
    return _expenses.where((expense) {
      return expense.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
             expense.date.isBefore(monthEnd);
    }).toList();
  }

  /// Spending by month (personalShare)
  Map<DateTime, double> getSpendingByMonth() {
    Map<DateTime, double> monthlySpending = {};
    
    for (var expense in _expenses) {
      final monthKey = DateTime(expense.date.year, expense.date.month, 1);
      monthlySpending[monthKey] = (monthlySpending[monthKey] ?? 0) + expense.personalShare;
    }
    
    return monthlySpending;
  }

  /// Category breakdown for a specific month (personalShare)
  Map<String, double> getCategorySpendingForMonth(DateTime month) {
    final monthExpenses = getExpensesForMonth(month);
    Map<String, double> categoryTotals = {};
    
    for (var expense in monthExpenses) {
      categoryTotals[expense.category] = 
        (categoryTotals[expense.category] ?? 0) + expense.personalShare;
    }
    
    return categoryTotals;
  }

  /// Total personal spending for a specific month
  double getSpendingForMonth(DateTime month) {
    return getExpensesForMonth(month).fold(0.0, (sum, expense) => sum + expense.personalShare);
  }

  /// Total gross spending for a specific month (full amounts)
  double getGrossSpendingForMonth(DateTime month) {
    return getExpensesForMonth(month).fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // ─── SPLIT ANALYTICS ─────────────────────────────────────────────────

  /// Get all expenses that have been split
  List<Expense> get splitExpenses =>
      _expenses.where((e) => e.isSplit).toList();

  /// Get split expenses for a specific month
  List<Expense> getSplitExpensesForMonth(DateTime month) {
    return getExpensesForMonth(month).where((e) => e.isSplit).toList();
  }

  /// Total amount owed to the user (unsettled) — all time
  double get totalUnsettled {
    return splitExpenses.fold(0.0, (sum, e) => sum + e.splitInfo!.unsettledTotal);
  }

  /// Total amount already settled — all time
  double get totalSettled {
    return splitExpenses.fold(0.0, (sum, e) => sum + e.splitInfo!.settledTotal);
  }

  /// Friend-wise breakdown: { friendName: { 'owed': X, 'settled': Y } }
  Map<String, Map<String, double>> getFriendWiseBreakdown() {
    Map<String, Map<String, double>> result = {};

    for (final expense in splitExpenses) {
      for (final splitItem in expense.splitInfo!.splits) {
        final name = splitItem.friendName;
        result.putIfAbsent(name, () => {'owed': 0.0, 'settled': 0.0});

        if (splitItem.settled) {
          result[name]!['settled'] = result[name]!['settled']! + splitItem.amount;
        } else {
          result[name]!['owed'] = result[name]!['owed']! + splitItem.amount;
        }
      }
    }

    return result;
  }

  /// Friend-wise breakdown for a specific month
  Map<String, Map<String, double>> getFriendWiseBreakdownForMonth(DateTime month) {
    Map<String, Map<String, double>> result = {};
    final monthSplits = getSplitExpensesForMonth(month);

    for (final expense in monthSplits) {
      for (final splitItem in expense.splitInfo!.splits) {
        final name = splitItem.friendName;
        result.putIfAbsent(name, () => {'owed': 0.0, 'settled': 0.0});

        if (splitItem.settled) {
          result[name]!['settled'] = result[name]!['settled']! + splitItem.amount;
        } else {
          result[name]!['owed'] = result[name]!['owed']! + splitItem.amount;
        }
      }
    }

    return result;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
