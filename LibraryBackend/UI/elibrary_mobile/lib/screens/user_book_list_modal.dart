import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elibrary_mobile/models/book.dart';
import 'package:elibrary_mobile/models/search_result.dart';
import 'package:elibrary_mobile/providers/book_provider.dart';

class UserBookListModal extends StatefulWidget {
  final int userId;
  const UserBookListModal({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserBookListModal> createState() => _UserBookListModalState();
}

class _UserBookListModalState extends State<UserBookListModal> {
  late BookProvider _bookProvider;
  SearchResult<Book>? _bookResult;
  bool _isLoading = true;
  String? _errorMessage;

  int _currentPage = 1;
  final int _pageSize = 6;
  int _totalCount = 0;
  Set<int> _borrowedBookIds = {};

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _bookProvider = context.read<BookProvider>();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      final filter = {
        "userId": widget.userId,
        "isUserBook": true,
        "page": _currentPage - 1,
        "pageSize": _pageSize,
      };
      final result = await _bookProvider.get(filter: filter);
      setState(() {
        _bookResult = result;
        _totalCount = result.count ?? 0;
        _isLoading = false;
        _borrowedBookIds = result.result!.where((b) => b.isUserBook ?? false).map((b) => b.id!).toSet();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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

    final hasBorrowed = book.id != null && _borrowedBookIds.contains(book.id);

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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          book.author != null ? '${book.author!.firstName} ${book.author!.lastName}' : 'Nepoznat autor',
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
                ],
              ),
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
            onPressed: _currentPage > 1 ? () { setState(() => _currentPage--); _loadBooks(); } : null,
            icon: const Icon(Icons.arrow_back),
          ),
          Text("Stranica $_currentPage od $_totalPages"),
          IconButton(
            onPressed: _currentPage < _totalPages ? () { setState(() => _currentPage++); _loadBooks(); } : null,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text("Greška: $_errorMessage"))
                : RefreshIndicator(
                    onRefresh: _loadBooks,
                    child: ListView(
                      children: [
                        if ((_bookResult?.result ?? []).isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: Text("Korisnik nema knjiga")),
                          )
                        else
                          ..._bookResult!.result!.map(_buildBookCard),
                        _buildPaginationControls(),
                      ],
                    ),
                  ),
      ),
    );
  }
}
