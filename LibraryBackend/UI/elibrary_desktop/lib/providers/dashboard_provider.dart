import 'dart:convert';
import 'package:elibrary_desktop/models/dashboard_models/book_loan_stats_dto.dart';
import 'package:elibrary_desktop/models/dashboard_models/user_loan_stats_dto.dart';
import 'package:elibrary_desktop/models/dashboard_models/rating_stats_dto.dart';
import 'package:elibrary_desktop/models/dashboard_models/monthly_revenue_dto.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';
import 'package:elibrary_desktop/utils/util.dart';
import 'package:http/http.dart' as http;

class DashboardProvider {
  static const String _base = 'api/Dashboard';

  Map<String, String> createHeaders() {
    final username = Authorization.username ?? '';
    final password = Authorization.password ?? '';
    final basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    return {
      'Content-Type': 'application/json',
      'Authorization': basicAuth,
    };
  }

  Future<List<BookLoanStatsDto>> getTopBorrowedBooks(int count) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}$_base/top-borrowed-books?count=$count');
    print('Calling: ${uri.toString()}');
    final res = await http.get(uri, headers: createHeaders());

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => BookLoanStatsDto.fromJson(e)).toList();
    }

    throw Exception('Failed to fetch top borrowed books');
  }

  Future<List<UserLoanStatsDto>> getTopActiveUsers(int count) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}$_base/top-active-users?count=$count');
    final res = await http.get(uri, headers: createHeaders());

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => UserLoanStatsDto.fromJson(e)).toList();
    }

    throw Exception('Failed to fetch top active users');
  }

  Future<List<RatingStatsDto>> getTopRatedBooks(int count) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}$_base/top-rated-books?count=$count');
    final res = await http.get(uri, headers: createHeaders());

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => RatingStatsDto.fromJson(e)).toList();
    }

    throw Exception('Failed to fetch top rated books');
  }

  Future<List<RatingStatsDto>> getTopRatedUsers(int count) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}$_base/top-rated-users?count=$count');
    final res = await http.get(uri, headers: createHeaders());

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => RatingStatsDto.fromJson(e)).toList();
    }

    throw Exception('Failed to fetch top rated users');
  }

  Future<List<MonthlyRevenueDto>> getBorrowStats(int months) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}$_base/borrow-stats?months=$months');
    final res = await http.get(uri, headers: createHeaders());

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => MonthlyRevenueDto.fromJson(e)).toList();
    }

    throw Exception('Failed to fetch borrow stats');
  }

  Future<List<MonthlyRevenueDto>> getProfitStats(int months) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}$_base/profit-stats?months=$months');
    final res = await http.get(uri, headers: createHeaders());

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => MonthlyRevenueDto.fromJson(e)).toList();
    }

    throw Exception('Failed to fetch profit stats');
  }
}
