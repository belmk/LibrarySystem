import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/book_exchange_provider.dart';
import '../models/book_exchange.dart';
import '../models/book_exchange_status.dart';

class PendingBookExchangeScreen extends StatefulWidget {
  const PendingBookExchangeScreen({Key? key}) : super(key: key);

  @override
  State<PendingBookExchangeScreen> createState() =>
      _PendingBookExchangeScreenState();
}

class _PendingBookExchangeScreenState extends State<PendingBookExchangeScreen> {
  late BookExchangeProvider _bookExchangeProvider;
  late AuthProvider _authProvider;

  List<BookExchange> _pendingExchanges = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bookExchangeProvider = context.read<BookExchangeProvider>();
    _authProvider = context.read<AuthProvider>();
    _loadPendingExchanges();
  }

  Future<void> _loadPendingExchanges() async {
    try {
      setState(() => _isLoading = true);

      final userId = _authProvider.currentUser?.id;
      if (userId == null) {
        setState(() {
          _errorMessage = "Niste prijavljeni.";
          _isLoading = false;
        });
        return;
      }

      final result = await _bookExchangeProvider.get(
        filter: {
          "receiverUserId": userId,
          "bookExchangeStatus": BookExchangeStatus.PendingApproval.index,
        },
      );

      setState(() {
        _pendingExchanges = result.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Greška pri učitavanju zahtjeva: $e";
        _isLoading = false;
      });
    }
  }

  Widget _buildExchangeCard(BookExchange exchange) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.swap_horiz, size: 32, color: Colors.orange),
        title: Text(
          "Ponuda od ${exchange.offerUser?.username ?? "Nepoznat korisnik"}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Nudi: ${exchange.offerBook?.title ?? '-'} (${exchange.offerBook?.author?.firstName ?? ''} ${exchange.offerBook?.author?.lastName ?? ''})",
            ),
            Text(
              "Traži: ${exchange.receiverBook?.title ?? '-'} (${exchange.receiverBook?.author?.firstName ?? ''} ${exchange.receiverBook?.author?.lastName ?? ''})",
            ),

            const SizedBox(height: 4),
            Text(
              "${exchange.bookExchangeStatus?.displayName ?? '-'}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: ElevatedButton(
          child: const Text("Pregled"),
          onPressed: () {
            
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Zahtjevi za razmjenu")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _pendingExchanges.isEmpty
                  ? const Center(child: Text("Nema novih zahtjeva."))
                  : RefreshIndicator(
                      onRefresh: _loadPendingExchanges,
                      child: ListView.builder(
                        itemCount: _pendingExchanges.length,
                        itemBuilder: (context, index) {
                          return _buildExchangeCard(_pendingExchanges[index]);
                        },
                      ),
                    ),
    );
  }
}
