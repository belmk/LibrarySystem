import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:elibrary_desktop/models/book_review.dart';
import 'package:elibrary_desktop/models/user_review.dart';
import 'package:elibrary_desktop/providers/book_review_provider.dart';
import 'package:elibrary_desktop/providers/user_review_provider.dart';
import 'package:elibrary_desktop/providers/user_provider.dart';
import 'package:elibrary_desktop/providers/notification_provider.dart';
import 'package:elibrary_desktop/utils/datetime_helper.dart';

class BookReviewScreen extends StatefulWidget {
  const BookReviewScreen({Key? key}) : super(key: key);

  @override
  State<BookReviewScreen> createState() => _BookReviewScreenState();
}

class _BookReviewScreenState extends State<BookReviewScreen> {
  final BookReviewProvider _reviewProvider = BookReviewProvider();
  final UserReviewProvider _userReviewProvider = UserReviewProvider();
  final UserProvider _userProvider = UserProvider();
  final NotificationProvider _notificationProvider = NotificationProvider();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _selectedDate;

  // BOOK REVIEWS
  List<BookReview> _reviews = [];
  bool _isLoading = true;
  String? _error;

  int _currentPage = 1;
  int _pageSize = 6;
  int _totalCount = 0;
  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  // USER REVIEWS
  List<UserReview> _userReviews = [];
  bool _isLoadingUser = true;
  String? _errorUser;

  int _currentPageUser = 1;
  int _pageSizeUser = 6;
  int _totalCountUser = 0;
  int get _totalPagesUser =>
      _totalCountUser > 0 ? (_totalCountUser / _pageSizeUser).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _loadUserReviews();
  }

  // LOAD BOOK REVIEWS
  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _reviewProvider.get(filter: {
        "Username": _nameController.text.trim(),
        "Email": _emailController.text.trim(),
        "ReviewDate": _selectedDate?.toIso8601String(),
        "IsApproved": false,
        "IsDenied": false,
        "Page": _currentPage - 1,
        "PageSize": _pageSize,
      });

      setState(() {
        _reviews = result.result;
        _totalCount = result.count ?? result.result.length;

        if (_currentPage > _totalPages) _currentPage = _totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Greška pri učitavanju recenzija: $e";
        _isLoading = false;
      });
    }
  }

  // LOAD USER REVIEWS
  Future<void> _loadUserReviews() async {
    setState(() {
      _isLoadingUser = true;
      _errorUser = null;
    });

    try {
      final result = await _userReviewProvider.get(filter: {
        "Username": _nameController.text.trim(),
        "Email": _emailController.text.trim(),
        "ReviewDate": _selectedDate?.toIso8601String(),
        "IsApproved": false,
        "IsDenied": false,
        "Page": _currentPageUser - 1,
        "PageSize": _pageSizeUser,
      });

      setState(() {
        _userReviews = result.result;
        _totalCountUser = result.count ?? result.result.length;

        if (_currentPageUser > _totalPagesUser) {
          _currentPageUser = _totalPagesUser;
        }

        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        _errorUser = "Greška pri učitavanju korisničkih recenzija: $e";
        _isLoadingUser = false;
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

  // BOOK REVIEW ACTIONS
  Future<bool> _confirmAction(BuildContext context, String title, String message) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("Odustani"),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            ElevatedButton(
              child: const Text("Potvrdi"),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ) ??
      false;
}

// BOOK REVIEW ACTIONS
void _acceptReview(BookReview review) async {
  final confirm = await _confirmAction(
    context,
    "Prihvatanje recenzije",
    "Da li ste sigurni da želite prihvatiti ovu recenziju?",
  );

  if (!confirm) return;

  try {
    await _reviewProvider.update(review.id!, {
      "Comment": review.comment,
      "Rating": review.rating,
      "isApproved": true,
      "isDenied": false,
    });

    await _notificationProvider.insert({
      "userId": review.user?.id,
      "receivedDate": DateTime.now().toIso8601String(),
      "title": "Recenzija prihvaćena",
      "message":
          "Vaša recenzija za knjigu '${review.book?.title}' je prihvaćena.",
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Recenzija prihvaćena")));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška prilikom prihvaćanja recenzije: $e")));
  }
}

void _declineReview(BookReview review) async {
  final confirm = await _confirmAction(
    context,
    "Odbijanje recenzije",
    "Da li ste sigurni da želite odbiti ovu recenziju?",
  );

  if (!confirm) return;

  try {
    await _reviewProvider.update(review.id!, {
      "Comment": review.comment,
      "Rating": review.rating,
      "isApproved": false,
      "isDenied": true,
    });

    await _notificationProvider.insert({
      "userId": review.user?.id,
      "receivedDate": DateTime.now().toIso8601String(),
      "title": "Recenzija odbijena",
      "message":
          "Vaša recenzija za knjigu '${review.book?.title}' je odbijena.",
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Recenzija odbijena")));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška prilikom odbijanja recenzije: $e")));
  }
}

// USER REVIEW ACTIONS
void _acceptUserReview(UserReview review) async {
  final confirm = await _confirmAction(
    context,
    "Prihvatanje korisničke recenzije",
    "Da li ste sigurni da želite prihvatiti ovu korisničku recenziju?",
  );

  if (!confirm) return;

  try {
    await _userReviewProvider.update(review.id!, {
      "Comment": review.comment,
      "Rating": review.rating,
      "isApproved": true,
      "isDenied": false,
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Korisnička recenzija prihvaćena")));
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Greška: $e")));
  }
}

void _declineUserReview(UserReview review) async {
  final confirm = await _confirmAction(
    context,
    "Odbijanje korisničke recenzije",
    "Da li ste sigurni da želite odbiti ovu korisničku recenziju?",
  );

  if (!confirm) return;

  try {
    await _userReviewProvider.update(review.id!, {
      "Comment": review.comment,
      "Rating": review.rating,
      "isApproved": false,
      "isDenied": true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Korisnička recenzija odbijena")));
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Greška: $e")));
  }
}


  Widget _buildFilters() {
    return Padding(
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
                    labelText: 'Datum recenzije',
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
            onPressed: () {
              setState(() {
                _emailController.clear();
                _nameController.clear();
                _selectedDate = null;
                _currentPage = 1;
                _currentPageUser = 1;
              });
              _loadReviews();
              _loadUserReviews();
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Pretraži',
            onPressed: () {
              setState(() {
                _currentPage = 1;
                _currentPageUser = 1;
              });
              _loadReviews();
              _loadUserReviews();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookReviewDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Korisnik')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Naslov knjige')),
          DataColumn(label: Text('Ocjena')),
          DataColumn(label: Text('Komentar')),
          DataColumn(label: Text('Datum')),
          DataColumn(label: Text('Akcije')),
        ],
        rows: _reviews.map((review) {
          final user = review.user;
          final book = review.book;
          return DataRow(
            cells: [
              DataCell(Text('${user?.firstName ?? ''} ${user?.lastName ?? ''}')),
              DataCell(Text(user?.email ?? '-')),
              DataCell(Text(book?.title ?? '-')),
              DataCell(Text(review.rating?.toString() ?? '-')),
              DataCell(Text(review.comment ?? '-')),
              DataCell(Text(review.reviewDate != null
                  ? DateTimeHelper.formatDateOnly(review.reviewDate!)
                  : '-')),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _acceptReview(review),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _declineReview(review),
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserReviewDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Korisnik')),
          DataColumn(label: Text('Meta recenzije')),
          DataColumn(label: Text('Ocjena')),
          DataColumn(label: Text('Komentar')),
          DataColumn(label: Text('Datum')),
          DataColumn(label: Text('Akcije')),
        ],
        rows: _userReviews.map((r) {
          final reviewer = r.reviewerUser;
          final reviewed = r.reviewedUser;

          return DataRow(
            cells: [
              DataCell(Text("${reviewer?.firstName ?? ''} ${reviewer?.lastName ?? ''}")),
              DataCell(Text("${reviewed?.firstName ?? ''} ${reviewed?.lastName ?? ''}")),
              DataCell(Text(r.rating?.toString() ?? '-')),
              DataCell(Text(r.comment ?? '-')),
              DataCell(Text(r.reviewDate != null
                  ? DateTimeHelper.formatDateOnly(r.reviewDate!)
                  : '-')),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _acceptUserReview(r),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _declineUserReview(r),
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentPage > 1
              ? () {
                  setState(() => _currentPage--);
                  _loadReviews();
                }
              : null,
        ),
        Text("Stranica $_currentPage od $_totalPages"),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _currentPage < _totalPages
              ? () {
                  setState(() => _currentPage++);
                  _loadReviews();
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildPaginationControlsUser() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentPageUser > 1
              ? () {
                  setState(() => _currentPageUser--);
                  _loadUserReviews();
                }
              : null,
        ),
        Text("Stranica $_currentPageUser od $_totalPagesUser"),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _currentPageUser < _totalPagesUser
              ? () {
                  setState(() => _currentPageUser++);
                  _loadUserReviews();
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildBookReviewsTable() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_reviews.isEmpty) return const Center(child: Text("Nema recenzija knjiga"));

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Recenzije na knjige", style: TextStyle(fontSize: 20)),
        ),
        Expanded(child: _buildBookReviewDataTable()),
        _buildPaginationControls(),
      ],
    );
  }

  Widget _buildUserReviewsTable() {
    if (_isLoadingUser) return const Center(child: CircularProgressIndicator());
    if (_errorUser != null) return Center(child: Text(_errorUser!));
    if (_userReviews.isEmpty) {
      return const Center(child: Text("Nema korisničkih recenzija"));
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Recenzije korisnika", style: TextStyle(fontSize: 20)),
        ),
        Expanded(child: _buildUserReviewDataTable()),
        _buildPaginationControlsUser(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isWide = constraints.maxWidth > 1100;

                return isWide
                    ? Row(
                        children: [
                          Expanded(child: _buildBookReviewsTable()),
                          VerticalDivider(width: 1, color: Colors.grey[400]),
                          Expanded(child: _buildUserReviewsTable()),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(child: _buildBookReviewsTable()),
                          Divider(height: 1, color: Colors.grey[400]),
                          Expanded(child: _buildUserReviewsTable()),
                        ],
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
