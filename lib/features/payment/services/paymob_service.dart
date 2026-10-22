import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:payment_with_paymob/features/payment/models/billing_data.dart';
import 'package:payment_with_paymob/features/payment/models/intention_response.dart';
import 'package:payment_with_paymob/features/payment/models/payment_result.dart';
import 'package:payment_with_paymob/features/payment/services/paymob_exception.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// The whole Paymob flow, in order (each step's output is the next step's input):
///
///    amount + customer data (from the screen)
///            ↓
/// 1. [createIntention] → client_secret
///            ↓
/// 2. [checkoutUri]     → payment page link (the WebView opens it)
///            ↓
/// 3. [resultFromUrl]   → PaymentResult (the screen shows it to the user)
class PaymobService {
  PaymobService() {
    if (kDebugMode) _dio.interceptors.add(PrettyDioLogger(requestBody: true));
  }

  static const String _baseUrl = 'https://accept.paymob.com';
  static const String _checkoutUrl = 'https://eg.checkout.paymob.com/';
  static const String _redirectionUrl = 'https://example.com/payment-result';

  static String get _secretKey => dotenv.get('PAYMOB_SECRET_KEY');
  static String get _publicKey => dotenv.get('PAYMOB_PUBLIC_KEY');
  static int get _cardIntegrationId =>
      dotenv.getInt('PAYMOB_CARD_INTEGRATION_ID');

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  /// Step 1: Create a payment intention.

  Future<IntentionResponse> createIntention({
    required int amountCents,
    required String itemName,
    required BillingData billingData,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/intention/',
        options: Options(headers: {'Authorization': 'Token $_secretKey'}),
        data: {
          'amount': amountCents,
          'currency': 'EGP',
          'payment_methods': [_cardIntegrationId],
          'items': [
            {
              'name': itemName,
              'amount': amountCents,
              'description': itemName,
              'quantity': 1,
            },
          ],
          'billing_data': billingData.toJson(),
          'special_reference': 'order_${DateTime.now().millisecondsSinceEpoch}',
          'redirection_url': _redirectionUrl,
        },
      );
      return IntentionResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw PaymobException(
        e.response?.data?.toString() ?? e.message ?? 'Unknown network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Step 2: Build the payment page link.

  Uri checkoutUri(String clientSecret) => Uri.parse(_checkoutUrl).replace(
    queryParameters: {'publicKey': _publicKey, 'clientSecret': clientSecret},
  );

  /// Step 3: Read the result when Paymob redirects back.
 
  PaymentResult? resultFromUrl(String url) {
    if (!url.startsWith(_redirectionUrl)) return null;

    final params = Uri.parse(url).queryParameters;

    final PaymentStatus status;
    if (params['pending'] == 'true') {
      status = PaymentStatus.pending;
    } else if (params['success'] == 'true') {
      status = PaymentStatus.success;
    } else {
      status = PaymentStatus.failed;
    }

    return PaymentResult(status: status, transactionId: params['id']);
  }
}
