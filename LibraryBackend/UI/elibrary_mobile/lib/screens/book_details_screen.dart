import 'dart:convert';
import 'package:elibrary_mobile/models/book.dart';
import 'package:elibrary_mobile/models/book_review.dart';
import 'package:elibrary_mobile/models/book_loan.dart';
import 'package:elibrary_mobile/models/book_loan_status.dart';
import 'package:elibrary_mobile/models/search_result.dart';
import 'package:elibrary_mobile/providers/book_review_provider.dart';
import 'package:elibrary_mobile/providers/book_loan_provider.dart';
import 'package:elibrary_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;

  const BookDetailsScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late BookReviewProvider _bookReviewProvider;
  late BookLoanProvider _bookLoanProvider;
  late AuthProvider _authProvider;

  SearchResult<BookReview>? _reviewResult;
  bool _isLoading = true;
  String? _errorMessage;

  int _currentPage = 1;
  int _pageSize = 5;
  int _totalCount = 0;

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  double? _averageRating;

  @override
  void initState() {
    super.initState();
    _bookReviewProvider = context.read<BookReviewProvider>();
    _bookLoanProvider = context.read<BookLoanProvider>();
    _authProvider = context.read<AuthProvider>();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);

    try {
      final filter = {
        "bookId": widget.book.id,
        "isApproved": true,
        "isDenied": false,
        "page": _currentPage - 1,
        "pageSize": _pageSize,
      };

      final result = await _bookReviewProvider.get(filter: filter);
      final reviews = result.result ?? [];

      double avgRating = 0;
      if (reviews.isNotEmpty) {
        avgRating = reviews.map((r) => r.rating ?? 0).reduce((a, b) => a + b) /
            reviews.length;
      }

      setState(() {
        _reviewResult = result;
        _totalCount = result.count ?? 0;
        _averageRating = avgRating;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendLoanRequest() async {
  final userId = _authProvider.currentUser?.id;
  final bookId = widget.book.id;

  if (userId == null || bookId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Neuspjela akcija: korisnik ili knjiga nisu pronađeni"),
      ),
    );
    return;
  }

  final requestBody = {
    "userId": userId,
    "bookId": bookId,
  };

  try {
    await _bookLoanProvider.insert(requestBody);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Zahtjev za posudbu je poslan!")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Neuspjelo slanje zahtjeva: $e")),
    );
  }
}


  Widget _buildBookInfo() {
    final book = widget.book;

    ImageProvider imageProvider;
    if (book.coverImageBase64 != null && book.coverImageBase64!.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(book.coverImageBase64!));
      } catch (e) {
        imageProvider = const AssetImage('assets/placeholder.jpg');
      }
    } else {
      imageProvider = const AssetImage('assets/placeholder.jpg');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image(
              image: imageProvider,
              width: 150,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            book.title ?? "Nepoznat naslov",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            book.author != null
                ? "${book.author!.firstName} ${book.author!.lastName}"
                : "Nepoznat autor",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 12),
        if (_averageRating != null && _averageRating! > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                _averageRating!.toStringAsFixed(1),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        const Divider(height: 30),
        Row(
          children: [
            const Icon(Icons.person, size: 20, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                book.author != null
                    ? "${book.author!.firstName} ${book.author!.lastName}"
                    : "Nepoznat autor",
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.menu_book, size: 20, color: Colors.grey),
            const SizedBox(width: 6),
            Text("${book.pageNumber ?? '-'} stranica",
                style: const TextStyle(fontSize: 15)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.inventory, size: 20, color: Colors.grey),
            const SizedBox(width: 6),
            Text("${book.availableNumber ?? '-'}",
                style: const TextStyle(fontSize: 15)),
          ],
        ),
        const SizedBox(height: 8),
        if (book.genres != null && book.genres!.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.category, size: 20, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  book.genres!.map((g) => g.name ?? '').join(', '),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.description, size: 20, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                book.description?.isNotEmpty == true
                    ? book.description!
                    : "Nema opisa.",
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        const Divider(height: 30),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _sendLoanRequest,
            icon: const Icon(Icons.send),
            label: const Text("Pošalji zahtjev za posudbu"), //TODO: hide button if loan request exists
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(BookReview review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.grey),
        title: Row(
          children: [
            Text(review.user?.username ?? "Nepoznat korisnik"),
            const SizedBox(width: 8),
            ...List.generate(
              review.rating ?? 0,
              (i) => const Icon(Icons.star, color: Colors.amber, size: 16),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (review.comment != null && review.comment!.isNotEmpty)
              Text(review.comment!),
            if (review.reviewDate != null)
              Text(
                "${review.reviewDate!.toLocal().toString().split(' ')[0]}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
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
                    _loadReviews();
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
          ),
          Text("Stranica $_currentPage od $_totalPages"),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadReviews();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalji knjige"),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text("Greška: $_errorMessage"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      _buildBookInfo(),
                      const SizedBox(height: 16),
                      Text(
                        "Recenzije:",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_reviewResult?.result.isEmpty ?? true)
                        const Text("Nema recenzija za ovu knjigu.")
                      else
                        ..._reviewResult!.result!.map(_buildReviewCard),
                      _buildPaginationControls(),
                    ],
                  ),
                ),
    );
  }
}
