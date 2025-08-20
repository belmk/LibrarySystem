import 'package:flutter/material.dart';
import 'package:elibrary_desktop/models/genre.dart';
import 'package:elibrary_desktop/models/author.dart';
import 'package:elibrary_desktop/models/book.dart'; // Ensure this exists
import 'package:elibrary_desktop/providers/book_provider.dart';
import 'package:elibrary_desktop/providers/author_provider.dart';
import 'package:elibrary_desktop/providers/genre_provider.dart';

class BookFormScreen extends StatefulWidget {
  final Book? book; // null for insert, not null for edit

  const BookFormScreen({Key? key, this.book}) : super(key: key);

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pageNumberController = TextEditingController();
  final _availableNumberController = TextEditingController();

  int? _selectedAuthorId;
  List<int> _selectedGenreIds = [];

  List<Author> _authors = [];
  List<Genre> _genres = [];

  final _bookProvider = BookProvider();
  final _authorProvider = AuthorProvider();
  final _genreProvider = GenreProvider();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadAuthorsAndGenres();

    if (widget.book != null) {
      final book = widget.book!;
      _titleController.text = book.title!;
      _descriptionController.text = book.description ?? '';
      _pageNumberController.text = book.pageNumber.toString();
      _availableNumberController.text = book.availableNumber.toString();
      _selectedAuthorId = book.author?.id;
      _selectedGenreIds = (book.genres ?? []).map((g) => g.id!).toList();
    }
  }

  Future<void> _loadAuthorsAndGenres() async {
    try {
      final authorsResult = await _authorProvider.get();
      final genresResult = await _genreProvider.get();

      setState(() {
        _authors = authorsResult.result;
        _genres = genresResult.result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri učitavanju autora ili žanrova: $e")),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAuthorId == null || _selectedGenreIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Molimo izaberite autora i barem jedan žanr.")),
      );
      return;
    }

    final dto = {
      "AuthorId": _selectedAuthorId,
      "Title": _titleController.text.trim(),
      "Description": _descriptionController.text.trim(),
      "PageNumber": int.tryParse(_pageNumberController.text.trim()) ?? 0,
      "AvailableNumber": int.tryParse(_availableNumberController.text.trim()) ?? 0,
      "GenreIds": _selectedGenreIds,
    };

    setState(() => _isSubmitting = true);

    try {
      if (widget.book == null) {
        await _bookProvider.insert(dto);
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Knjiga uspješno dodana.")),
          );
        }
      } else {
        await _bookProvider.update(widget.book!.id!, dto);
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Knjiga uspješno ažurirana.")),
          );
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri spremanju knjige: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.book == null ? "Dodaj novu knjigu" : "Uredi knjigu"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 600,
          maxWidth: 500,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Naslov'),
                  validator: (value) => value == null || value.isEmpty ? "Unesite naslov" : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Opis'),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
                TextFormField(
                  controller: _pageNumberController,
                  decoration: const InputDecoration(labelText: 'Broj stranica'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      (value == null || int.tryParse(value) == null)
                          ? "Unesite validan broj"
                          : null,
                ),
                TextFormField(
                  controller: _availableNumberController,
                  decoration: const InputDecoration(labelText: 'Dostupno primjeraka'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      (value == null || int.tryParse(value) == null)
                          ? "Unesite validan broj"
                          : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _selectedAuthorId,
                  items: _authors.map((author) {
                    final name = "${author.firstName} ${author.lastName}";
                    return DropdownMenuItem<int>(
                      value: author.id,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedAuthorId = value),
                  decoration: const InputDecoration(labelText: 'Autor'),
                  validator: (value) => value == null ? "Izaberite autora" : null,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Žanrovi", style: Theme.of(context).textTheme.titleMedium),
                ),
                Wrap(
                  spacing: 8.0,
                  children: _genres.map((genre) {
                    final isSelected = _selectedGenreIds.contains(genre.id);
                    return FilterChip(
                      label: Text(genre.name ?? "Nepoznat"),
                      selected: isSelected,
                      showCheckmark: false, // Only changes color on select
                      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedGenreIds.add(genre.id!);
                          } else {
                            _selectedGenreIds.remove(genre.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text("Otkaži"),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.book == null ? "Dodaj" : "Spremi"),
        ),
      ],
    );
  }
}
