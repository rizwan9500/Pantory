import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/auth_service.dart';
import '../models/subscription_plan.dart';

class PaymentScreen extends StatefulWidget {
  final SubscriptionPlan plan;

  const PaymentScreen({
    super.key,
    required this.plan,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0; // 0: UPI, 1: QR Code, 2: Payment Link
  final TextEditingController _upiIdController = TextEditingController();
  final String _razorpayPaymentLink = 'razorpay.me/@ruzo';
  
  // Generate UPI payment string
  String get _upiPaymentString {
    final amount = widget.plan.price.toStringAsFixed(2);
    // UPI payment format: upi://pay?pa=MERCHANT_UPI&pn=MERCHANT_NAME&am=AMOUNT&cu=INR&tn=DESCRIPTION
    return 'upi://pay?pa=ruzo@paytm&pn=Pantory&am=$amount&cu=INR&tn=${Uri.encodeComponent(widget.plan.name)}';
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Have you completed the payment?'),
            const SizedBox(height: 16),
            Text(
              'Amount: ₹${widget.plan.price}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Plan: ${widget.plan.name}'),
            const SizedBox(height: 16),
            const Text(
              'Note: Your subscription will be activated once payment is verified.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close payment screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment confirmation received! We will verify and activate your subscription shortly.'),
                  duration: Duration(seconds: 4),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Yes, I\'ve Paid'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Plan Summary Card
            Container(
              width: double.infinity,
              color: Colors.green[50],
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    size: 64,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.plan.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${widget.plan.price}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.plan.duration,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Method Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method Tabs
                  Row(
                    children: [
                      Expanded(
                        child: _buildPaymentMethodTab(
                          index: 0,
                          icon: Icons.account_balance,
                          label: 'UPI',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPaymentMethodTab(
                          index: 1,
                          icon: Icons.qr_code_scanner,
                          label: 'QR Code',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPaymentMethodTab(
                          index: 2,
                          icon: Icons.link,
                          label: 'Link',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Payment Method Content
                  if (_selectedPaymentMethod == 0) _buildUPIPayment(),
                  if (_selectedPaymentMethod == 1) _buildQRCodePayment(),
                  if (_selectedPaymentMethod == 2) _buildPaymentLink(),

                  const SizedBox(height: 24),

                  // Confirm Payment Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'I\'ve Completed Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info Card
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'After payment, your subscription will be activated within 24 hours. You\'ll receive a confirmation email.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedPaymentMethod == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[700],
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUPIPayment() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pay via UPI',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // UPI ID Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'UPI ID',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ruzo@paytm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard('ruzo@paytm', 'UPI ID'),
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy UPI ID',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Amount
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Amount to Pay',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    '₹${widget.plan.price}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('1. Open any UPI app (GPay, PhonePe, Paytm, etc.)', style: TextStyle(fontSize: 13)),
                  Text('2. Enter UPI ID: ruzo@paytm', style: TextStyle(fontSize: 13)),
                  Text('3. Enter amount: ₹${999}', style: TextStyle(fontSize: 13)),
                  Text('4. Complete the payment', style: TextStyle(fontSize: 13)),
                  Text('5. Click "I\'ve Completed Payment" below', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodePayment() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Scan QR Code to Pay',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: QrImageView(
                data: _upiPaymentString,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),

            const SizedBox(height: 24),

            // Amount Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '₹${widget.plan.price}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'How to pay:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('1. Open any UPI app', style: TextStyle(fontSize: 13)),
                  Text('2. Tap on Scan QR', style: TextStyle(fontSize: 13)),
                  Text('3. Scan the QR code above', style: TextStyle(fontSize: 13)),
                  Text('4. Verify amount and complete payment', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentLink() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pay via Razorpay Link',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Payment Link Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Link',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _razorpayPaymentLink,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(_razorpayPaymentLink, 'Payment link'),
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy link',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Open Link Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // In a real app, this would open the browser
                  _copyToClipboard(_razorpayPaymentLink, 'Payment link');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Open this link in your browser to complete payment'),
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open Payment Link'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Steps to pay:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('1. Click "Open Payment Link" button', style: TextStyle(fontSize: 13)),
                  Text('2. You\'ll be redirected to Razorpay', style: TextStyle(fontSize: 13)),
                  Text('3. Choose your payment method', style: TextStyle(fontSize: 13)),
                  Text('4. Complete the secure payment', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
