class AdminUser {
  final String userId;
  final String email;
  final String? name;
  final String currentPlan;
  final String role;
  final String status;
  final double totalExpense;
  final String createdAt;

  AdminUser({
    required this.userId,
    required this.email,
    this.name,
    required this.currentPlan,
    required this.role,
    required this.status,
    required this.totalExpense,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      currentPlan: json['currentPlan'] ?? 'FREE',
      role: json['role'] ?? 'USER',
      status: json['status'] ?? 'ACTIVE',
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
