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
        "IsResolved": false
      });

      setState(() {
        _complaints = result.result;
        _isLoading = false;
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
    // TODO: await _userProvider.revokeMembership(complaint.target?.id);
    await _complaintProvider.update(complaint.id!, {
      "IsResolved": true,
    });

    await _notificationProvider.insert({
      "userId": complaint.target?.id,
      "receivedDate": DateTime.now().toIso8601String(),
      "title": "Ukinuto članstvo",
      "message": "Vaše članstvo je ukinuto zbog ozbiljne žalbe na vaše ponašanje.",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Članstvo korisnika je ukinuto.")),
    );

    await _loadComplaints();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška pri ukidanju članstva: $e")),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Filters
            Row(
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
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Pretraži',
                  onPressed: _loadComplaints,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Table
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : _complaints.isEmpty
                          ? const Center(child: Text('Nema žalbi'))
                          : SingleChildScrollView(
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
                                            tooltip: 'Ukinuti članstvo',
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
          ],
        ),
      ),
    );
  }
}
