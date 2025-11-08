import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../utils/util.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String username, String password) async {
    final uri = Uri.parse("${dotenv.env['API_URL']}Auth/login");

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        Authorization.username = username;
        Authorization.password = password;

        final userProvider = UserProvider();
        final user = await userProvider.getMe();

        _currentUser = user;
        notifyListeners();

        return true;
      } else if (response.statusCode == 401) {
        throw Exception("Pogrešno korisničko ime ili lozinka.");
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? "Login failed.");
      }
    } catch (e) {
      throw Exception("Greška pri loginu: ${e.toString()}");
    }
  }

  User? getUser() => _currentUser;

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    Authorization.username = null;
    Authorization.password = null;
    notifyListeners();
  }
}
