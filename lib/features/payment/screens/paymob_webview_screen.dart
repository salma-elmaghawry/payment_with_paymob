import 'package:flutter/material.dart';
import 'package:payment_with_paymob/features/payment/services/paymob_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymobWebViewScreen extends StatefulWidget {
  const PaymobWebViewScreen({
    super.key,
    required this.service,
    required this.clientSecret,
  });

  final PaymobService service;
  final String clientSecret;

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
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // Watch every URL change to detect when Paymob redirects back to our app.
          onUrlChange: (change) => _checkUrl(change.url),
        ),
      )
      ..loadRequest(widget.service.checkoutUri(widget.clientSecret));
  }

  // If the URL is our redirection URL, close the screen and return the result.
  void _checkUrl(String? url) {
    if (url == null || _finished) return;
    final result = widget.service.resultFromUrl(url);
    if (result == null) return;
    _finished = true;
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
