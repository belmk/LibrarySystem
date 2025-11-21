import 'package:elibrary_mobile/models/user.dart';
import 'package:elibrary_mobile/providers/user_review_provider.dart';
import 'package:elibrary_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserReviewScreen extends StatefulWidget {
  final User reviewedUser;

  const UserReviewScreen({Key? key, required this.reviewedUser}) : super(key: key);

  @override
  State<UserReviewScreen> createState() => _UserReviewScreenState();
}

class _UserReviewScreenState extends State<UserReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedRating;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  late UserReviewProvider _userReviewProvider;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _userReviewProvider = context.read<UserReviewProvider>();
    _authProvider = context.read<AuthProvider>();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    final reviewer = _authProvider.currentUser;
    if (reviewer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Morate biti prijavljeni da ostavite recenziju.")),
      );
      return;
    }

    if (reviewer.id == widget.reviewedUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ne možete recenzirati samog sebe.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final review = {
        "reviewerUserId": reviewer.id,
        "reviewedUserId": widget.reviewedUser.id,
        "rating": _selectedRating,
        "comment": _commentController.text.trim(),
      };

      await _userReviewProvider.insert(review);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recenzija uspješno poslana!")),
      );

      Navigator.of(context).pop();
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
                  "Recenzija za korisnika \"${widget.reviewedUser.username}\"",
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
                  hintText: "Ostavite komentar o korisniku...",
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