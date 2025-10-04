import 'package:elibrary_desktop/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:elibrary_desktop/models/complaint.dart';
import 'package:elibrary_desktop/providers/complaint_provider.dart';
import 'package:elibrary_desktop/providers/user_provider.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final ComplaintProvider _complaintProvider = ComplaintProvider();
  final UserProvider _userProvider = UserProvider();
  final NotificationProvider _notificationProvider = NotificationProvider();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _selectedDate;

  List<Complaint> _complaints = [];
  bool _isLoading = true;
  String? _error;

  int _currentPage = 1;
  int _pageSize = 6;
  int _totalCount = 0;

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;


  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final result = await _complaintProvider.get(filter: {
      "Username": _nameController.text.trim(),
      "Email": _emailController.text.trim(),
      "ComplaintDate": _selectedDate?.toIso8601String(),
      "IsResolved": false,
      "Page": _currentPage - 1, 
      "PageSize": _pageSize,
    });

    setState(() {
      _complaints = result.result;
      _totalCount = result.count ?? result.result.length; 
      _isLoading = false;

      if (_currentPage > _totalPages) {
        _currentPage = _totalPages;
      }
    });
  } catch (e) {
    setState(() {
      _error = "Greška pri učitavanju žalbi: $e";
      _isLoading = false;
    });
  }
}


  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _giveWarning(Complaint complaint) async {
  try {
    await _userProvider.warnUser(complaint.target?.id);
    await _complaintProvider.update(complaint.id!, {
      "IsResolved": true,
    });

    await _notificationProvider.insert({
      "userId": complaint.target?.id,
      "receivedDate": DateTime.now().toIso8601String(),
      "title": "Upozorenje",
      "message": "Dobili ste upozorenje na osnovu žalbe zbog neprimjerenog ponašanja.",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Upozorenje je poslano korisniku.")),
    );

    await _loadComplaints(); 
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška pri slanju upozorenja: $e")),
    );
  }
}

Future<void> _revokeMembership(Complaint complaint) async {
  try {
    final userId = complaint.target?.id;

    if (userId == null) {
      throw Exception("ID korisnika nije dostupan.");
    }

    final success = await _userProvider.revokeSubscription(userId);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Korisnik nema aktivnu pretplatu.")),
      );
      return; 
    }

    await _complaintProvider.update(complaint.id!, {
      "IsResolved": true,
    });

    await _notificationProvider.insert({
      "userId": userId,
      "receivedDate": DateTime.now().toIso8601String(),
      "title": "Ukinuta pretplata",
      "message": "Vaša pretplata je ukinuta zbog ozbiljne žalbe na vaše ponašanje.",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pretplata korisnika je ukinuta.")),
    );

    await _loadComplaints(); 
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška pri ukidanju pretplate: $e")),
    );
  }
}


Future<void> _deactivateProfile(Complaint complaint) async {
  try {
    await _userProvider.deactivateUser((complaint.target?.id)!);
    await _complaintProvider.update(complaint.id!, {
      "IsResolved": true,
    });

    await _notificationProvider.insert({
      "userId": complaint.target?.id,
      "receivedDate": DateTime.now().toIso8601String(),
      "title": "Deaktiviran profil",
      "message": "Vaš profil je deaktiviran zbog ozbiljnih kršenja pravila platforme.",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil korisnika je deaktiviran.")),
    );

    await _loadComplaints();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška pri deaktivaciji profila: $e")),
    );
  }
}

Widget _buildPaginationControls() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        onPressed: _currentPage > 1
            ? () {
                setState(() {
                  _currentPage--;
                });
                _loadComplaints();
              }
            : null,
        icon: const Icon(Icons.arrow_back),
      ),
      Text("Stranica $_currentPage od $_totalPages"),
      IconButton(
        onPressed: _currentPage < _totalPages
            ? () {
                setState(() {
                  _currentPage++;
                });
                _loadComplaints();
              }
            : null,
        icon: const Icon(Icons.arrow_forward),
      ),
    ],
  );
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Ime korisnika'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email korisnika'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Datum žalbe',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: _selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                            : '',
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Resetuj filtere',
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            onPressed: () {
              setState(() {
                _nameController.clear();
                _emailController.clear();
                _selectedDate = null;
                _currentPage = 1;
              });
              _loadComplaints();
            },
          ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Pretraži',
                onPressed: () {
                  setState(() {
                    _currentPage = 1;
                  });
                  _loadComplaints();
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : _complaints.isEmpty
                      ? const Center(child: Text('Nema žalbi'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Podnosilac žalbe')),
                                  DataColumn(label: Text('Meta žalbe')),
                                  DataColumn(label: Text('Razlog')),
                                  DataColumn(label: Text('Datum')),
                                  DataColumn(label: Text('Upozorenja')),
                                  DataColumn(label: Text('Akcije')),
                                ],
                                rows: _complaints.map((complaint) {
                                  final sender = complaint.sender;
                                  final target = complaint.target;
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(
                                        '${sender?.firstName ?? ''} ${sender?.lastName ?? ''} (${sender?.email ?? '-'})',
                                      )),
                                      DataCell(Text(
                                        '${target?.firstName ?? ''} ${target?.lastName ?? ''} (${target?.email ?? '-'})',
                                      )),
                                      DataCell(Text(complaint.reason ?? '-')),
                                      DataCell(Text(complaint.complaintDate != null
                                          ? DateFormat('yyyy-MM-dd').format(complaint.complaintDate!)
                                          : '-')),
                                      DataCell(Text('${target?.warningNumber ?? 0}')),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.warning, color: Colors.orange),
                                            tooltip: 'Upozori',
                                            onPressed: () => _giveWarning(complaint),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                            tooltip: 'Ukini pretplatu',
                                            onPressed: () => _revokeMembership(complaint),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.person_off, color: Colors.grey),
                                            tooltip: 'Deaktiviraj profil',
                                            onPressed: () => _deactivateProfile(complaint),
                                          ),
                                        ],
                                      )),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
        ),

          _buildPaginationControls(),
        
      ],
    ),
  );
}

}
