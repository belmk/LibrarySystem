import 'dart:convert';
import 'package:elibrary_mobile/models/book.dart';
import 'package:elibrary_mobile/models/book_review.dart';
import 'package:elibrary_mobile/models/search_result.dart';
import 'package:elibrary_mobile/providers/book_provider.dart';
import 'package:elibrary_mobile/providers/book_review_provider.dart';
import 'package:elibrary_mobile/providers/auth_provider.dart';
import 'package:elibrary_mobile/providers/book_exchange_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserBookDetailsScreen extends StatefulWidget {
  final Book book;

  const UserBookDetailsScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<UserBookDetailsScreen> createState() => _UserBookDetailsScreenState();
}

class _UserBookDetailsScreenState extends State<UserBookDetailsScreen> {
  late BookReviewProvider _bookReviewProvider;
  late AuthProvider _authProvider;
  late BookExchangeProvider _bookExchangeProvider;

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
    _authProvider = context.read<AuthProvider>();
    _bookExchangeProvider = context.read<BookExchangeProvider>();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadReviews();
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
        avgRating = reviews.map((r) => r.rating ?? 0).reduce((a, b) => a + b) / reviews.length;
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

  Future<void> _openSelectBookModal() async {
    final selectedBook = await showModalBottomSheet<Book>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SelectUserBookScreen(
        receiverBook: widget.book,
      ),
    );

    if (selectedBook != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Zahtjev za zamjenu poslan!")),
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
            const Icon(Icons.account_circle, size: 20, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                book.user != null ? book.user!.username ?? "Nepoznat korisnik" : "Nepoznat korisnik",
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
            onPressed: _openSelectBookModal,
            icon: const Icon(Icons.send),
            label: const Text("Pošalji upit za zamjenu"),
            style: ElevatedButton.styleFrom(
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
        title: const Text("Detalji korisničke knjige"),
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
                      const Text(
                        "Recenzije:",
                        style: TextStyle(
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

class SelectUserBookScreen extends StatefulWidget {
  final Book receiverBook;

  const SelectUserBookScreen({Key? key, required this.receiverBook}) : super(key: key);

  @override
  State<SelectUserBookScreen> createState() => _SelectUserBookScreenState();
}

class _SelectUserBookScreenState extends State<SelectUserBookScreen> {
  late BookProvider _bookProvider;
  late AuthProvider _authProvider;
  late BookExchangeProvider _bookExchangeProvider;

  List<Book> _userBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bookProvider = context.read<BookProvider>();
    _authProvider = context.read<AuthProvider>();
    _bookExchangeProvider = context.read<BookExchangeProvider>();
    _loadUserBooks();
  }

  Future<void> _loadUserBooks() async {
    setState(() => _isLoading = true);
    final userId = _authProvider.currentUser?.id;
    if (userId != null) {
      final filter = {
        "userId": userId,
        "isUserBook": true,
      };
      final books = await _bookProvider.get(filter: filter);
      setState(() {
        _userBooks = books.result;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectBook(Book offerBook) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Potvrda"),
        content: const Text("Da li ste sigurni da želite odabrati ovu knjigu za zamjenu?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Ne")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Da")),
        ],
      ),
    );

    if (confirm != true) return;

    final userId = _authProvider.currentUser?.id;
    final receiverId = widget.receiverBook.user?.id;
    if (userId != null && receiverId != null) {
      await _bookExchangeProvider.insert({
        "offerUserId": userId,
        "receiverUserId": receiverId,
        "offerBookId": offerBook.id,
        "receiverBookId": widget.receiverBook.id,
      });
      Navigator.pop(context, offerBook);
    }
  }

  Widget _buildBookCard(Book book) {
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image(image: imageProvider, width: 50, height: 70, fit: BoxFit.cover),
        ),
        title: Text(book.title ?? "Nepoznat naslov"),
        subtitle: Text(book.author != null ? "${book.author!.firstName} ${book.author!.lastName}" : "Nepoznat autor"),
        trailing: ElevatedButton(
          onPressed: () => _selectBook(book),
          child: const Text("Odaberi"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userBooks.isEmpty
              ? const Center(child: Text("Nemate dostupnih knjiga za zamjenu."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _userBooks.length,
                  itemBuilder: (_, index) => _buildBookCard(_userBooks[index]),
                ),
    );
  }
}
