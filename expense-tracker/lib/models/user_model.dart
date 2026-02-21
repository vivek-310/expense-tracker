class User {
  final String userId;
  final String email;
  final String? name;
  final String? phone;
  final String currentPlan;
  final String role;
  final String status;

  User({
    required this.userId,
    required this.email,
    this.name,
    this.phone,
    required this.currentPlan,
    required this.role,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      currentPlan: json['currentPlan']?.toString() ?? 'FREE',
      role: json['role']?.toString() ?? 'USER',
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'phone': phone,
      'currentPlan': currentPlan,
      'role': role,
      'status': status,
    };
  }
}
