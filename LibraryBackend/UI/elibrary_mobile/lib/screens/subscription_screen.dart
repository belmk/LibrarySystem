import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elibrary_mobile/models/subscription.dart';
import 'package:elibrary_mobile/providers/subscription_provider.dart';
import 'package:elibrary_mobile/providers/auth_provider.dart';
import 'package:elibrary_mobile/utils/datetime_helper.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late Future<List<Subscription>> _futureSubscriptions;

  int _currentPage = 1;
  int _pageSize = 6;
  int _totalCount = 0;

  int get _totalPages =>
      _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      _futureSubscriptions = Future.value([]);
      return;
    }

    final subscriptionProvider = SubscriptionProvider();

    _futureSubscriptions = subscriptionProvider
        .get(
      filter: {
        "userId": user.id,
        "page": _currentPage - 1,
        "pageSize": _pageSize,
      },
    )
        .then((res) {
      setState(() {
        _totalCount = res.count;
      });
      return res.result;
    });
  }

  int calculateTotalDays(List<Subscription> subs) {
    int totalDays = 0;
    for (var s in subs) {
      if (s.startDate != null && s.endDate != null) {
        totalDays += s.endDate!.difference(s.startDate!).inDays;
      }
    }
    return totalDays;
  }

  double calculateTotalMoney(List<Subscription> subs) {
    double total = 0;
    for (var s in subs) {
      total += s.price ?? 0;
    }
    return total;
  }

  Widget _iconRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _loadData();
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
          ),
          Text("Stranica $_currentPage od $_totalPages"),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadData();
                  }
                : null,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      body: currentUser == null
          ? const Center(
              child: Text(
                "Niste prijavljeni.",
                style: TextStyle(fontSize: 18),
              ),
            )
          : FutureBuilder<List<Subscription>>(
              future: _futureSubscriptions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyView();
                }

                final subs = snapshot.data!;
                final totalDays = calculateTotalDays(subs);
                final totalMoney = calculateTotalMoney(subs);

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Vaše pretplate",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: ListView.builder(
                          itemCount: subs.length,
                          itemBuilder: (context, index) {
                            final s = subs[index];

                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _iconRow(
                                        Icons.calendar_month,
                                        "Od ${DateTimeHelper.formatDate(s.startDate)}"),
                                    const SizedBox(height: 8),
                                    _iconRow(
                                        Icons.cancel,
                                        "Do ${DateTimeHelper.formatDate(s.endDate)}"),
                                    const SizedBox(height: 8),
                                    _iconRow(
                                        Icons.payments,
                                        " ${(s.price ?? 0).toStringAsFixed(2)} KM"),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      _buildPaginationControls(),

                      const Divider(),

                      Row(
                        children: [
                          const Icon(Icons.timelapse,
                              color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Text(
                            "Ukupno dana pretplaćen: $totalDays dana",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.attach_money,
                              color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            "Ukupno potrošeno: ${totalMoney.toStringAsFixed(2)} KM",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {}, //TODO: Implement subscription paypal screen
                          icon: const Icon(Icons.subscriptions),
                          label: const Text("Pretplati se"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          const Text("Nema pronađenih pretplata.",
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.subscriptions),
            label: const Text("Pretplati se"),
          ),
        ],
      ),
    );
  }
}
