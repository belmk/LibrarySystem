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
  bool hasCaptured = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            print("Navigating to: $url");

            if (url.contains("/payments/success")) {
              final uri = Uri.parse(url);

              final userId = uri.queryParameters["userId"];
              final days = uri.queryParameters["days"];
              final price = uri.queryParameters["price"];

              print("SUCCESS URL HIT");
              print("userId=$userId days=$days price=$price");

              if (!hasCaptured) {
                hasCaptured = true;

                await _verifyThenCapture(widget.orderId);

                if (userId != null && days != null && price != null) {
                  await _saveSubscription(
                    int.parse(userId),
                    int.parse(days),
                    double.parse(price),
                  );
                }
              }

              return NavigationDecision.prevent;
            }

            if (url.contains("/payments/cancel")) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Plaćanje otkazano.")),
              );
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (url) => print(" Page started: $url"),
          onPageFinished: (url) => print(" Page finished: $url"),
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  Future<void> _verifyThenCapture(String orderId) async {
    print("Checking PayPal order status...");

    final res = await http.get(
      Uri.parse("http://10.0.2.2:7268/payments/check-paypal-order/$orderId"),
    );

    print("Verify response: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("PayPal order check failed");
    }

    final data = jsonDecode(res.body);
    final status = data["status"] ??
        data["purchase_units"]?[0]?["payments"]?["authorizations"]?[0]?["status"];

    if (status != "APPROVED") {
      throw Exception("Order not approved yet. Status: $status");
    }

    print("Order approved. Capturing...");
    await _captureOrder(orderId);
  }

  Future<void> _captureOrder(String orderId) async {
    try {
      print("Attempting to capture PayPal order: $orderId");

      final response = await http.post(
        Uri.parse("http://10.0.2.2:7268/payments/capture-paypal-order/$orderId"),
        headers: {"Content-Type": "application/json"},
      );

      print("Capture response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }

      final data = jsonDecode(response.body);
      final status = _extractStatus(data);

      print("PayPal capture status: $status");

      if (status != "COMPLETED") {
        throw Exception("Capture exists but is not completed.");
      }
    } catch (e) {
      print("Capture error: $e");

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška pri potvrdi uplate: $e")),
        );
      }
    }
  }

  Future<void> _saveSubscription(int userId, int days, double price) async {
    print("Saving subscription → userId=$userId days=$days price=$price");

    try {
      final provider = context.read<SubscriptionProvider>();

      await provider.insert({
        "userId": userId,
        "days": days,
        "price": price,
        "startDate": DateTime.now().toIso8601String(),
        "endDate": DateTime.now().add(Duration(days: days)).toIso8601String(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Uplata uspješna! Pretplata aktivirana.")),
        );
      }
    } catch (e) {
      print("Subscription insert failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška pri kreiranju pretplate: $e")),
        );
      }
    }
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
