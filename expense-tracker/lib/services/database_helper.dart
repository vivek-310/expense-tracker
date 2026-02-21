import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Incremented version for migration
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        category $textType,
        amount $doubleType,
        merchantName $textTypeNullable,
        upiId $textTypeNullable,
        date $textType,
        notes $textTypeNullable
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        categoryId $textType,
        name $textType,
        icon $textType,
        color $intType,
        isCustom $intType
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add categories table for version 2
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const intType = 'INTEGER NOT NULL';
      
      await db.execute('''
        CREATE TABLE categories (
          id $idType,
          categoryId $textType,
          name $textType,
          icon $textType,
          color $intType,
          isCustom $intType
        )
      ''');
    }
  }

  // Create - Insert new expense
  Future<Expense> create(Expense expense) async {
    final db = await instance.database;
    final id = await db.insert('expenses', expense.toMap());
    return expense.copyWith(id: id);
  }

  // Read - Get expense by ID
  Future<Expense?> readExpense(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'expenses',
      columns: ['id', 'category', 'amount', 'merchantName', 'upiId', 'date', 'notes'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Read - Get all expenses
  Future<List<Expense>> readAllExpenses() async {
    final db = await instance.database;
    const orderBy = 'date DESC';
    final result = await db.query('expenses', orderBy: orderBy);
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  // Read - Get expenses by category
  Future<List<Expense>> readExpensesByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  // Read - Get expenses by date range
  Future<List<Expense>> readExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await instance.database;
    final result = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  // Update - Update existing expense
  Future<int> update(Expense expense) async {
    final db = await instance.database;
    return db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Delete - Delete expense by ID
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Analytics - Get total spending
  Future<double> getTotalSpending() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM expenses');
    return result.first['total'] as double? ?? 0.0;
  }

  // Analytics - Get total spending by category
  Future<Map<String, double>> getSpendingByCategory() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM expenses GROUP BY category'
    );
    
    Map<String, double> categoryTotals = {};
    for (var row in result) {
      categoryTotals[row['category'] as String] = row['total'] as double;
    }
    return categoryTotals;
  }

  // Analytics - Get spending for date range
  Future<double> getSpendingForDateRange(DateTime start, DateTime end) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date BETWEEN ? AND ?',
      [start.toIso8601String(), end.toIso8601String()]
    );
    return result.first['total'] as double? ?? 0.0;
  }

  // ============ CATEGORY OPERATIONS ============
  
  // Create - Insert new custom category
  Future<Category> createCategory(Category category) async {
    final db = await instance.database;
    final id = await db.insert('categories', category.toMap());
    return Category(
      dbId: id,
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
      isCustom: true,
    );
  }

  // Read - Get all custom categories
  Future<List<Category>> readAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories', where: 'isCustom = ?', whereArgs: [1]);
    return result.map((json) => Category.fromMap(json)).toList();
  }

  // Read - Get category by ID
  Future<Category?> readCategory(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Update - Update existing category
  Future<int> updateCategory(Category category) async {
    final db = await instance.database;
    return db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.dbId],
    );
  }

  // Delete - Delete category by ID
  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
