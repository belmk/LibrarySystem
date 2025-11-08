import 'package:elibrary_mobile/models/book.dart';
import 'package:elibrary_mobile/models/book_review.dart';
import 'package:elibrary_mobile/providers/book_review_provider.dart';
import 'package:elibrary_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookReviewScreen extends StatefulWidget {
  final Book book;

  const BookReviewScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<BookReviewScreen> createState() => _BookReviewScreenState();
}

class _BookReviewScreenState extends State<BookReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedRating;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  late BookReviewProvider _bookReviewProvider;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _bookReviewProvider = context.read<BookReviewProvider>();
    _authProvider = context.read<AuthProvider>();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Morate biti prijavljeni da ostavite recenziju.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final review = {
        "bookId": widget.book.id,
        "userId": user.id,
        "rating": _selectedRating,
        "comment": _commentController.text.trim(),
      };

      await _bookReviewProvider.insert(review);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recenzija uspješno poslana!")),
      );

      Navigator.of(context).pop(); // close modal
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri slanju recenzije: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Text(
                  "Recenzija za \"${widget.book.title}\"",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Ocjena",
                  border: OutlineInputBorder(),
                ),
                value: _selectedRating,
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text("${index + 1}"),
                  ),
                ),
                validator: (value) => value == null ? "Molimo izaberite ocjenu" : null,
                onChanged: (value) => setState(() => _selectedRating = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: "Komentar",
                  hintText: "Ostavite svoj komentar o knjizi...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Molimo unesite komentar" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitReview,
                icon: const Icon(Icons.send),
                label: Text(_isSubmitting ? "Slanje..." : "Pošalji recenziju"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
