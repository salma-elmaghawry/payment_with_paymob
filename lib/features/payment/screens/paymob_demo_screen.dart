import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payment_with_paymob/features/payment/models/billing_data.dart';
import 'package:payment_with_paymob/features/payment/models/payment_result.dart';
import 'package:payment_with_paymob/features/payment/screens/paymob_webview_screen.dart';
import 'package:payment_with_paymob/features/payment/services/paymob_exception.dart';
import 'package:payment_with_paymob/features/payment/services/paymob_service.dart';

class PaymobDemoScreen extends StatefulWidget {
  const PaymobDemoScreen({super.key});

  @override
  State<PaymobDemoScreen> createState() => _PaymobDemoScreenState();
}

class _PaymobDemoScreenState extends State<PaymobDemoScreen> {
  final _service = PaymobService();
  final _amountController = TextEditingController();
  bool _loading = false;

  int? get _amountCents {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return null;
    return (amount * 100).round(); // Convert to cents
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final amountCents = _amountCents;
    if (amountCents == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      final intention = await _service.createIntention(
        amountCents: amountCents,
        itemName: 'Flutter Course',
        billingData: const BillingData(
          firstName: 'Ahmed',
          lastName: 'Ali',
          email: 'ahmed@example.com',
          phoneNumber: '+201012345678',
        ),
      );
      if (!mounted) return;

      final result =
          await Navigator.push<PaymentResult>(
            context,
            MaterialPageRoute(
              builder: (_) => PaymobWebViewScreen(
                service: _service,
                clientSecret: intention.clientSecret,
              ),
            ),
          ) ??
          const PaymentResult(status: PaymentStatus.cancelled);

      _showMessage('${result.status.name} · ${result.transactionId ?? '-'}');
    } on PaymobException catch (e) {
      _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final amountCents = _amountCents;

    return Scaffold(
      appBar: AppBar(title: const Text('Paymob Demo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amountController,
              enabled: !_loading,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: '50',
                suffixText: 'EGP',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _pay(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading || amountCents == null ? null : _pay,
              child: _loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      amountCents == null
                          ? 'Enter an amount'
                          : 'Pay ${(amountCents / 100).toStringAsFixed(2)} EGP',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
