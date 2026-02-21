import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/expense_tile.dart';
import '../models/category_model.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  Set<String> selectedCategories = {}; // Changed to Set for multiple selection
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (selectedCategories.isNotEmpty || startDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Multiple category chips
                  ...selectedCategories.map((categoryId) {
                    final categoryProvider = context.read<CategoryProvider>();
                    final category = categoryProvider.getCategoryById(categoryId);
                    return Chip(
                      label: Text(category?.name ?? ''),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          selectedCategories.remove(categoryId);
                        });
                      },
                      backgroundColor: const Color(0xFF334155),
                    );
                  }).toList(),
                  if (startDate != null)
                    Chip(
                      label: Text(
                        'From: ${DateFormat('MMM dd').format(startDate!)}',
                      ),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          startDate = null;
                          endDate = null;
                        });
                      },
                      backgroundColor: const Color(0xFF334155),
                    ),
                ],
              ),
            ),

          // Expense List
          Expanded(
            child: Consumer<ExpenseProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                var expenses = provider.expenses;

                // Apply filters
                if (selectedCategories.isNotEmpty) {
                  expenses = expenses
                      .where((e) => selectedCategories.contains(e.category))
                      .toList();
                }

                if (startDate != null && endDate != null) {
                  expenses = expenses.where((e) {
                    return e.date.isAfter(startDate!) &&
                        e.date.isBefore(endDate!.add(const Duration(days: 1)));
                  }).toList();
                }

                if (expenses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Color(0xFF475569),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses found',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF94A3B8),
                              ),
                        ),
                      ],
                    ),
                  );
                }

                // Group expenses by date
                final groupedExpenses = _groupExpensesByDate(expenses);

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: groupedExpenses.length,
                  itemBuilder: (context, index) {
                    final entry = groupedExpenses[index];
                    final dateLabel = entry['label'] as String;
                    final dateExpenses = entry['expenses'] as List;
                    final total = entry['total'] as double;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateLabel,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                '₹${total.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: const Color(0xFF6366F1),
                                    ),
                              ),
                            ],
                          ),
                        ),

                        // Expenses for this date
                        ...dateExpenses.map((expense) {
                          return ExpenseTile(
                            expense: expense,
                          );
                        }).toList(),
                        
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupExpensesByDate(List expenses) {
    final Map<String, List> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var expense in expenses) {
      final expenseDate = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );

      String label;
      if (expenseDate.isAtSameMomentAs(today)) {
        label = 'Today';
      } else if (expenseDate.isAtSameMomentAs(yesterday)) {
        label = 'Yesterday';
      } else {
        label = DateFormat('EEEE, MMM dd').format(expenseDate);
      }

      if (!grouped.containsKey(label)) {
        grouped[label] = [];
      }
      grouped[label]!.add(expense);
    }

    // Convert to list with totals
    return grouped.entries.map((entry) {
      final total = entry.value.fold<double>(
        0.0,
        (sum, expense) => sum + expense.amount,
      );

      return {
        'label': entry.key,
        'expenses': entry.value,
        'total': total,
      };
    }).toList();
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Expenses',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),

                  // Category Filter
                  const Text('Category', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, child) {
                      final allCategories = categoryProvider.allCategories;
                      
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCategoryChip('All', null, setModalState),
                          ...allCategories.map<Widget>((Category cat) {
                            return _buildCategoryChip(cat.name, cat.id, setModalState);
                          }).toList(),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Date Filter
                  const Text('Date Range', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setModalState(() {
                                startDate = date;
                              });
                              setState(() {});
                            }
                          },
                          child: Text(
                            startDate != null
                                ? DateFormat('MMM dd').format(startDate!)
                                : 'Start Date',
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('to'),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: startDate == null
                              ? null
                              : () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: endDate ?? DateTime.now(),
                                    firstDate: startDate!,
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setModalState(() {
                                      endDate = date;
                                    });
                                    setState(() {});
                                  }
                                },
                          child: Text(
                            endDate != null
                                ? DateFormat('MMM dd').format(endDate!)
                                : 'End Date',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryChip(String label, String? categoryId, StateSetter setModalState) {
    // Special handling for "All" option
    if (categoryId == null) {
      final isAllSelected = selectedCategories.isEmpty;
      return ChoiceChip(
        label: Text(label),
        selected: isAllSelected,
        onSelected: (selected) {
          setModalState(() {
            selectedCategories.clear();
          });
          setState(() {});
        },
        selectedColor: const Color(0xFF6366F1),
        backgroundColor: const Color(0xFF334155),
      );
    }
    
    // Multiple selection for categories
    final isSelected = selectedCategories.contains(categoryId);
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          if (selected) {
            selectedCategories.add(categoryId);
          } else {
            selectedCategories.remove(categoryId);
          }
        });
        setState(() {});
      },
      selectedColor: const Color(0xFF6366F1),
      backgroundColor: const Color(0xFF334155),
      checkmarkColor: Colors.white,
    );
  }
}
