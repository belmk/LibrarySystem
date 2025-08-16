import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthProvider with ChangeNotifier {


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
        final data = jsonDecode(response.body);

        notifyListeners();

        return true;
      } else if (response.statusCode == 401) {
        throw Exception("Invalid username or password.");
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? "Login failed.");
      }
    } catch (e) {
      throw Exception("${e.toString()}");
    }
  }
}