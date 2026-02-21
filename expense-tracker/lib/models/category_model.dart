class Category {
  final int? dbId; // Database ID for custom categories
  final String id;
  final String name;
  final String icon;
  final int color;
  final bool isCustom;

  Category({
    this.dbId,
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isCustom = false,
  });

  // Convert Category to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': dbId,
      'categoryId': id,
      'name': name,
      'icon': icon,
      'color': color,
      'isCustom': isCustom ? 1 : 0,
    };
  }

  // Create Category from Map (database retrieval)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      dbId: map['id'],
      id: map['categoryId'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      isCustom: map['isCustom'] == 1,
    );
  }

  // Predefined categories
  static final List<Category> predefinedCategories = [
    Category(
      id: 'food',
      name: 'Food',
      icon: '🍔',
      color: 0xFFFF6B6B,
    ),
    Category(
      id: 'travel',
      name: 'Travel',
      icon: '✈️',
      color: 0xFF4ECDC4,
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: '🎬',
      color: 0xFFFFE66D,
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      icon: '🛍️',
      color: 0xFF95E1D3,
    ),
    Category(
      id: 'bills',
      name: 'Bills',
      icon: '📄',
      color: 0xFFF38181,
    ),
    Category(
      id: 'others',
      name: 'Others',
      icon: '📦',
      color: 0xFFAA96DA,
    ),
  ];

  // Get category by ID (checks both predefined and custom)
  static Category? getCategoryById(String id, [List<Category>? customCategories]) {
    // Check predefined categories first
    try {
      return predefinedCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      // If not found in predefined, check custom categories
      if (customCategories != null) {
        try {
          return customCategories.firstWhere((cat) => cat.id == id);
        } catch (e) {
          return null;
        }
      }
      return null;
    }
  }
}
