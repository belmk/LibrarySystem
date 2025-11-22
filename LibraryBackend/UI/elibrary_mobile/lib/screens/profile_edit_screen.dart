import 'package:elibrary_mobile/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elibrary_mobile/models/user.dart';
import 'package:elibrary_mobile/providers/auth_provider.dart';
import 'package:elibrary_mobile/providers/user_provider.dart';

class UserProfileEditScreen extends StatefulWidget {
  const UserProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileEditScreen> createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late AuthProvider _authProvider;
  late UserProvider _userProvider;

  late User _user;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _userProvider = context.read<UserProvider>();

    _user = _authProvider.currentUser!;

    _firstNameController.text = _user.firstName ?? "";
    _lastNameController.text = _user.lastName ?? "";
    _usernameController.text = _user.username ?? "";
  }

  bool _hasChanges() {
    return _firstNameController.text.trim() != (_user.firstName ?? "") ||
        _lastNameController.text.trim() != (_user.lastName ?? "") ||
        _usernameController.text.trim() != (_user.username ?? "");
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Potvrda"),
            content: const Text(
                "Da li ste sigurni da želite sačuvati promjene? Odjaviti ćete se nakon izmjena."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Ne"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Da"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  if (!_hasChanges()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nema promjena za spremiti.")),
    );
    return;
  }

  final confirm = await _showConfirmationDialog();
  if (!confirm) return;

  setState(() => _isSaving = true);

  final dto = {
    "firstName": _firstNameController.text.trim(),
    "lastName": _lastNameController.text.trim(),
    "username": _usernameController.text.trim(),
    "email": _user.email,
    "warningNumber": _user.warningNumber ?? 0,
    "isActive": _user.isActive ?? true
  };

  try {
    final updatedUser = await _userProvider.update(_user.id!, dto);
    _authProvider.setCurrentUser(updatedUser);

    _authProvider.logout();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Podaci uspješno ažurirani.")),
    );
  } catch (e) {
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: $e")),
    );
  }
}


  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Osnovne informacije"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: "Ime",
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Unesite ime" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: "Prezime",
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Unesite prezime" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Korisničko ime",
                  prefixIcon: Icon(Icons.account_circle_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Unesite korisničko ime" : null,
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Dodatne informacije",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 10),

              _infoTile(Icons.email_outlined, "Email", _user.email ?? "N/A"),
              const SizedBox(height: 12),

              _infoTile(Icons.calendar_month_outlined, "Registracija",
                  _user.registrationDate?.toIso8601String().substring(0, 10) ??
                      "N/A"),
              const SizedBox(height: 12),

              _infoTile(Icons.warning_amber_outlined, "Upozorenja",
                  (_user.warningNumber ?? 0).toString()),
              const SizedBox(height: 12),

              _infoTile(Icons.verified_user_outlined, "Status",
                  _user.isActive == true ? "Aktivan" : "Neaktivan"),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text("Spremi promjene"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
