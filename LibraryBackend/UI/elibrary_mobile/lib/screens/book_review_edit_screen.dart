import 'package:elibrary_mobile/models/book.dart';
import 'package:elibrary_mobile/models/book_review.dart';
import 'package:elibrary_mobile/providers/book_review_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExistingReviewScreen extends StatefulWidget {
  final BookReview review;
  final Book book;

  const ExistingReviewScreen({
    Key? key,
    required this.review,
    required this.book,
  }) : super(key: key);

  @override
  State<ExistingReviewScreen> createState() => _ExistingReviewScreenState();
}

class _ExistingReviewScreenState extends State<ExistingReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late int? _selectedRating;
  late TextEditingController _commentController;
  bool _isEditing = false;
  bool _isSubmitting = false;

  late BookReviewProvider _bookReviewProvider;

  @override
  void initState() {
    super.initState();
    _bookReviewProvider = context.read<BookReviewProvider>();
    _selectedRating = (widget.review.rating != null &&
            widget.review.rating! >= 1 &&
            widget.review.rating! <= 5)
        ? widget.review.rating
        : null;
    _commentController = TextEditingController(text: widget.review.comment ?? "");
  }

  Future<void> _updateReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _bookReviewProvider.update(widget.review.id!, {
        "rating": _selectedRating,
        "comment": _commentController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recenzija uspješno ažurirana!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri ažuriranju recenzije: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteReview() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Brisanje recenzije"),
        content: const Text("Da li ste sigurni da želite obrisati ovu recenziju?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Otkaži")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Obriši"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);

    try {
      await _bookReviewProvider.delete(widget.review.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recenzija uspješno obrisana!")),
      );
      Navigator.pop(context); // Close modal
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri brisanju recenzije: $e")),
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
                  "Vaša recenzija za \"${widget.book.title}\"",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // Dropdown copied from BookReviewScreen
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
                validator: (value) =>
                    value == null ? "Molimo izaberite ocjenu" : null,
                onChanged: _isEditing
                    ? (value) => setState(() => _selectedRating = value)
                    : null,
              ),
              const SizedBox(height: 16),

              // TextField copied from BookReviewScreen
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: "Komentar",
                  hintText: "Ostavite svoj komentar o knjizi...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) => value == null || value.trim().isEmpty
                    ? "Molimo unesite komentar"
                    : null,
                enabled: _isEditing,
              ),
              const SizedBox(height: 24),

              if (!_isEditing)
                ElevatedButton.icon(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit),
                  label: const Text("Uredi recenziju"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _updateReview,
                  icon: const Icon(Icons.save),
                  label: Text(_isSubmitting ? "Spremanje..." : "Spremi promjene"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _deleteReview,
                icon: const Icon(Icons.delete),
                label: const Text("Obriši recenziju"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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
