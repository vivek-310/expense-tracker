import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Avatar
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user.name?.isNotEmpty == true
                              ? user.name![0].toUpperCase()
                              : (user.email.isNotEmpty 
                                  ? user.email[0].toUpperCase()
                                  : 'U'),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User Name
                  Text(
                    user.name ?? 'User',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // User Email
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // User Details Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF334155)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          context,
                          'User ID',
                          user.userId,
                          Icons.fingerprint,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          context,
                          'Plan',
                          user.currentPlan.toUpperCase(),
                          Icons.workspace_premium,
                          highlightColor: user.currentPlan == 'PRO'
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981),
                        ),
                        const SizedBox(height: 20),

                        // Plan Switcher (demo account only)
                        if (user.email == 'test@gmail.com')
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF6366F1).withOpacity(0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.swap_horiz_rounded,
                                    color: const Color(0xFF6366F1),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Switch Plan',
                                    style: TextStyle(
                                      color: const Color(0xFF6366F1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Demo',
                                      style: TextStyle(
                                        color: Color(0xFF6366F1),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Try PRO features instantly',
                                style: TextStyle(
                                    color: Color(0xFF64748B), fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: ['FREE', 'PRO'].map((plan) {
                                  final isSelected =
                                      user.currentPlan.toUpperCase() == plan;
                                  final isPro = plan == 'PRO';
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right: plan == 'FREE' ? 8 : 0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          if (!isSelected) {
                                            await _changePlan(
                                                context, user.userId, plan);
                                          }
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          decoration: BoxDecoration(
                                            gradient: isSelected
                                                ? LinearGradient(
                                                    colors: isPro
                                                        ? [
                                                            const Color(
                                                                0xFFF59E0B),
                                                            const Color(
                                                                0xFFD97706),
                                                          ]
                                                        : [
                                                            const Color(
                                                                0xFF10B981),
                                                            const Color(
                                                                0xFF059669),
                                                          ],
                                                  )
                                                : null,
                                            color: isSelected
                                                ? null
                                                : const Color(0xFF0F172A),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.transparent
                                                  : const Color(0xFF334155),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                isPro
                                                    ? Icons.workspace_premium
                                                    : Icons.account_circle,
                                                color: isSelected
                                                    ? Colors.white
                                                    : const Color(0xFF64748B),
                                                size: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                plan,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : const Color(0xFF94A3B8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildDetailRow(
                          context,
                          'Role',
                          user.role.toUpperCase(),
                          Icons.admin_panel_settings,
                          highlightColor: user.role == 'ADMIN'
                              ? const Color(0xFFEF4444)
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          context,
                          'Status',
                          user.status.toUpperCase(),
                          Icons.check_circle,
                          highlightColor: user.status == 'ACTIVE'
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        // Logout - clear auth and navigate to login
                        await context.read<AuthProvider>().logout();
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Logged out successfully'),
                              backgroundColor: Color(0xFF10B981),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          
                          // Explicitly navigate to login screen and remove all previous routes
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // App Info
                  Text(
                    'Expense Tracker v1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? highlightColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (highlightColor ?? const Color(0xFF6366F1)).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: highlightColor ?? const Color(0xFF6366F1),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: highlightColor,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Change plan using self-service subscriptions API (works for all users)
  Future<void> _changePlan(BuildContext context, String userId, String newPlan) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Switching to $newPlan plan...'),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF3B82F6),
          ),
        );
      }

      if (newPlan == 'PRO') {
        // Self-service: activate PRO
        await ApiService.post(
          ApiConfig.subscriptions + '/activate',
          {'plan': 'PRO', 'months': 12},
        );
      } else {
        // Self-service: cancel/downgrade to FREE
        await ApiService.post(ApiConfig.subscriptions + '/cancel', {});
      }

      if (context.mounted) {
        await context.read<AuthProvider>().checkAuthStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Switched to $newPlan successfully!'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
