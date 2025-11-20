import 'package:elibrary_mobile/screens/create_complaint_screen.dart';
import 'package:elibrary_mobile/screens/user_book_list_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elibrary_mobile/models/user.dart';
import 'package:elibrary_mobile/models/search_result.dart';
import 'package:elibrary_mobile/providers/user_provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late UserProvider _userProvider;

  SearchResult<User>? _userResult;
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  int _currentPage = 1;
  int _pageSize = 6;
  int _totalCount = 0;

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();
    _loadUsers();
  }

  Future<void> _loadUsers({bool useFilters = true}) async {
    setState(() => _isLoading = true);

    try {
      final filter = {
        "username": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "page": _currentPage - 1,
        "pageSize": _pageSize,
      };

      final result = await _userProvider.get(filter: filter);
      setState(() {
        _userResult = result;
        _totalCount = result.count ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _resetFilters() {
    _nameController.clear();
    _emailController.clear();
    setState(() {
      _currentPage = 1;
    });
    _loadUsers();
  }

  Widget _buildUserCard(User user) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            user.username ?? "Nepoznato korisničko ime",
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),

          // Info rows with icons
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text("${user.firstName ?? '-'} ${user.lastName ?? ''}")),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.email, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(user.email ?? '-')),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.admin_panel_settings, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(user.role?.name ?? '-')),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => UserBookListModal(userId: user.id!),
                  );
                },
                  icon: const Icon(Icons.menu_book, size: 18),
                  label: const Text("Knjige"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: allow user to leave a review
                  },
                  icon: const Icon(Icons.rate_review, size: 18),
                  label: const Text("Recenzija"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: CreateComplaintScreen(targetUser: user),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.report_problem, size: 18),
                label: const Text("Pošalji žalbu"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),

            ],
          ),
        ],
      ),
    ),
  );
}



  Widget _buildFilters() {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Ime korisnika',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _currentPage = 1;
                });
                _loadUsers(useFilters: true);
              },
              icon: const Icon(Icons.search, color: Colors.blueAccent),
              tooltip: 'Pretraži',
            ),
            IconButton(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh, color: Colors.grey),
              tooltip: 'Resetuj filtere',
            ),
          ],
        ),
      ],
    ),
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
                    _loadUsers();
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
          ),
          Text("Stranica $_currentPage od $_totalPages"),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadUsers();
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
    if (_isLoading) { //TODO: popraviti nestajanje UI za vrijeme loadinga
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(child: Text("Greška: $_errorMessage")),
      );
    }

    var users = _userResult?.result ?? [];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: ListView(
          children: [
            _buildFilters(),
            if (users.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text("Nema pronađenih korisnika")),
              )
            else
              ...users.map(_buildUserCard),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }
}
