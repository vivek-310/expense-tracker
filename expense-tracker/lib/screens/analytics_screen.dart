import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';

class AnalyticsScreen extends StatelessWidget {
  final DateTime? selectedMonth;
  
  const AnalyticsScreen({Key? key, this.selectedMonth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedMonth != null 
            ? DateFormat('MMMM yyyy').format(selectedMonth!)
            : 'Analytics'),
      ),
      body: Consumer2<ExpenseProvider, CategoryProvider>(
        builder: (context, expenseProvider, categoryProvider, child) {
          if (expenseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Get data for specific month or current month
          final month = selectedMonth ?? DateTime.now();
          final categorySpending = expenseProvider.getCategorySpendingForMonth(month);
          final personalSpending = expenseProvider.getSpendingForMonth(month);
          final grossSpending = expenseProvider.getGrossSpendingForMonth(month);
          final monthExpenses = expenseProvider.getExpensesForMonth(month);
          final splitExpenses = expenseProvider.getSplitExpensesForMonth(month);
          final friendBreakdown = expenseProvider.getFriendWiseBreakdownForMonth(month);

          if (monthExpenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bar_chart,
                    size: 64,
                    color: Color(0xFF475569),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data for this month',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                  ),
                ],
              ),
            );
          }

          // Calculate split summary for this month
          double monthUnsettled = 0;
          double monthSettled = 0;
          for (final e in splitExpenses) {
            monthUnsettled += e.splitInfo!.unsettledTotal;
            monthSettled += e.splitInfo!.settledTotal;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── SPENDING SUMMARY CARDS ──────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        'Your Spending',
                        '₹${personalSpending.toStringAsFixed(2)}',
                        Icons.account_balance_wallet,
                        const Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        'Total Transacted',
                        '₹${grossSpending.toStringAsFixed(2)}',
                        Icons.receipt_long,
                        const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        'Transactions',
                        '${monthExpenses.length}',
                        Icons.swap_horiz,
                        const Color(0xFF0EA5E9),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        'Split Expenses',
                        '${splitExpenses.length}',
                        Icons.call_split,
                        const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ─── PIE CHART ────────────────────────────────────
                Text(
                  'Spending by Category',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on your personal share',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  height: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  child: categorySpending.isEmpty
                      ? const Center(
                          child: Text('No category data available'),
                        )
                      : PieChart(
                          PieChartData(
                            sections: _buildPieChartSections(categorySpending, categoryProvider),
                            sectionsSpace: 2,
                            centerSpaceRadius: 60,
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // ─── CATEGORY BREAKDOWN LIST ──────────────────────
                Text(
                  'Category Breakdown',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),

                ...categorySpending.entries.map((entry) {
                  final category = categoryProvider.getCategoryById(entry.key);
                  final percentage =
                      personalSpending > 0
                          ? (entry.value / personalSpending * 100).toStringAsFixed(1)
                          : '0.0';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(category?.color ?? 0xFF6366F1),
                                Color(category?.color ?? 0xFF6366F1)
                                    .withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              category?.icon ?? '📦',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category?.name ?? 'Others',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$percentage% of total',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${entry.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                // ─── SPLIT SETTLEMENTS SECTION ───────────────────
                if (splitExpenses.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Split Settlements',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For ${DateFormat('MMMM yyyy').format(month)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Settled vs Unsettled summary
                  Row(
                    children: [
                      Expanded(
                        child: _buildSettlementCard(
                          context,
                          'Owed to You',
                          '₹${monthUnsettled.toStringAsFixed(2)}',
                          Icons.arrow_downward,
                          const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSettlementCard(
                          context,
                          'Settled',
                          '₹${monthSettled.toStringAsFixed(2)}',
                          Icons.check_circle,
                          const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Friend-wise breakdown
                  Text(
                    'Friend Breakdown',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  ...friendBreakdown.entries.map((entry) {
                    final friendName = entry.key;
                    final owed = entry.value['owed'] ?? 0.0;
                    final settled = entry.value['settled'] ?? 0.0;
                    final total = owed + settled;
                    final settledPercent = total > 0 ? settled / total : 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    friendName.isNotEmpty ? friendName[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      color: Color(0xFF6366F1),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  friendName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (owed > 0)
                                    Text(
                                      'Owes ₹${owed.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFF59E0B),
                                      ),
                                    ),
                                  if (settled > 0)
                                    Text(
                                      'Paid ₹${settled.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: settledPercent,
                              backgroundColor: const Color(0xFFF59E0B).withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(settledPercent * 100).toStringAsFixed(0)}% settled',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],

                // ─── ALL TIME SPLIT OVERVIEW ─────────────────────
                const SizedBox(height: 32),
                _buildAllTimeSplitOverview(context, expenseProvider),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllTimeSplitOverview(BuildContext context, ExpenseProvider provider) {
    final allFriends = provider.getFriendWiseBreakdown();
    if (allFriends.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All-Time Split Overview',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSettlementCard(
                context,
                'Total Owed',
                '₹${provider.totalUnsettled.toStringAsFixed(2)}',
                Icons.hourglass_bottom,
                const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSettlementCard(
                context,
                'Total Received',
                '₹${provider.totalSettled.toStringAsFixed(2)}',
                Icons.check_circle_outline,
                const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...allFriends.entries.map((entry) {
          final friendName = entry.key;
          final owed = entry.value['owed'] ?? 0.0;
          final settled = entry.value['settled'] ?? 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      friendName.isNotEmpty ? friendName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    friendName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                if (owed > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${owed.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                if (settled > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '✓ ₹${settled.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      Map<String, double> categorySpending, CategoryProvider categoryProvider) {
    final total =
        categorySpending.values.fold(0.0, (sum, amount) => sum + amount);

    return categorySpending.entries.map((entry) {
      final category = categoryProvider.getCategoryById(entry.key);
      final percentage = total > 0 ? (entry.value / total * 100) : 0.0;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: Color(category?.color ?? 0xFF6366F1),
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
