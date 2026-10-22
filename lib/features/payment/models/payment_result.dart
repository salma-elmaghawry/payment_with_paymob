enum PaymentStatus { success, pending, failed, cancelled }

class PaymentResult {
  final PaymentStatus status;
  final String? transactionId;

  const PaymentResult({required this.status, this.transactionId});
}
