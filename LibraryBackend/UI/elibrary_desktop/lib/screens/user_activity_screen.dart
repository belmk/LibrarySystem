import 'package:flutter/material.dart';
import 'package:elibrary_desktop/models/user.dart';
import 'package:elibrary_desktop/models/activity.dart';
import 'package:elibrary_desktop/providers/activity_provider.dart';
import 'package:elibrary_desktop/utils/datetime_helper.dart';

class UserActivityDialog extends StatefulWidget {
  final User user;

  const UserActivityDialog({super.key, required this.user});

  @override
  State<UserActivityDialog> createState() => _UserActivityDialogState();
}

class _UserActivityDialogState extends State<UserActivityDialog> {
  final ActivityProvider _activityProvider = ActivityProvider();
  List<Activity> _activities = [];

  bool _isLoading = true;
  String? _error;

  int _currentPage = 1;
  int _pageSize = 10;
  int _totalCount = 0;

  int get _totalPages => (_totalCount / _pageSize).ceil();

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _activityProvider.get(filter: {
      "UserId": widget.user.id,
      "Page": _currentPage - 1,
      "PageSize": _pageSize,
    });

      setState(() {
        _activities = result.result;
        _totalCount = result.count ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Greška pri učitavanju aktivnosti: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 700,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aktivnosti korisnika: ${widget.user.username}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : _activities.isEmpty
                          ? const Center(child: Text('Nema aktivnosti.'))
                          : SingleChildScrollView(
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Opis')),
                                  DataColumn(label: Text('Datum aktivnosti')),
                                ],
                                rows: _activities.map((activity) {
                                  return DataRow(cells: [
                                    DataCell(
                                    SizedBox(
                                      width: 300,
                                      child: Tooltip(
                                        message: activity.description ?? '-',
                                        child: Text(
                                          activity.description ?? '-',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                    DataCell(Text(
                                      DateTimeHelper.formatDateTime(activity.activityDate),
                                    )),
                                  ]);
                                }).toList(),
                              ),
                            ),
            ),
            const Divider(height: 1),
            // Pagination
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Stranica $_currentPage od $_totalPages"),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _currentPage > 1
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                                _loadActivities();
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _currentPage < _totalPages
                            ? () {
                                setState(() {
                                  _currentPage++;
                                });
                                _loadActivities();
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
