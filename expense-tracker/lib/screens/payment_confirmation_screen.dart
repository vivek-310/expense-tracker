import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../providers/expense_provider.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final Expense expense;

  const PaymentConfirmationScreen({
    Key? key,
    required this.expense,
  }) : super(key: key);

  void _confirmPayment(BuildContext context) async {
    // Save expense to database
    await context.read<ExpenseProvider>().addExpense(expense);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense saved successfully!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );

    // Navigate back to home (pop all screens)
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _cancelPayment(BuildContext context) {
    // Just go back without saving
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final category = Category.getCategoryById(expense.category);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),

              // Success Icon Animation
              Container(
                width: 120,
                height: 120,
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
                child: const Icon(
                  Icons.receipt_long,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Payment Initiated',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                'Did you complete the payment?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Expense Details Card
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
                    // Category
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(category?.color ?? 0xFF6366F1),
                                Color(category?.color ?? 0xFF6366F1).withOpacity(0.7),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Category',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category?.name ?? 'Others',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Amount
                    _buildDetailRow(
                      'Amount',
                      currencyFormat.format(expense.amount),
                      isHighlighted: true,
                    ),

                    if (expense.merchantName != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow('Merchant', expense.merchantName!),
                    ],

                    if (expense.upiId != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow('UPI ID', expense.upiId!),
                    ],

                    const SizedBox(height: 16),
                    _buildDetailRow('Date', dateFormat.format(expense.date)),

                    if (expense.note != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow('Notes', expense.note!),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This expense will be saved based on your confirmation',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFF59E0B),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelPayment(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFFEF4444)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _confirmPayment(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Text('Yes, Save Expense'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF94A3B8),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 24 : 16,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              color: const Color(0xFFF1F5F9),
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
