import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../services/upi_service.dart';
import 'qr_scanner_screen.dart';
import 'payment_confirmation_screen.dart';

class AddExpenseScreen extends StatefulWidget {
  final Category selectedCategory;

  const AddExpenseScreen({
    Key? key,
    required this.selectedCategory,
  }) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _merchantNameController = TextEditingController();
  final _notesController = TextEditingController();

  String? scannedUpiId;
  String? scannedMerchantName;

  @override
  void dispose() {
    _amountController.dispose();
    _upiIdController.dispose();
    _merchantNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _openQRScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        scannedUpiId = result['pa'];
        scannedMerchantName = result['pn'];
        _upiIdController.text = scannedUpiId ?? '';
        _merchantNameController.text = scannedMerchantName ?? '';
        
        // Auto-fill amount if present in QR code
        if (result['am'] != null && result['am']!.isNotEmpty) {
          _amountController.text = result['am']!;
          
          // Show snackbar to inform user that amount was auto-filled
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Amount ₹${result['am']} detected from QR code'),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  void _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final upiId = _upiIdController.text.trim();
    final merchantName = _merchantNameController.text.trim();

    if (upiId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter UPI ID or scan QR code'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Launch UPI payment
    final success = await UpiService.initiateUpiPayment(
      payeeAddress: upiId,
      payeeName: merchantName.isNotEmpty ? merchantName : 'Merchant',
      amount: amount,
      category: widget.selectedCategory.name,
    );

    if (!mounted) return;

    if (success) {
      // Navigate to confirmation screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentConfirmationScreen(
            expense: Expense(
              category: widget.selectedCategory.id,
              amount: amount,
              merchantName: merchantName.isNotEmpty ? merchantName : null,
              upiId: upiId,
              date: DateTime.now(),
              note: _notesController.text.trim().isNotEmpty 
                  ? _notesController.text.trim() 
                  : null,
              paymentMethod: 'UPI',
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No UPI app found. Please install a UPI app.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  void _saveWithoutPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final merchantName = _merchantNameController.text.trim();
    final notes = _notesController.text.trim();

    final expense = Expense(
      category: widget.selectedCategory.id,
      amount: amount,
      merchantName: merchantName.isNotEmpty ? merchantName : null,
      upiId: _upiIdController.text.trim().isNotEmpty 
          ? _upiIdController.text.trim() 
          : null,
      date: DateTime.now(),
      note: notes.isNotEmpty ? notes : null,
      paymentMethod: 'CASH', // Indicate manual entry without UPI
    );

    try {
      await context.read<ExpenseProvider>().addExpense(expense);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add expense: ${e.toString()}'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.selectedCategory.name} Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(widget.selectedCategory.color),
                      Color(widget.selectedCategory.color).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.selectedCategory.icon,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.selectedCategory.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // QR Scanner Button
              OutlinedButton.icon(
                onPressed: _openQRScanner,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF6366F1), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'OR',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
              const SizedBox(height: 16),

              // Manual UPI ID Input
              TextFormField(
                controller: _upiIdController,
                decoration: const InputDecoration(
                  labelText: 'UPI ID',
                  hintText: 'merchant@upi',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
              ),
              const SizedBox(height: 16),

              // Merchant Name
              TextFormField(
                controller: _merchantNameController,
                decoration: const InputDecoration(
                  labelText: 'Merchant Name (Optional)',
                  hintText: 'Shop or restaurant name',
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any additional details',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              ElevatedButton(
                onPressed: _proceedToPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text('Proceed to UPI Payment'),
              ),
              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: _saveWithoutPayment,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Without Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
