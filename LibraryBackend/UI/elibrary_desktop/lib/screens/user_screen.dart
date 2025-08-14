import 'package:elibrary_desktop/models/user.dart';
import 'package:elibrary_desktop/providers/user_provider.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;
  final UserProvider _userProvider = UserProvider();

  List<User> _users = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalCount = 0;

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }
  
@override
void dispose() {
  _searchController.dispose();
  _firstNameController.dispose();
  _lastNameController.dispose();
  _dateController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        Padding(
  padding: const EdgeInsets.all(8.0),
  child: Row(
    children: [
      // Username filter
      Expanded(
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Korisničko ime',
          ),
        ),
      ),
      const SizedBox(width: 8),

      // First Name filter
      Expanded(
        child: TextField(
          controller: _firstNameController,
          decoration: const InputDecoration(
            labelText: 'Ime',
          ),
        ),
      ),
      const SizedBox(width: 8),

      // Last Name filter
      Expanded(
        child: TextField(
          controller: _lastNameController,
          decoration: const InputDecoration(
            labelText: 'Prezime',
          ),
        ),
      ),

      const SizedBox(width: 8),

      Expanded(
  child: TextField(
    controller: _dateController,
    readOnly: true,
    decoration: const InputDecoration(
      labelText: 'Datum registracije',
      suffixIcon: Icon(Icons.calendar_today),
    ),
    onTap: () async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );

      if (picked != null) {
        setState(() {
          _selectedDate = picked;
          _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        });
      }
    },
  ),
),
const SizedBox(width: 8),
      // Search button
      IconButton(
        icon: const Icon(Icons.search),
        tooltip: 'Pretraži',
        onPressed: () {
          _currentPage = 1;
          _loadUsers();
        },
      ),
    ],
  ),
),

        Expanded(
  child: SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: _users.map((user) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user.firstName ?? '-'} ${user.lastName ?? '-'}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        user.username ?? '-',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                    ],
                  ),
                  const SizedBox(height: 8),
                   Row(
                    children: [
                      const Icon(Icons.email, size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(user.email ?? '-', overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Role with icon
                  Row(
                    children: [
                      const Icon(Icons.security, size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(user.role?.name ?? '-'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Registration Date with icon
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(user.registrationDate.toString()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info, color: Colors.blue),
                        tooltip: "Detalji",
                        onPressed: () {
                          // Implement your details action
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: "Uredi",
                        onPressed: () {
                          // Implement your edit action
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: "Obriši",
                        onPressed: () {
                          // Implement your delete action
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ),
  ),
),



        _buildPaginationControls(),
      ],
    ),
  );
}


   Future<void> _loadUsers({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final result = await _userProvider.get(
        filter: {
          "FirstName": _firstNameController.text.trim(),
          "LastName": _lastNameController.text.trim(),
          "Username": _searchController.text.trim(),
          "Page": _currentPage - 1,
          "PageSize": _pageSize,
          if(_selectedDate != null)
            "RegistrationDate": _selectedDate!.toIso8601String(),
          
        },
      );
      if (mounted) {
        setState(() {
          _users = result.result;
          _totalCount = result.count ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading users: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Greška pri učitavanju korisnika: ${e.toString()}";
        });
      }
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
                _loadUsers();
              }
            : null,
        icon: const Icon(Icons.arrow_back),
      ),
      Text("Stranica $_currentPage"),
      IconButton(
        onPressed: () {
          setState(() {
            _currentPage++;
          });
          _loadUsers();
        },
        icon: const Icon(Icons.arrow_forward),
      ),
    ],
  );
}

}

