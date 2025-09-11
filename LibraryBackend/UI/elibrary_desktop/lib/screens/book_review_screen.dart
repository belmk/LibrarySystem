import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:elibrary_desktop/models/book_review.dart';
import 'package:elibrary_desktop/providers/book_review_provider.dart';
import 'package:elibrary_desktop/providers/user_provider.dart';

class BookReviewScreen extends StatefulWidget {
  const BookReviewScreen({Key? key}) : super(key: key);

  @override
  State<BookReviewScreen> createState() => _BookReviewScreenState();
}

class _BookReviewScreenState extends State<BookReviewScreen> {
  final BookReviewProvider _reviewProvider = BookReviewProvider();
  final UserProvider _userProvider = UserProvider();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _selectedDate;

  List<BookReview> _reviews = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

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
      });

      setState(() {
        _reviews = result.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Greška pri učitavanju recenzija: $e";
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

  void _acceptReview(BookReview review) async {
  try {
    await _reviewProvider.update(review.id!, {
      "Comment": review.comment,
      "Rating": review.rating,
      "isApproved": true,
      "isDenied": false,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Recenzija prihvaćena")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška prilikom prihvaćanja recenzije: $e")),
    );
  }
}

void _declineReview(BookReview review) async {
  try {
    await _reviewProvider.update(review.id!, {
      "Comment": review.comment,
      "Rating": review.rating,
      "isApproved": true,
      "isDenied": true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Recenzija odbijena")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška prilikom odbijanja recenzije: $e")),
    );
  }
}

void _declineAndWarnUser(BookReview review) async {
  try {
    await _reviewProvider.update(review.id!, {
      "Comment": review.comment,
      "Rating": review.rating,
      "isApproved": true,
      "isDenied": true,
    });

    // You may add a separate API call here to warn the user if needed
    await _userProvider.warnUser(review.user?.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Recenzija odbijena i korisnik upozoren")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška prilikom odbijanja i upozoravanja korisnika: $e")),
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
                        decoration: const InputDecoration(labelText: 'Datum recenzije',
                                                          suffixIcon: Icon(Icons.calendar_today),),
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
                ElevatedButton.icon(
                  onPressed: _loadReviews,
                  icon: const Icon(Icons.search),
                  label: const Text('Pretraži'),
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
                      : _reviews.isEmpty
                          ? const Center(child: Text('Nema recenzija'))
                          : SingleChildScrollView(
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
                                          ? DateFormat('yyyy-MM-dd').format(review.reviewDate!)
                                          : '-')),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check, color: Colors.green),
                                            tooltip: 'Prihvati',
                                            onPressed: () => _acceptReview(review),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.red),
                                            tooltip: 'Odbij',
                                            onPressed: () => _declineReview(review),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.warning, color: Colors.orange),
                                            tooltip: 'Odbij i upozori',
                                            onPressed: () => _declineAndWarnUser(review),
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
