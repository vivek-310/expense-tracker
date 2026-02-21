import 'package:flutter/foundation.dart' hide Category;
import '../models/category_model.dart';
import '../services/database_helper.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _customCategories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get customCategories => _customCategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get all categories (predefined + custom)
  List<Category> get allCategories {
    return [...Category.predefinedCategories, ..._customCategories];
  }

  // Load all custom categories from database
  Future<void> loadCustomCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _customCategories = await DatabaseHelper.instance.readAllCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new custom category
  Future<void> addCategory(Category category) async {
    try {
      final newCategory = await DatabaseHelper.instance.createCategory(category);
      _customCategories.add(newCategory);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add category: $e';
      notifyListeners();
    }
  }

  // Update custom category
  Future<void> updateCategory(Category category) async {
    try {
      await DatabaseHelper.instance.updateCategory(category);
      final index = _customCategories.indexWhere((c) => c.dbId == category.dbId);
      if (index != -1) {
        _customCategories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update category: $e';
      notifyListeners();
    }
  }

  // Delete custom category
  Future<void> deleteCategory(int id) async {
    try {
      await DatabaseHelper.instance.deleteCategory(id);
      _customCategories.removeWhere((category) => category.dbId == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete category: $e';
      notifyListeners();
    }
  }

  // Get category by ID (checks both predefined and custom)
  Category? getCategoryById(String id) {
    return Category.getCategoryById(id, _customCategories);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
