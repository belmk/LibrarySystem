import 'package:flutter/material.dart';
import 'package:elibrary_desktop/providers/author_provider.dart';

class AuthorScreen extends StatefulWidget {
  const AuthorScreen({Key? key}) : super(key: key);

  @override
  State<AuthorScreen> createState() => _AuthorScreenState();
}

class _AuthorScreenState extends State<AuthorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final _authorProvider = AuthorProvider();

  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = {
      "FirstName": _firstNameController.text.trim(),
      "LastName": _lastNameController.text.trim(),
    };

    setState(() => _isSubmitting = true);

    try {
      await _authorProvider.insert(request);

      if (mounted) {
        Navigator.of(context).pop(true); // return success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Autor uspješno dodan.")),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri dodavanju autora: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Dodaj autora"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "Ime"),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Unesite ime" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: "Prezime"),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Unesite prezime" : null,
              ),
            ],
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
              : const Text("Dodaj"),
        ),
      ],
    );
  }
}
