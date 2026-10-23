import 'package:flutter/material.dart';
import 'package:payment_with_paymob/features/payment/services/paymob_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymobWebViewScreen extends StatefulWidget {
  const PaymobWebViewScreen({super.key, required this.checkoutUri});

  final Uri checkoutUri;

  @override
  State<PaymobWebViewScreen> createState() => _PaymobWebViewScreenState();
}

class _PaymobWebViewScreenState extends State<PaymobWebViewScreen> {
  late final WebViewController _controller;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)// to allow the payment page to work properly
      ..setNavigationDelegate(
        NavigationDelegate(
          // Watch every URL change to detect when Paymob redirects back to our app.
          onUrlChange: (change) => _checkUrl(change.url),
        ),
      )
      ..loadRequest(widget.checkoutUri);
  }

  // If the URL is our redirection URL, close the screen and return that URL.
  void _checkUrl(String? url) {
    if (url == null || _finished) return;
    //https://example.com/payment-result?success=true&pending=false&id=123456
    //the user has completed the payment and Paymob is redirecting back to our app
    if (!url.startsWith(PaymobService.redirectionUrl)) return; 
    _finished = true;
    Navigator.pop(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
