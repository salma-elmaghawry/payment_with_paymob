class PaymobException implements Exception {
  final String message;
  final int? statusCode;

  const PaymobException(this.message, {this.statusCode});

  @override
  String toString() => 'PaymobException($statusCode): $message';
}
