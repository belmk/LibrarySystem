import 'package:elibrary_desktop/providers/auth_provider.dart';
import 'package:elibrary_desktop/providers/book_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/util.dart';
import 'admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); 

  bool _loading = false;

  void _login() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() => _loading = true);

  final authProvider = context.read<AuthProvider>();

  try {
    final success = await authProvider.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success) {
      // Set credentials globally if needed
      Authorization.username = _usernameController.text;
      Authorization.password = _passwordController.text;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
      );
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Login failed"),
        content: Text(e.toString().replaceAll("Exception: ", "")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  } finally {
    setState(() => _loading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey, 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Korisničko ime",
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Polje za korisničko ime ne smije biti prazno.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Lozinka",
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Polje za lozinku ne smije biti prazno.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text("Login"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
