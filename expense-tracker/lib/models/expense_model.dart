class ExpenseSplitItem {
  final String friendId;
  final String friendName;
  final double amount;
  final bool settled;

  ExpenseSplitItem({
    required this.friendId,
    required this.friendName,
    required this.amount,
    required this.settled,
  });

  factory ExpenseSplitItem.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitItem(
      friendId: json['friendId']?.toString() ?? '',
      friendName: json['friendName']?.toString() ?? 'Unknown',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      settled: json['settled'] as bool? ?? false,
    );
  }
}

class ExpenseSplitInfo {
  final double totalAmount;
  final List<ExpenseSplitItem> splits;

  ExpenseSplitInfo({
    required this.totalAmount,
    required this.splits,
  });

  factory ExpenseSplitInfo.fromJson(Map<String, dynamic> json) {
    final splitsJson = json['splits'] as List<dynamic>? ?? [];
    return ExpenseSplitInfo(
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      splits: splitsJson
          .map((s) => ExpenseSplitItem.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Total amount friends owe
  double get friendsTotal => splits.fold(0.0, (sum, s) => sum + s.amount);

  /// Total unsettled (still owed to user)
  double get unsettledTotal =>
      splits.where((s) => !s.settled).fold(0.0, (sum, s) => sum + s.amount);

  /// Total settled (already paid back)
  double get settledTotal =>
      splits.where((s) => s.settled).fold(0.0, (sum, s) => sum + s.amount);
}

class Expense {
  final int? id; // Local DB ID
  final String? expenseId; // Backend API ID
  final String category;
  final double amount;
  final String? merchantName;
  final String? upiId;
  final DateTime date;
  final String? note; // Changed from 'notes' to match backend
  final String? paymentMethod; // Added for backend
  final ExpenseSplitInfo? splitInfo; // Split data from backend

  Expense({
    this.id,
    this.expenseId,
    required this.category,
    required this.amount,
    this.merchantName,
    this.upiId,
    required this.date,
    this.note,
    this.paymentMethod,
    this.splitInfo,
  });

  /// The user's personal share of this expense.
  /// If the expense is NOT split, this equals the full amount.
  /// If the expense IS split, this is: totalAmount - sum(all friend shares).
  double get personalShare {
    if (splitInfo == null) return amount;
    return amount - splitInfo!.friendsTotal;
  }

  /// Whether this expense has been split with friends
  bool get isSplit => splitInfo != null;

  // Convert Expense to Map for local database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'merchantName': merchantName,
      'upiId': upiId,
      'date': date.toIso8601String(),
      'notes': note, // Keep 'notes' for local DB compatibility
    };
  }

  // Create Expense from Map (local database retrieval)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      category: map['category'],
      amount: map['amount'],
      merchantName: map['merchantName'],
      upiId: map['upiId'],
      date: DateTime.parse(map['date']),
      note: map['notes'], // Map 'notes' to 'note'
    );
  }

  // Create Expense from API JSON
  factory Expense.fromApiJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: json['expenseId']?.toString() ?? json['id']?.toString(),
      category: json['category']?.toString() ?? 'Other',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null 
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      note: json['note']?.toString(),
      merchantName: json['merchantName']?.toString(),
      upiId: json['upiId']?.toString(),
      paymentMethod: json['paymentMethod']?.toString() ?? 'UPI',
      splitInfo: json['split'] != null
          ? ExpenseSplitInfo.fromJson(json['split'] as Map<String, dynamic>)
          : null,
    );
  }

  // Copy with method for updating expense
  Expense copyWith({
    int? id,
    String? expenseId,
    String? category,
    double? amount,
    String? merchantName,
    String? upiId,
    DateTime? date,
    String? note,
    String? paymentMethod,
    ExpenseSplitInfo? splitInfo,
  }) {
    return Expense(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      merchantName: merchantName ?? this.merchantName,
      upiId: upiId ?? this.upiId,
      date: date ?? this.date,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      splitInfo: splitInfo ?? this.splitInfo,
    );
  }
}
