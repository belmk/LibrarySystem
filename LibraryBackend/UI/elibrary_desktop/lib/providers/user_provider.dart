import 'dart:convert';
import 'package:elibrary_desktop/models/user.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
  User fromJson(data) => User.fromJson(data);

  Future<User> warnUser(int? id) async {
    final url = "${BaseProvider.baseUrl}$endpoint/warn/$id";
    final uri = Uri.parse(url);
    final headers = createHeaders();

    final response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to warn user (status ${response.statusCode})");
    }
  }

  Future<User> deactivateUser(int id) async {
  final url = "${BaseProvider.baseUrl}$endpoint/$id";
  final uri = Uri.parse(url);
  final headers = createHeaders();

  final response = await http.get(uri, headers: headers);

  if (!isValidResponse(response)) {
    throw Exception("Failed to fetch user with id $id");
  }

  final userJson = jsonDecode(response.body);
  final user = fromJson(userJson);

  user.isActive = false;

  return await update(id, user.toJson());
}
}
