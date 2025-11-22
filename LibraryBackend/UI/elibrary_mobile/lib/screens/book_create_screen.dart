import 'dart:convert';
import 'dart:io';

import 'package:elibrary_mobile/models/book.dart';
import 'package:elibrary_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:elibrary_mobile/models/author.dart';
import 'package:elibrary_mobile/models/genre.dart';
import 'package:elibrary_mobile/providers/book_provider.dart';
import 'package:elibrary_mobile/providers/author_provider.dart';
import 'package:elibrary_mobile/providers/genre_provider.dart';

class BookCreateScreen extends StatefulWidget {
  final Book? bookToEdit;

  const BookCreateScreen({Key? key, this.bookToEdit}) : super(key: key);

  @override
  State<BookCreateScreen> createState() => _BookCreateScreenState();
}

class _BookCreateScreenState extends State<BookCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pageNumberController = TextEditingController();

  int? _selectedAuthorId;
  List<int> _selectedGenreIds = [];

  List<Author> _authors = [];
  List<Genre> _genres = [];

  bool _isLoading = true;
  bool _isSubmitting = false;

  File? _selectedImage;
  String? _imageBase64;
  String? _imageFormat;

  late BookProvider _bookProvider;
  late AuthorProvider _authorProvider;
  late GenreProvider _genreProvider;
  late AuthProvider _authProvider;

  bool get isEditing => widget.bookToEdit != null;

  @override
  void initState() {
    super.initState();
    _bookProvider = context.read<BookProvider>();
    _authorProvider = context.read<AuthorProvider>();
    _genreProvider = context.read<GenreProvider>();
    _authProvider = context.read<AuthProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final authorsResult = await _authorProvider.get();
    final genresResult = await _genreProvider.get();

    _authors = authorsResult.result;
    _genres = genresResult.result;

    if (isEditing) {
      final b = widget.bookToEdit!;
      _titleController.text = b.title ?? "";
      _descriptionController.text = b.description ?? "";
      _pageNumberController.text = b.pageNumber?.toString() ?? "";
      _selectedAuthorId = b.author?.id;
      _selectedGenreIds = b.genres?.map((g) => g.id!).toList() ?? [];

      if (b.coverImageBase64 != null && b.coverImageBase64!.isNotEmpty) {
        _imageBase64 = b.coverImageBase64;
        _imageFormat = "image/jpeg";
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final file = File(picked.path);
      final bytes = await file.readAsBytes();

      setState(() {
        _selectedImage = file;
        _imageBase64 = base64Encode(bytes);
        final ext = file.path.split('.').last.toLowerCase();
        _imageFormat = ext == "png" ? "image/png" : "image/jpeg";
      });
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
      "AvailableNumber": 1,
      "GenreIds": _selectedGenreIds,
      "CoverImageBase64": _imageBase64,
      "CoverImageContentType": _imageFormat,
      "IsUserBook": true,
      "UserId": _authProvider.currentUser?.id
    };

    setState(() => _isSubmitting = true);

    try {
      if (isEditing) {
        await _bookProvider.update(widget.bookToEdit!.id!, dto);
      } else {
        await _bookProvider.insert(dto);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? "Knjiga ažurirana." : "Knjiga uspješno dodana.")),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    }
  }

  Widget _buildGenreChips() {
    return Wrap(
      spacing: 8,
      children: _genres.map((genre) {
        final selected = _selectedGenreIds.contains(genre.id);

        return FilterChip(
          label: Text(genre.name ?? ""),
          selected: selected,
          showCheckmark: false,
          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.25),
          onSelected: (value) {
            setState(() {
              if (value) {
                _selectedGenreIds.add(genre.id!);
              } else {
                _selectedGenreIds.remove(genre.id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Uredi knjigu" : "Dodaj novu knjigu"),
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Naslov",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Unesite naslov" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Opis",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pageNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Broj stranica",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          (value == null || int.tryParse(value) == null)
                              ? "Unesite validan broj"
                              : null,
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Naslovna slika",
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade400),
                          color: Colors.grey.shade100,
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(_selectedImage!, fit: BoxFit.cover),
                              )
                            : (_imageBase64 != null)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      base64Decode(_imageBase64!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo, size: 40),
                                        SizedBox(height: 8),
                                        Text("Dodajte sliku"),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<int>(
                      value: _selectedAuthorId,
                      decoration: const InputDecoration(
                        labelText: "Autor",
                        border: OutlineInputBorder(),
                      ),
                      items: _authors
                          .map((author) => DropdownMenuItem<int>(
                                value: author.id,
                                child: Text("${author.firstName} ${author.lastName}"),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedAuthorId = v),
                      validator: (v) => v == null ? "Izaberite autora" : null,
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Žanrovi",
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 8),
                    _buildGenreChips(),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(isEditing ? "Sačuvaj promjene" : "Dodaj knjigu"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
