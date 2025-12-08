import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:elibrary_mobile/providers/subscription_provider.dart';

class PayPalWebView extends StatefulWidget {
  final String approvalUrl;
  final String orderId;

  const PayPalWebView({
    super.key,
    required this.approvalUrl,
    required this.orderId,
  });

  @override
  State<PayPalWebView> createState() => _PayPalWebViewState();
}

class _PayPalWebViewState extends State<PayPalWebView> {
  late final WebViewController controller;
  bool hasProcessed = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            if (url.contains("/payments/success") && !hasProcessed) {
              hasProcessed = true;
              _handleSuccess(url);
              return NavigationDecision.prevent;
            }

            if (url.contains("/payments/cancel")) {
              Navigator.pop(context, false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Plaćanje otkazano.")),
              );
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  void _handleSuccess(String url) async {
    try {
      final uri = Uri.parse(url);

      final userId = int.parse(uri.queryParameters["userId"]!);
      final days = int.parse(uri.queryParameters["days"]!);
      final price = double.parse(uri.queryParameters["price"]!);

      await _verifyOrder(widget.orderId);
      await _captureOrder(widget.orderId);
      await _saveSubscription(userId, days, price);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context, false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška pri obradi plaćanja: $e")),
        );
      }
    }
  }

  Future<void> _verifyOrder(String orderId) async {
    final res = await http.get(
      Uri.parse("http://10.0.2.2:8080/payments/check-paypal-order/$orderId"),
    );

    if (res.statusCode != 200) {
      throw Exception("PayPal order check failed");
    }

    final data = jsonDecode(res.body);
    final status = data["status"];

    if (status != "APPROVED") {
      throw Exception("Order not approved. Status: $status");
    }
  }

  Future<void> _captureOrder(String orderId) async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/payments/capture-paypal-order/$orderId"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Capture failed → ${response.body}");
    }

    final data = jsonDecode(response.body);
    final status = _extractStatus(data);

    if (status != "COMPLETED") {
      throw Exception("Capture not completed → $status");
    }
  }

  Future<void> _saveSubscription(int userId, int days, double price) async {
    final provider = context.read<SubscriptionProvider>();

    await provider.insert({
      "userId": userId,
      "days": days,
      "price": price,
      "startDate": DateTime.now().toIso8601String(),
      "endDate": DateTime.now().add(Duration(days: days)).toIso8601String(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Uplata uspješna! Pretplata aktivirana.")),
    );
  }

  String? _extractStatus(dynamic json) {
    try {
      if (json["status"] != null) return json["status"];
      return json["purchase_units"]?[0]["payments"]?["captures"]?[0]["status"];
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PayPal plaćanje")),
      body: WebViewWidget(controller: controller),
    );
  }
}
