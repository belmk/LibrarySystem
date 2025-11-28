import 'dart:convert';
import 'package:elibrary_mobile/models/book.dart';
import 'package:elibrary_mobile/models/genre.dart';
import 'package:elibrary_mobile/models/search_result.dart';
import 'package:elibrary_mobile/providers/auth_provider.dart';
import 'package:elibrary_mobile/providers/book_provider.dart';
import 'package:elibrary_mobile/providers/genre_provider.dart';
import 'package:elibrary_mobile/providers/book_loan_provider.dart';
import 'package:elibrary_mobile/screens/book_details_screen.dart';
import 'package:elibrary_mobile/screens/book_review_edit_screen.dart';
import 'package:elibrary_mobile/screens/book_review_screen.dart';
import 'package:elibrary_mobile/providers/book_review_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({Key? key}) : super(key: key);

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  late BookProvider _bookProvider;
  late GenreProvider _genreProvider;
  late BookLoanProvider _bookLoanProvider;
  late AuthProvider _authProvider;
  late BookReviewProvider _bookReviewProvider;

  List<Book> _recommendedBooks = [];
  bool _isRecommendedLoading = true;

  SearchResult<Book>? _bookResult;
  List<Genre> _genres = [];
  bool _isLoading = true;
  bool _isGenreLoading = true;
  String? _errorMessage;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  Genre? _selectedGenre;

  int _currentPage = 1;
  int _pageSize = 6;
  int _totalCount = 0;

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  Set<int> _borrowedBookIds = {};

  @override
  void initState() {
    super.initState();
    _bookProvider = context.read<BookProvider>();
    _genreProvider = context.read<GenreProvider>();
    _bookLoanProvider = context.read<BookLoanProvider>();
    _authProvider = context.read<AuthProvider>();
    _bookReviewProvider = context.read<BookReviewProvider>();

    _loadGenres();
    _loadBooks(); 
    _loadUserLoans(); 
    _loadRecommendedBooks();
  }

  Future<void> _loadRecommendedBooks() async {
  setState(() {
    _isRecommendedLoading = true;
  });

  if (_bookResult == null) {
    await _loadBooks();
  }

  final allBooks = _bookResult?.result ?? [];

  _recommendedBooks = allBooks.take(3).toList();

  setState(() {
    _isRecommendedLoading = false;
  });
}


  Future<void> _loadGenres() async {
    try {
      var result = await _genreProvider.get();
      setState(() {
        _genres = result.result;
        _isGenreLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isGenreLoading = false;
      });
    }
  }

  Future<void> _loadUserLoans() async {
    try {
      final userId = _authProvider.currentUser?.id;
      if (userId == null) return;

      final result = await _bookLoanProvider.get(filter: {
        "userId": userId,
      });

      final loans = result.result ?? [];
      setState(() {
        _borrowedBookIds = loans
            .where((loan) => loan.book?.id != null)
            .map((loan) => loan.book!.id!)
            .toSet();
      });
    } catch (e) {
      debugPrint("Failed to load user loans: $e");
    }
  }

  Future<void> _loadBooks({bool useFilters = true}) async {
    setState(() => _isLoading = true);

    try {
      final filter = {
        "title": _titleController.text.trim(),
        "author": _authorController.text.trim(),
        "genreId": _selectedGenre?.id,
        "isUserBook": false,
        "page": _currentPage - 1,
        "pageSize": _pageSize,
      };

      var result = await _bookProvider.get(filter: filter);
      setState(() {
        _bookResult = result;
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
    _titleController.clear();
    _authorController.clear();
    setState(() {
      _selectedGenre = null;
      _currentPage = 1;
    });
    _loadBooks();
  }

Widget _buildRecommendedSection() {
  if (_isRecommendedLoading) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  if (_recommendedBooks.isEmpty) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Možda vam se svidi...",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Column(
          children: _recommendedBooks.take(3).map(_buildBookCard).toList(),
        ),
      ],
    ),
  );
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

    final hasBorrowed = book.id != null && _borrowedBookIds.contains(book.id);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: imageProvider,
                width: 70,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title ?? "Nepoznat naslov",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          book.author != null
                              ? '${book.author!.firstName} ${book.author!.lastName}'
                              : 'Nepoznat autor',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.menu_book, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${book.pageNumber ?? '-'} stranica'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.inventory, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Dostupno ${book.availableNumber ?? '-'}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
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
                              builder: (context) => SizedBox(
                                height: MediaQuery.of(context).size.height * 0.9,
                                child: BookDetailsScreen(book: book),
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text("Detalji"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      if (hasBorrowed) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final authProvider = context.read<AuthProvider>();
                              final bookReviewProvider = context.read<BookReviewProvider>();

                              final userId = authProvider.currentUser?.id;
                              if (userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Morate biti prijavljeni da ostavite recenziju.")),
                                );
                                return;
                              }

                              try {
                                final reviewResult = await bookReviewProvider.get(filter: {
                                  "bookId": book.id,
                                  "userId": userId,
                                });

                                if (reviewResult.result.isNotEmpty) {
                                  // user left a review
                                  final existingReview = reviewResult.result.first;
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
                                        height: MediaQuery.of(context).size.height * 0.75,
                                        child: ExistingReviewScreen(
                                          review: existingReview,
                                          book: book,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
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
                                        height: MediaQuery.of(context).size.height * 0.75,
                                        child: BookReviewScreen(book: book),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Greška pri učitavanju recenzije: $e")),
                                );
                              }
                            },
                            icon: const Icon(Icons.rate_review),
                            label: const Text("Recenzija"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
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
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Naslov knjige',
            prefixIcon: Icon(Icons.book_outlined),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _authorController,
          decoration: const InputDecoration(
            labelText: 'Pisac',
            prefixIcon: Icon(Icons.person_search_outlined),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),

        _isGenreLoading
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<Genre>(
                decoration: const InputDecoration(
                  labelText: 'Žanr',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                value: _selectedGenre,
                items: _genres.map((g) {
                  return DropdownMenuItem(
                    value: g,
                    child: Text(g.name ?? ""),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedGenre = val);
                },
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
                _loadBooks(useFilters: true);
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
                    _loadBooks();
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
          ),
          Text("Stranica $_currentPage od $_totalPages"),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadBooks();
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
    if (_isLoading && _isGenreLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(child: Text("Greška: $_errorMessage")),
      );
    }

    var books = _bookResult?.result ?? [];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadBooks,
        child: ListView(
          children: [
            _buildFilters(),
            if (books.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text("Nema pronađenih knjiga")),
              )
            else
              ...books.map(_buildBookCard),
            _buildPaginationControls(),
            _buildRecommendedSection(),
          ],
        ),
      ),
    );
  }
}
