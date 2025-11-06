import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elibrary_mobile/models/book.dart';
import 'package:elibrary_mobile/models/genre.dart';
import 'package:elibrary_mobile/providers/book_provider.dart';
import 'package:elibrary_mobile/providers/genre_provider.dart';
import 'package:elibrary_mobile/models/search_result.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({Key? key}) : super(key: key);

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  late BookProvider _bookProvider;
  late GenreProvider _genreProvider;

  SearchResult<Book>? _bookResult;
  List<Genre> _genres = [];
  bool _isLoading = true;
  bool _isGenreLoading = true;
  String? _errorMessage;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  Genre? _selectedGenre;

  // Pagination
  int _currentPage = 1;
  int _pageSize = 6;
  int _totalCount = 0;

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _bookProvider = context.read<BookProvider>();
    _genreProvider = context.read<GenreProvider>();
    _loadGenres();
    _loadBooks();
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

  Future<void> _loadBooks({bool useFilters = false}) async {
    setState(() => _isLoading = true);

    try {
      final filter = {
        "title": _titleController.text.trim(),
        "author": _authorController.text.trim(),
        "genreId": _selectedGenre?.id,
        "page": _currentPage - 1,
        "pageSize": _pageSize,
      };

      var result = await _bookProvider.get(filter: useFilters ? filter : null);
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
                            // TODO: Navigate to details
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to review
                          },
                          icon: const Icon(Icons.rate_review),
                          label: const Text("Recenzija"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
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
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _authorController,
            decoration: const InputDecoration(
              labelText: 'Pisac',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          _isGenreLoading
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<Genre>(
                  decoration: const InputDecoration(
                    labelText: 'Žanr',
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _loadBooks(useFilters: true),
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
                    _loadBooks(useFilters: true);
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
          ),
          Text("Stranica $_currentPage od $_totalPages"),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadBooks(useFilters: true);
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
      appBar: AppBar(title: const Text("Knjige")),
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
          ],
        ),
      ),
    );
  }
}
