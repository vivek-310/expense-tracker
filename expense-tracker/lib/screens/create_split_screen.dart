import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense_model.dart';
import '../models/split_model.dart';
import '../services/split_api_service.dart';

class CreateSplitSheet extends StatefulWidget {
  final List<Expense> expenses;

  const CreateSplitSheet({Key? key, required this.expenses}) : super(key: key);

  @override
  State<CreateSplitSheet> createState() => _CreateSplitSheetState();
}

class _FriendEntry {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  _FriendEntry();

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class _CreateSplitSheetState extends State<CreateSplitSheet> {
  Expense? _selectedExpense;
  final List<_FriendEntry> _friends = [];
  bool _equalSplit = false;
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  List<Expense> get _eligibleExpenses =>
      widget.expenses.where((e) => e.expenseId != null).toList();

  @override
  void initState() {
    super.initState();
    _addFriend();
  }

  @override
  void dispose() {
    for (final f in _friends) {
      f.dispose();
    }
    super.dispose();
  }

  void _addFriend() {
    setState(() => _friends.add(_FriendEntry()));
  }

  void _removeFriend(int index) {
    _friends[index].dispose();
    setState(() => _friends.removeAt(index));
  }

  void _applyEqualSplit() {
    if (_selectedExpense == null || _friends.isEmpty) return;
    final each = _selectedExpense!.amount / _friends.length;
    for (final f in _friends) {
      f.amountController.text = each.toStringAsFixed(2);
    }
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExpense == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expense'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    if (_friends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one friend'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
    final now = DateTime.now().millisecondsSinceEpoch;
      final splits = _friends.asMap().entries.map((entry) {
        final i = entry.key;
        final f = entry.value;
        final name = f.nameController.text.trim();
        // Generate a stable unique friendId from name + index + timestamp
        final friendId = '${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_${i}_$now';
        return ExpenseSplitDetail(
          friendId: friendId,
          friendName: name,
          amount: double.tryParse(f.amountController.text) ?? 0.0,
          settled: false,
        );
      }).toList();

      await SplitApiService.createSplit(
        _selectedExpense!.expenseId!,
        splits,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Split created successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              const Text(
                'Split an Expense',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose an expense and add who to split with',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Expense selector
              const Text(
                'Expense',
                style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Expense>(
                    value: _selectedExpense,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E293B),
                    hint: const Text(
                      'Select an expense...',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                    items: _eligibleExpenses.map((e) {
                      final label =
                          '${e.merchantName ?? e.category} — ₹${e.amount.toStringAsFixed(2)}';
                      return DropdownMenuItem(
                        value: e,
                        child: Text(
                          label,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedExpense = val;
                        _equalSplit = false;
                      });
                    },
                  ),
                ),
              ),

              // Equal split toggle
              if (_selectedExpense != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Switch(
                      value: _equalSplit,
                      activeColor: const Color(0xFF6366F1),
                      onChanged: (val) {
                        setState(() => _equalSplit = val);
                        if (val) _applyEqualSplit();
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Split equally',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      'Total: ₹${_selectedExpense!.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // Friends header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Friends',
                    style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  TextButton.icon(
                    onPressed: _addFriend,
                    icon: const Icon(Icons.person_add_outlined,
                        size: 18, color: Color(0xFF6366F1)),
                    label: const Text(
                      'Add Friend',
                      style: TextStyle(
                          color: Color(0xFF6366F1), fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Friend rows
              ..._friends.asMap().entries.map((entry) {
                final i = entry.key;
                final friend = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // Avatar circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Name field
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: friend.nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Name',
                            hintStyle:
                                const TextStyle(color: Color(0xFF64748B)),
                            filled: true,
                            fillColor: const Color(0xFF1E293B),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF334155)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF334155)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF6366F1)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Amount field
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: friend.amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'))
                          ],
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '₹ 0',
                            hintStyle:
                                const TextStyle(color: Color(0xFF64748B)),
                            filled: true,
                            fillColor: const Color(0xFF1E293B),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF334155)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF334155)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF6366F1)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (double.tryParse(v) == null) return 'Invalid';
                            if (double.parse(v) <= 0) return '> 0';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Remove button
                      if (_friends.length > 1)
                        GestureDetector(
                          onTap: () => _removeFriend(i),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 18, color: Color(0xFFEF4444)),
                          ),
                        )
                      else
                        const SizedBox(width: 34),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Split',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
