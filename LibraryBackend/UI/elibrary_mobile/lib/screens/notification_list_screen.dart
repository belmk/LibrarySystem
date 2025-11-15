import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notification.dart' as model;
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../models/search_result.dart';
import '../utils/datetime_helper.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({Key? key}) : super(key: key);

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late NotificationProvider _notificationProvider;
  late AuthProvider _authProvider;

  SearchResult<model.Notification>? _notificationResult;

  bool _isLoading = true;
  String? _errorMessage;

  // Pagination
  int _currentPage = 1;
  final int _pageSize = 10;
  int _totalCount = 0;

  int get _totalPages =>
      _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _notificationProvider = context.read<NotificationProvider>();
    _authProvider = context.read<AuthProvider>();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() => _isLoading = true);

      final userId = _authProvider.currentUser?.id;
      if (userId == null) {
        setState(() {
          _errorMessage = "Niste prijavljeni.";
          _isLoading = false;
        });
        return;
      }

      final result = await _notificationProvider.get(
        filter: {
          "userId": userId,
          "page": _currentPage - 1,
          "pageSize": _pageSize,
        },
      );

      setState(() {
        _notificationResult = result;
        _totalCount = result.count;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Greška pri učitavanju notifikacija: $e";
        _isLoading = false;
      });
    }
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
                    _loadNotifications();
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
          ),
          Text("Stranica $_currentPage od $_totalPages"),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadNotifications();
                  }
                : null,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(model.Notification notification) { //TODO: add buttons to card
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.notifications_active,
            color: Colors.blue, size: 32),
        title: Text(
          notification.title ?? "Bez naslova",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message ?? "Bez poruke"),
            const SizedBox(height: 4),
            Text(
              DateTimeHelper.formatDateTime(notification.receivedDate),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(_errorMessage!)),
      );
    }

    final notifications = _notificationResult?.result ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Notifikacije")),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView(
          children: [
            if (notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text("Nemate notifikacija.")),
              )
            else
              ...notifications.map(_buildNotificationCard),

            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }
}
