import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/split_model.dart';
import '../providers/expense_provider.dart';
import '../services/split_api_service.dart';
import 'create_split_screen.dart';

class SplitsScreen extends StatefulWidget {
  const SplitsScreen({Key? key}) : super(key: key);

  @override
  State<SplitsScreen> createState() => _SplitsScreenState();
}

class _SplitsScreenState extends State<SplitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ExpenseSplit> _splits = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllSplits();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSplits() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final expenses = context.read<ExpenseProvider>().expenses;
      final List<ExpenseSplit> allSplits = [];
      for (final expense in expenses) {
        if (expense.expenseId != null) {
          try {
            final split =
                await SplitApiService.getSplitsByExpense(expense.expenseId!);
            if (split != null) allSplits.add(split);
          } catch (_) {}
        }
      }
      if (mounted) {
        setState(() {
          _splits = allSplits;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  double _totalOwedToMe() {
    return _splits.fold(0.0, (sum, split) {
      final unsettled = split.splits.where((s) => !s.settled);
      return sum + unsettled.fold(0.0, (s, d) => s + d.amount);
    });
  }

  Future<void> _settle(String expenseId, String friendId) async {
    try {
      await SplitApiService.settleSplit(expenseId, friendId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Settled successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        _loadAllSplits();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to settle: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  List<_SplitEntry> get _unsettledEntries {
    final entries = <_SplitEntry>[];
    for (final split in _splits) {
      for (final detail in split.splits) {
        if (!detail.settled) {
          entries.add(_SplitEntry(
            expenseId: split.expenseId,
            detail: detail,
            totalAmount: split.totalAmount,
          ));
        }
      }
    }
    return entries;
  }

  List<_SplitEntry> get _settledEntries {
    final entries = <_SplitEntry>[];
    for (final split in _splits) {
      for (final detail in split.splits) {
        if (detail.settled) {
          entries.add(_SplitEntry(
            expenseId: split.expenseId,
            detail: detail,
            totalAmount: split.totalAmount,
          ));
        }
      }
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Expenses'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: const Color(0xFF94A3B8),
          tabs: const [
            Tab(text: 'They Owe Me'),
            Tab(text: 'Settled'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSplit,
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Split',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    _buildSummaryCard(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSplitList(_unsettledEntries, settled: false),
                          _buildSplitList(_settledEntries, settled: true),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSummaryCard() {
    final total = _totalOwedToMe();
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet,
              color: Colors.white70, size: 36),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Pending',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_unsettledEntries.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'pending',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSplitList(List<_SplitEntry> entries, {required bool settled}) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              settled ? Icons.check_circle_outline : Icons.handshake_outlined,
              size: 64,
              color: const Color(0xFF475569),
            ),
            const SizedBox(height: 16),
            Text(
              settled ? 'No settled splits yet' : 'No pending splits 🎉',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
            ),
            if (!settled) ...[
              const SizedBox(height: 8),
              const Text(
                'Tap + New Split to split an expense',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllSplits,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _buildSplitCard(entry, settled: settled);
        },
      ),
    );
  }

  Widget _buildSplitCard(_SplitEntry entry, {required bool settled}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: settled
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFF334155),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: settled
                  ? const Color(0xFF10B981).withOpacity(0.15)
                  : const Color(0xFF6366F1).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.detail.friendName.isNotEmpty
                    ? entry.detail.friendName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: settled
                      ? const Color(0xFF10B981)
                      : const Color(0xFF6366F1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.detail.friendName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expense: ₹${entry.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${entry.detail.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: settled
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF97316),
                ),
              ),
              const SizedBox(height: 6),
              if (!settled)
                GestureDetector(
                  onTap: () =>
                      _settle(entry.expenseId, entry.detail.friendId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Settle',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                const Text(
                  '✓ Settled',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 64, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(
            'Failed to load splits',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadAllSplits,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _openCreateSplit() async {
    final expenses = context.read<ExpenseProvider>().expenses;
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateSplitSheet(expenses: expenses),
    );
    if (created == true) {
      _loadAllSplits();
    }
  }
}

class _SplitEntry {
  final String expenseId;
  final ExpenseSplitDetail detail;
  final double totalAmount;

  _SplitEntry({
    required this.expenseId,
    required this.detail,
    required this.totalAmount,
  });
}
