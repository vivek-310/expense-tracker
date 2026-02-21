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

  // Calculate total spending
  double getTotalSpending() {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Calculate total for today
  double getTodaySpending() {
    return getTodayExpenses().fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Calculate total for week
  double getWeekSpending() {
    return getWeekExpenses().fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Calculate total for month
  double getMonthSpending() {
    return getMonthExpenses().fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get spending by category
  Map<String, double> getSpendingByCategory() {
    Map<String, double> categoryTotals = {};
    
    for (var expense in _expenses) {
      categoryTotals[expense.category] = 
        (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    return categoryTotals;
  }

  // Get all months that have expenses (for monthly analysis)
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

  // Get expenses for a specific month
  List<Expense> getExpensesForMonth(DateTime month) {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 1);
    
    return _expenses.where((expense) {
      return expense.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
             expense.date.isBefore(monthEnd);
    }).toList();
  }

  // Get spending by month
  Map<DateTime, double> getSpendingByMonth() {
    Map<DateTime, double> monthlySpending = {};
    
    for (var expense in _expenses) {
      final monthKey = DateTime(expense.date.year, expense.date.month, 1);
      monthlySpending[monthKey] = (monthlySpending[monthKey] ?? 0) + expense.amount;
    }
    
    return monthlySpending;
  }

  // Get category breakdown for a specific month
  Map<String, double> getCategorySpendingForMonth(DateTime month) {
    final monthExpenses = getExpensesForMonth(month);
    Map<String, double> categoryTotals = {};
    
    for (var expense in monthExpenses) {
      categoryTotals[expense.category] = 
        (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    return categoryTotals;
  }

  // Get total spending for a specific month
  double getSpendingForMonth(DateTime month) {
    return getExpensesForMonth(month).fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
