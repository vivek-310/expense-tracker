class ExpenseSplitDetail {
  final String friendId;
  final String friendName;
  final double amount;
  final bool settled;

  ExpenseSplitDetail({
    required this.friendId,
    required this.friendName,
    required this.amount,
    required this.settled,
  });

  factory ExpenseSplitDetail.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitDetail(
      friendId: json['friendId']?.toString() ?? '',
      friendName: json['friendName']?.toString() ?? 'Unknown',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      settled: json['settled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'friendName': friendName,
      'amount': amount,
      // 'settled' is server-side only — do not send on create
    };
  }
}

class ExpenseSplit {
  final String expenseId;
  final String userId;
  final double totalAmount;
  final List<ExpenseSplitDetail> splits;

  ExpenseSplit({
    required this.expenseId,
    required this.userId,
    required this.totalAmount,
    required this.splits,
  });

  factory ExpenseSplit.fromJson(Map<String, dynamic> json) {
    final splitsJson = json['splits'] as List<dynamic>? ?? [];
    return ExpenseSplit(
      expenseId: json['expenseId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      splits: splitsJson.map((s) => ExpenseSplitDetail.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'userId': userId,
      'totalAmount': totalAmount,
      'splits': splits.map((s) => s.toJson()).toList(),
    };
  }
}
