import 'package:elibrary_desktop/models/book.dart';
import 'package:elibrary_desktop/models/user.dart';
import 'package:flutter/material.dart';
import 'package:elibrary_desktop/models/book_exchange.dart';
import 'package:elibrary_desktop/models/book_exchange_status.dart';
import 'package:elibrary_desktop/providers/book_exchange_provider.dart';
import 'package:elibrary_desktop/models/search_result.dart';

class BookExchangeScreen extends StatefulWidget {
  const BookExchangeScreen({Key? key}) : super(key: key);

  @override
  State<BookExchangeScreen> createState() => _BookExchangeScreenState();
}

class _BookExchangeScreenState extends State<BookExchangeScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bookTitleController = TextEditingController();
  BookExchangeStatus? _selectedStatus;

  final _provider = BookExchangeProvider();

  List<BookExchange> _exchanges = [];
  int _currentPage = 1;
  final int _pageSize = 6;
  int _totalCount = 0;
  bool _isLoading = false;
  String? _error;

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _loadExchanges();
  }

  Future<void> _loadExchanges() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final SearchResult<BookExchange> result = await _provider.get(
        filter: {
          "Username": _usernameController.text.trim(),
          "Email": _emailController.text.trim(),
          "BookTitle": _bookTitleController.text.trim(),
          "BookExchangeStatus": _selectedStatus?.index,
          "Page": _currentPage - 1,
          "PageSize": _pageSize,
        },
      );

      setState(() {
        _exchanges = result.result;
        _totalCount = result.count ?? 0;

        if (_currentPage > _totalPages) {
          _currentPage = _totalPages;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = "Greška pri učitavanju razmjena: $e";
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _usernameController.clear();
      _emailController.clear();
      _bookTitleController.clear();
      _selectedStatus = null;
      _currentPage = 1;
    });
    _loadExchanges();
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Korisničko ime'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _bookTitleController,
              decoration: const InputDecoration(labelText: 'Naslov knjige'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<BookExchangeStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status razmjene'),
              items: BookExchangeStatus.values
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Resetuj filtere',
            onPressed: _resetFilters,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Pretraži',
            onPressed: () {
              _currentPage = 1;
              _loadExchanges();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeCard(BookExchange exchange) {
  final offerUser = exchange.offerUser;
  final receiverUser = exchange.receiverUser;
  final offerBook = exchange.offerBook;
  final receiverBook = exchange.receiverBook;
  final status = exchange.bookExchangeStatus ?? BookExchangeStatus.BookDeliveryPhase;

  const String placeholderImage = 'https://plus.unsplash.com/premium_photo-1669652639337-c513cc42ead6?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

  String getActionLabel() {
    return status == BookExchangeStatus.BookDeliveryPhase
        ? 'Potvrdi isporuku'
        : 'Potvrdi prijem';
  }

  Widget buildUserBookInfo(String label, User? user, Book? book) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person, size: 20),
              const SizedBox(width: 6),
              Text(user?.username ?? "-"),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.email, size: 20),
              const SizedBox(width: 6),
              Expanded(child: Text(user?.email ?? "-")),
            ],
          ),
          const SizedBox(height: 10),
          Text("Knjiga", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.book, size: 20),
                        const SizedBox(width: 6),
                        Expanded(child: Text(book?.title ?? "-")),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            (book?.author != null)
                                ? "${book!.author!.firstName} ${book.author!.lastName}"
                                : "-",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.category, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            (book?.genres?.map((g) => g.name).join(", ")) ?? "-",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.description, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            book?.description ?? "-",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  placeholderImage,
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  return Card(
    elevation: 4,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sync_alt, size: 24),
              const SizedBox(width: 8),
              Text(
                "Faza: ${status.displayName}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildUserBookInfo("Pošiljalac", offerUser, offerBook),
              Container(
                width: 1,
                height: 220,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              buildUserBookInfo("Primaoc", receiverUser, receiverBook),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!(exchange.offerUserAction ?? false))
                ElevatedButton.icon(
                  onPressed: () {
                    _handleUserAction(exchange.id!, isOfferUser: true);
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text("${getActionLabel()} - ${offerUser?.username ?? '-'}"),
                ),
              if (!(exchange.receiverUserAction ?? false))
                ElevatedButton.icon(
                  onPressed: () {
                    _handleUserAction(exchange.id!, isOfferUser: false);
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text("${getActionLabel()} - ${receiverUser?.username ?? '-'}"),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}



  Future<void> _handleUserAction(int exchangeId, {required bool isOfferUser}) async {
    try {
      final exchange = _exchanges.firstWhere((e) => e.id == exchangeId);

      final updated = BookExchange(
        id: exchange.id,
        offerUserId: exchange.offerUserId,
        receiverUserId: exchange.receiverUserId,
        offerBookId: exchange.offerBookId,
        receiverBookId: exchange.receiverBookId,
        offerUserAction: isOfferUser ? true : exchange.offerUserAction,
        receiverUserAction: isOfferUser ? exchange.receiverUserAction : true,
        bookExchangeStatus: exchange.bookExchangeStatus,
      );

      await _provider.update(exchangeId, updated.toJson());
      _loadExchanges();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    }
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
                  _loadExchanges();
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
                  _loadExchanges();
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
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text("Greška: $_error"))
                    : _exchanges.isEmpty
                        ? const Center(child: Text("Nema pronađenih razmjena."))
                        : ListView.builder(
                            itemCount: _exchanges.length,
                            itemBuilder: (context, index) =>
                                _buildExchangeCard(_exchanges[index]),
                          ),
          ),
          _buildPaginationControls(),
        ],
      ),
    );
  }
}
