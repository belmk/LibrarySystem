import 'dart:convert';
import 'package:elibrary_mobile/models/book.dart';
import 'package:elibrary_mobile/models/genre.dart';
import 'package:elibrary_mobile/models/search_result.dart';
import 'package:elibrary_mobile/providers/auth_provider.dart';
import 'package:elibrary_mobile/providers/author_provider.dart';
import 'package:elibrary_mobile/providers/book_provider.dart';
import 'package:elibrary_mobile/providers/genre_provider.dart';
import 'package:elibrary_mobile/screens/book_create_screen.dart';
import 'package:elibrary_mobile/screens/book_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserBooksScreen extends StatefulWidget {
  const UserBooksScreen({Key? key}) : super(key: key);

  @override
  State<UserBooksScreen> createState() => _UserBooksScreenState();
}

class _UserBooksScreenState extends State<UserBooksScreen> {
  late BookProvider _bookProvider;
  late GenreProvider _genreProvider;
  late AuthProvider _authProvider;

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

  @override
  void initState() {
    super.initState();
    _bookProvider = context.read<BookProvider>();
    _genreProvider = context.read<GenreProvider>();
    _authProvider = context.read<AuthProvider>();

    _loadGenres();
    _loadUserBooks();
  }

  Future<void> _loadGenres() async {
    try {
      final result = await _genreProvider.get();
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

  Future<void> _loadUserBooks({bool useFilters = true}) async {
    setState(() => _isLoading = true);

    try {
      final userId = _authProvider.currentUser?.id;
      if (userId == null) return;

      final filter = {
        "title": _titleController.text.trim(),
        "author": _authorController.text.trim(),
        "genreId": _selectedGenre?.id,
        "isUserBook": true,
        "userId": userId,
        "page": _currentPage - 1,
        "pageSize": _pageSize,
      };

      final result = await _bookProvider.get(filter: filter);

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
    _loadUserBooks();
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
        padding: const EdgeInsets.all(8),
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
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
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
                  items: _genres
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g.name ?? ""),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _selectedGenre = val);
                  },
                ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _currentPage = 1);
                  _loadUserBooks();
                },
                icon: const Icon(Icons.search, color: Colors.blueAccent),
              ),
              IconButton(
                onPressed: _resetFilters,
                icon: const Icon(Icons.refresh, color: Colors.grey),
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
                    _loadUserBooks();
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
          ),
          Text("Stranica $_currentPage od $_totalPages"),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadUserBooks();
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

    final books = _bookResult?.result ?? [];

    return Scaffold(
  floatingActionButton: FloatingActionButton(
    onPressed: () async {
      final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BookCreateScreen(),
  ),
);


      if (result == true) {
        _currentPage = 1;      
        await _loadUserBooks(); 
      }
    },
    backgroundColor: Colors.blue,
    child: const Icon(Icons.add),
  ),
  body: RefreshIndicator(
    onRefresh: () => _loadUserBooks(),
    child: ListView(
      children: [
        _buildFilters(),
        if (books.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text("Nemate unesenih knjiga")),
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
