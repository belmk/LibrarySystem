import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elibrary_mobile/models/user.dart';
import 'package:elibrary_mobile/providers/complaint_provider.dart';
import 'package:elibrary_mobile/providers/auth_provider.dart';

class CreateComplaintScreen extends StatefulWidget {
  final User targetUser;

  const CreateComplaintScreen({Key? key, required this.targetUser}) : super(key: key);

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  late ComplaintProvider _complaintProvider;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _complaintProvider = context.read<ComplaintProvider>();
    _authProvider = context.read<AuthProvider>();
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    final sender = _authProvider.currentUser;
    if (sender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Morate biti prijavljeni da pošaljete žalbu.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final complaintData = {
        "senderId": sender.id,
        "targetId": widget.targetUser.id,
        "reason": _reasonController.text.trim(),
      };

      await _complaintProvider.insert(complaintData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Žalba uspješno poslana!")),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri slanju žalbe: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Žalba protiv: ${widget.targetUser.username ?? 'Nepoznato korisničko ime'}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: "Razlog žalbe",
                  hintText: "Opišite razlog žalbe...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Molimo unesite razlog žalbe" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitComplaint,
                icon: const Icon(Icons.send),
                label: Text(_isSubmitting ? "Slanje..." : "Pošalji žalbu"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
