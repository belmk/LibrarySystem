import 'dart:convert';
import 'package:elibrary_mobile/providers/subscription_provider.dart';
import 'package:elibrary_mobile/utils/util.dart';
import 'package:elibrary_mobile/models/user.dart';
import 'package:elibrary_mobile/providers/base_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
  User fromJson(data) => User.fromJson(data);

   final SubscriptionProvider _subscriptionProvider = SubscriptionProvider();

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

Future<bool> revokeSubscription(int userId) async {
  final subscriptions = await _subscriptionProvider.get(filter: {
    "UserId": userId,
    "IsCancelled": false,
  });

  if (subscriptions.result.isEmpty) {
    return false; 
  }

  final activeSub = subscriptions.result.first;

  await _subscriptionProvider.update(activeSub.id!, {
    "IsCancelled": true,
  });

  return true;
}

Future<User> getMe() async {
  final uri = Uri.parse("${dotenv.env['API_URL']}User/me");
  final headers = await createAuthHeaders();

  final response = await http.get(uri, headers: headers);

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Greška prilikom dohvata trenutnog korisnika: ${response.body}");
  }
}


  Future<Map<String, String>> createAuthHeaders() async {
  final headers = {
    'Content-Type': 'application/json',
  };

  if (Authorization.username != null && Authorization.password != null) {
    final credentials = base64Encode(utf8.encode('${Authorization.username}:${Authorization.password}'));
    headers['Authorization'] = 'Basic $credentials';
  }

  return headers;
}
}
