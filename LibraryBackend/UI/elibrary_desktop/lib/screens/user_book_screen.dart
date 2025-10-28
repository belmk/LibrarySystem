import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:elibrary_desktop/models/book.dart';
import 'package:elibrary_desktop/models/genre.dart';
import 'package:elibrary_desktop/providers/book_provider.dart';
import 'package:elibrary_desktop/providers/genre_provider.dart';
import 'package:elibrary_desktop/providers/user_provider.dart';

class UserBookListScreen extends StatefulWidget {
  const UserBookListScreen({super.key});

  @override
  State<UserBookListScreen> createState() => _UserBookListScreenState();
}

class _UserBookListScreenState extends State<UserBookListScreen> {
  final _bookProvider = BookProvider();
  final _userProvider = UserProvider();
  final _genreProvider = GenreProvider();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  int? _selectedGenreId;

  List<Genre> _genres = [];
  List<Book> _books = [];
  int _totalCount = 0;
  int _pageSize = 6;
  int _currentPage = 1;
  bool _isLoading = false;
  String? _error;

  int get _totalPages => (_totalCount / _pageSize).ceil().clamp(1, double.infinity).toInt();

  @override
  void initState() {
    super.initState();
    _loadGenres();
    _loadBooks();
  }

  Future<void> _loadGenres() async {
    try {
      final result = await _genreProvider.get();
      setState(() {
        _genres = result.result;
      });
    } catch (e) {
      print("Failed to load genres: $e");
    }
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _bookProvider.get(filter: {
        "Title": _titleController.text.trim(),
        "Author": _authorController.text.trim(),
        "Username": _usernameController.text.trim(),
        "Email": _emailController.text.trim(),
        "GenreId": _selectedGenreId,
        "IsUserBook": true,
        "Page": _currentPage - 1,
        "PageSize": _pageSize,
      });

      setState(() {
        _books = result.result;
        _totalCount = result.count ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _confirmDelete(Book book, {bool warnUser = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Potvrda'),
        content: Text(warnUser
            ? "Da li želite da obrišete knjigu '${book.title}' i upozorite korisnika?"
            : "Da li želite da obrišete knjigu '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Ne"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteBook(book, warnUser: warnUser);
            },
            child: const Text("Da"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBook(Book book, {bool warnUser = false}) async {
    try {
      await _bookProvider.delete(book.id!);

      if (warnUser && book.userId != null) {
        await _userProvider.warnUser(book.userId!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            warnUser
                ? "Knjiga obrisana i korisnik upozoren."
                : "Knjiga obrisana.",
          ),
        ),
      );

      _loadBooks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    }
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _buildTextField(_titleController, 'Naslov'),
          const SizedBox(width: 8),
          _buildTextField(_authorController, 'Autor'),
          const SizedBox(width: 8),
          _buildTextField(_usernameController, 'Korisničko ime'),
          const SizedBox(width: 8),
          _buildTextField(_emailController, 'Email'),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedGenreId,
              decoration: const InputDecoration(labelText: 'Žanr'),
              items: [
                const DropdownMenuItem<int>(value: null, child: Text('Svi žanrovi')),
                ..._genres.map(
                  (g) => DropdownMenuItem<int>(
                    value: g.id,
                    child: Text(g.name ?? 'Nepoznat'),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGenreId = value;
                  _currentPage = 1;
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Resetuj filtere',
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            onPressed: () {
              setState(() {
                _titleController.clear();
                _authorController.clear();
                _usernameController.clear();
                _emailController.clear();
                _selectedGenreId = null;
                _currentPage = 1;
              });
              _loadBooks();
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Pretraži',
            onPressed: () {
              _currentPage = 1;
              _loadBooks();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Expanded(
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _buildBookCard(Book book) {
  final genreNames = book.genres?.map((g) => g.name).whereType<String>().join(', ') ?? '-';

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.title ?? 'Untitled',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${book.author?.firstName ?? ''} ${book.author?.lastName ?? ''}'.trim().isNotEmpty
                ? '${book.author!.firstName} ${book.author!.lastName}'
                : '-',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Korisnik: ${book.user!.username ?? 'Nepoznat'}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              book.description ?? 'Bez opisa',
              style: const TextStyle(fontSize: 14),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
           SizedBox(
              width: 150, 
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (book.coverImageBase64 != null && book.coverImageBase64!.isNotEmpty)
                    ? Image.memory(
                        base64Decode(book.coverImageBase64!),
                        fit: BoxFit.fill,
                      )
                    : Image.asset(
                        'assets/placeholder.jpg',
                        fit: BoxFit.fill,
                      ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            genreNames,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Broj stranica: ${book.pageNumber ?? '-'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                tooltip: 'Obriši',
                onPressed: () => _confirmDelete(book),
              ),
              IconButton(
                icon: const Icon(Icons.warning, color: Colors.orange, size: 20),
                tooltip: 'Obriši i upozori korisnika',
                onPressed: () => _confirmDelete(book, warnUser: true),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Dostupno: ${book.availableNumber ?? 0}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          
        ],
      ),
    ),
  );
}


  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 1
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                  _loadBooks();
                }
              : null,
          icon: const Icon(Icons.arrow_back),
        ),
        Text("Stranica $_currentPage od $_totalPages"),
        IconButton(
          onPressed: _currentPage < _totalPages
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                  _loadBooks();
                }
              : null,
          icon: const Icon(Icons.arrow_forward),
        ),
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
            child: _error != null
                ? Center(child: Text('Greška: $_error'))
                : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1, 
                        ),

                        itemCount: _books.length,
                        itemBuilder: (_, index) => _buildBookCard(_books[index]),
                      ),
          ),
          _buildPagination(),
        ],
      ),
    );
  }
}
