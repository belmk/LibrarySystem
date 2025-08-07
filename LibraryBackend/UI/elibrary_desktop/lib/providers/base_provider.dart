import 'dart:convert';
import 'dart:async';
import 'package:elibrary_desktop/utils/util.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  @protected
  String endpoint = "";
  static late String baseUrl;
  static late http.Client _httpClient;

  static void initializeHttpClient(http.Client client) {
    _httpClient = client;
  }

  http.Client get client => _httpClient;

  BaseProvider(String endpoint) {
    this.endpoint = endpoint;
  }

  Future<T?> getById(int id, [dynamic additionalData]) async {
    var url = Uri.parse("$baseUrl$endpoint/$id");

    Map<String, String> headers = createHeaders();

    var response = await http.get(url, headers: headers);

    if (isValidResponseCode(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      return null;
    }
  }

  Future<List<T>> get([dynamic search]) async {
    var url = "$baseUrl$endpoint";

    if (search != null) {
      String queryString = getQueryString(search);
      url = url + "?" + queryString;
    }

    var uri = Uri.parse(url);

    Map<String, String> headers = createHeaders();
    var response = await http.get(uri, headers: headers);
    print("done $response");
    if (isValidResponseCode(response)) {
      var data = jsonDecode(response.body);
      return data['result'].map((x) => fromJson(x)).cast<T>().toList();
    } else {
      throw Exception("Exception... handle this gracefully");
    }
  }

  Future<T?> insert(dynamic request) async {
    var url = "$baseUrl$endpoint";
    var uri = Uri.parse(url);

    Map<String, String> headers = createHeaders();
    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponseCode(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      return null;
    }
  }

  Future<T?> update(int id, [dynamic request]) async {
    var url = "$baseUrl$endpoint/$id";
    var uri = Uri.parse(url);

    Map<String, String> headers = createHeaders();

    var response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(request),
    );

    if (isValidResponseCode(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      return null;
    }
  }

  Future<Response> post(String path, dynamic request) async {
    final url = '$baseUrl$endpoint/$path';
    final uri = Uri.parse(url);

    final headers = createHeaders();
    final body = jsonEncode(request);

    return await http.post(uri, headers: headers, body: body);
  }

  static Map<String, String> createHeaders() {
    String? username = Authorization.username;
    String? password = Authorization.password;

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };
    return headers;
  }

  T fromJson(data) {
    throw Exception("Override method");
  }

  String getQueryString(
    Map params, {
    String prefix = '&',
    bool inRecursion = false,
  }) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${(value).toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query += getQueryString(
            {k: v},
            prefix: '$prefix$key',
            inRecursion: true,
          );
        });
      }
    });
    return query;
  }

  bool isValidResponseCode(Response response) {
    if (response.statusCode == 200) {
      if (response.body != "") {
        return true;
      } else {
        return false;
      }
    } else if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      String errorMessage = "Došlo je do greške.";
      if (response.body.isNotEmpty) {
        try {
          var errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else {
            errorMessage = response.body;
          }
        } catch (e) {
          errorMessage = response.body;
        }
      } else {
        errorMessage =
            response.reasonPhrase ?? "Greška: ${response.statusCode}";
      }
      throw Exception(errorMessage);
    } else if (response.statusCode == 500) {
      throw Exception("Greška na serveru. Molimo pokušajte kasnije.");
    } else {
      throw Exception("Dogodila se nepoznata greška.");
    }
  }
}