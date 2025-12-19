import 'package:elibrary_desktop/models/user.dart';
import 'package:flutter/material.dart';

class UserFormDialog extends StatefulWidget {
  final User user;
  final Future<void> Function(User updatedUser) onSave;


  const UserFormDialog({
    Key? key,
    required this.user,
    required this.onSave,
  }) : super(key: key);

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user.lastName ?? '');
    _usernameController = TextEditingController(text: widget.user.username ?? '');
    _emailController = TextEditingController(text: widget.user.email ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
  if (_formKey.currentState?.validate() ?? false) {
    final updatedUser = User(
      id: widget.user.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      warningNumber: widget.user.warningNumber,
      isActive: widget.user.isActive,
    );

    await widget.onSave(updatedUser);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Uredi korisnika"),
      content: SizedBox(
        width: 400, 
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField("Ime", _firstNameController),
                _buildTextField("Prezime", _lastNameController),
                _buildTextField("Korisničko ime", _usernameController),
                _buildTextField("Email", _emailController),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Otkaži"),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text("Spasi"),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Polje ne smije biti prazno.';
          }
          return null;
        },
      ),
    );
  }
}
