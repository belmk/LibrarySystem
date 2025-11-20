import 'package:elibrary_mobile/models/book_exchange_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/book_exchange.dart';
import '../providers/book_exchange_provider.dart';

class ExchangeDetailsScreen extends StatelessWidget {
  final BookExchange exchange;

  const ExchangeDetailsScreen({super.key, required this.exchange});

  Future<bool?> confirm(BuildContext context, String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Ne"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Da"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookExchangeProvider>(context, listen: false);

    final offerUser = exchange.offerUser?.username ?? '-';
    final receiverUser = exchange.receiverUser?.username ?? '-';
    final offerBook = exchange.offerBook;
    final receiverBook = exchange.receiverBook;
    final status = exchange.bookExchangeStatus?.displayName ?? '-';

    Widget sectionTitle(String text) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }

    Widget row(IconData icon, String text) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: Colors.blueGrey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    Widget bookSection(Book? book) {
      if (book == null) return const Text("-");
      final author = "${book.author?.firstName ?? ''} ${book.author?.lastName ?? ''}";
      final genres = (book.genres ?? []).map((g) => g.name).join(", ");
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          row(Icons.book, book.title ?? '-'),
          row(Icons.person, author),
          row(Icons.description, book.description ?? '-'),
          row(Icons.menu_book, "Broj stranica: ${book.pageNumber ?? '-'}"),
          row(Icons.category, genres),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalji razmjene"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle("Ponuditelj"),
                  row(Icons.person, offerUser),
                  const SizedBox(height: 8),
                  bookSection(offerBook),
                  const SizedBox(height: 20),
                  sectionTitle("Primatelj"),
                  row(Icons.person, receiverUser),
                  const SizedBox(height: 8),
                  bookSection(receiverBook),
                  const SizedBox(height: 20),
                  row(Icons.info, status),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmed = await confirm(
                        context,
                        "Prihvati razmjenu",
                        "Jeste li sigurni da želite prihvatiti razmjenu?",
                      );
                      if (confirmed == true) {
                        await provider.update(exchange.id!, {
                          "receiverUserAction": true
                        });
                        Navigator.pop(context, true);
                      }
                    },
                    child: const Text("Prihvati"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmed = await confirm(
                        context,
                        "Odbij razmjenu",
                        "Jeste li sigurni da želite odbiti i obrisati razmjenu?",
                      );
                      if (confirmed == true) {
                        await provider.delete(exchange.id!);
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Odbij"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
