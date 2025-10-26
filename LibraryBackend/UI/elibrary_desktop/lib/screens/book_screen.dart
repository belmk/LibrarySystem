import 'dart:convert';

import 'package:elibrary_desktop/screens/book_create_screen.dart';
import 'package:flutter/material.dart';
import 'package:elibrary_desktop/models/book.dart';
import 'package:elibrary_desktop/models/genre.dart';
import 'package:elibrary_desktop/providers/book_provider.dart';
import 'package:elibrary_desktop/providers/genre_provider.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({Key? key}) : super(key: key);

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  late GenreProvider _genreProvider;
  List<Genre> _genres = [];
  int? _selectedGenreId;
  late BookProvider _bookProvider;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  List<Book> _books = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _pageSize = 6;
  int _totalCount = 0;

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _bookProvider = BookProvider();
    _genreProvider = GenreProvider();
    _loadGenres();
    _loadBooks();
  }

  Future<void> _loadGenres() async {
  try {
    final genres = await _genreProvider.get(); 
    if (mounted) {
      setState(() {
        _genres = genres.result;
      });
    }
  } catch (e) {
    print("Failed to load genres: $e");
  }
}

void _confirmDelete(Book book) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Potvrda"),
      content: Text("Da li želite da obrišete knjigu '${book.title}'?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), 
          child: const Text("Ne"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); 
            await _deleteBook(book.id!); 
          },
          child: const Text("Da"),
        ),
      ],
    ),
  );
}

Future<void> _deleteBook(int id) async {
  try {
    await _bookProvider.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Knjiga je uspješno obrisana.")),
    );
    _loadBooks(); 
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška pri brisanju knjige: $e")),
    );
  }
}
  Future<void> _loadBooks({bool showLoading = true}) async {
  if (showLoading) {
    setState(() {
      _isLoading = true;
      _error = null;
    });
  }

  try {
    final result = await _bookProvider.get(
      filter: {
        "Title": _titleController.text.trim(),
        "Author": _authorController.text.trim(),
        "GenreId": _selectedGenreId,
        "IsUserBook": false,
        "Page": _currentPage - 1,
        "PageSize": _pageSize,
      },
    );

    if (mounted) {
      setState(() {
        _books = result.result;
        _totalCount = result.count ?? 0;

        if (_currentPage > _totalPages) {
          _currentPage = _totalPages;
        }

        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _error = "Greška pri učitavanju knjiga: ${e.toString()}";
      });
    }
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    floatingActionButton: FloatingActionButton(
    onPressed: () async {
      final result = await showDialog(
        context: context,
        builder: (context) => const BookFormScreen(),
      );

      if (result == true) {
        _loadBooks(); 
      }

      print('Create new book');
    },
    child: const Icon(Icons.add),
    tooltip: 'Dodaj novu knjigu',
  ),
    body: Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Naslov knjige'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _authorController,
                    decoration: const InputDecoration(labelText: 'Autor'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedGenreId,
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text("Svi žanrovi"),
                      ),
                      ..._genres.map((genre) => DropdownMenuItem<int>(
                        value: genre.id,
                        child: Text(genre.name ?? "Nepoznat"),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGenreId = value;
                        _currentPage = 1;
                      });
                      //_loadBooks();
                    },
                    decoration: const InputDecoration(labelText: 'Žanr'),
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
          ),

          const SizedBox(height: 16),
          Expanded(
            child: _error != null
                ? Center(child: Text('Error: $_error'))
                : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1,
                        ),
                        itemCount: _books.length,
                        itemBuilder: (context, index) {
                          final book = _books[index];
                          return BookCard(
                            book: book,
                            onEdit: () async {
                            final result = await showDialog(
                              context: context,
                              builder: (_) => BookFormScreen(book: book),
                            );

                            if (result == true) {
                              _loadBooks();
                            }

                            },
                            onDelete: () {
                              _confirmDelete(book);
                            },
                          );
                        },
                      ),
          ),
         _buildPaginationControls(),
        ],
      ),
    ),
  );
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
}

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookCard({
      Key? key,
      required this.book,
      required this.onEdit,
      required this.onDelete,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                book.description ?? 'No description',
                style: const TextStyle(fontSize: 14),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
  child: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: (book.coverImageBase64 != null && book.coverImageBase64!.isNotEmpty)
        ? Image.memory(
            base64Decode(book.coverImageBase64!),
            fit: BoxFit.cover,
            width: double.infinity,
          )
        : Image.asset(
            'assets/placeholder.jpg', 
            fit: BoxFit.cover,
            width: double.infinity,
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
      icon: const Icon(Icons.edit, color: Colors.amber, size: 20),
      tooltip: 'Uredi',
      onPressed: onEdit
    ),
    IconButton(
      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
      tooltip: 'Obriši',
      onPressed: onDelete
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

  
}