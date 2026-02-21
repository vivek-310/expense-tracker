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
  });

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
    );
  }
}
