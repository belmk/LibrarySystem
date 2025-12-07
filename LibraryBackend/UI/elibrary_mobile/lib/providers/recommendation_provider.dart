import 'dart:convert';
import 'package:elibrary_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:elibrary_mobile/models/book.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecommenderProvider with ChangeNotifier {
  final http.Client _client;

  RecommenderProvider(this._client);

  Future<List<Book>> getRecommendedBooks({int take = 3}) async {
    try {
      final apiUrl = dotenv.env['API_URL'] ?? '';
      if (apiUrl.isEmpty) {
        throw Exception("API_URL not found in .env");
      }

      final uri = Uri.parse("${apiUrl}Recommendation/recommendations?take=$take");

      // Prepare Basic Auth header
      final credentials = "${Authorization.username}:${Authorization.password}";
      final encodedCredentials = base64Encode(utf8.encode(credentials));
      final headers = {
        'Authorization': 'Basic $encodedCredentials',
      };

      final response = await _client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load recommended books. Status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching recommended books: $e");
      throw Exception("Error fetching recommended books: $e");
    }
  }
}
