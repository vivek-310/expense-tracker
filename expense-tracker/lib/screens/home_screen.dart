import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/category_model.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/expense_tile.dart';
import 'add_expense_screen.dart';
import 'expense_history_screen.dart';
import 'monthly_analytics_screen.dart';
import 'add_category_screen.dart';
import 'profile_screen.dart';
import 'splits_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load expenses and custom categories when screen initializes
    Future.microtask(() {
      context.read<ExpenseProvider>().loadExpenses();
      context.read<CategoryProvider>().loadCustomCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UPI Tracker',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMM dd').format(DateTime.now()),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Consumer<ThemeProvider>(
                              builder: (context, themeProvider, child) {
                                return IconButton(
                                  icon: Icon(
                                    themeProvider.isDarkMode 
                                        ? Icons.light_mode_outlined 
                                        : Icons.dark_mode_outlined,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    themeProvider.toggleTheme();
                                  },
                                  tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.bar_chart_rounded, size: 28),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MonthlyAnalyticsScreen(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.people_outline, size: 28),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SplitsScreen(),
                                  ),
                                );
                              },
                              tooltip: 'Split Expenses',
                            ),
                            IconButton(
                              icon: const Icon(Icons.account_circle_outlined, size: 28),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              },
                              tooltip: 'Profile',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Spending Summary
            SliverToBoxAdapter(
              child: Consumer<ExpenseProvider>(
                builder: (context, provider, child) {
                  final personalSpending = provider.getMonthSpending();
                  final grossSpending = provider.getMonthGrossSpending();
                  final hasSplits = personalSpending != grossSpending;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Spending',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${personalSpending.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (hasSplits) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Total transacted: ₹${grossSpending.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  'Today',
                                  '₹${provider.getTodaySpending().toStringAsFixed(0)}',
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white24,
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  'Week',
                                  '₹${provider.getWeekSpending().toStringAsFixed(0)}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Categories Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddCategoryScreen(),
                              ),
                            ).then((_) {
                              // Reload categories after adding new one
                              context.read<CategoryProvider>().loadCustomCategories();
                            });
                          },
                          tooltip: 'Add custom category',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<CategoryProvider>(
                      builder: (context, categoryProvider, child) {
                        final allCategories = categoryProvider.allCategories;
                        
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.3,
                          ),
                          itemCount: allCategories.length,
                          itemBuilder: (context, index) {
                            final category = allCategories[index];
                            return CategoryCard(
                              category: category,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddExpenseScreen(
                                      selectedCategory: category,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Recent Transactions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExpenseHistoryScreen(),
                          ),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Expenses List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              sliver: Consumer<ExpenseProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final recentExpenses = provider.expenses.take(5).toList();

                  if (recentExpenses.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: Color(0xFF475569),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No expenses yet',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: const Color(0xFF94A3B8),
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap a category to add your first expense',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expense = recentExpenses[index];
                        return ExpenseTile(
                          expense: expense,
                        );
                      },
                      childCount: recentExpenses.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
