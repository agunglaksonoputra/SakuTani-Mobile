import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/finance.dart';

final String baseUrl = dotenv.env['BASE_URL_EMULATOR'] ?? dotenv.env['BASE_URL_DEVICE'] ?? '';

class FinanceService {

  static Future<Map<String, dynamic>> getCurrentMonthSummary() async {
    final res = await http.get(Uri.parse('$baseUrl/summary/current-month'));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to fetch finance summary');
    }
  }

  static Future<List<dynamic>> getProfitShares() async {
    final res = await http.get(Uri.parse('$baseUrl/profit-shares'));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to fetch profit shares');
    }
  }

  static Future<List<dynamic>> getUserBalances() async {
    final res = await http.get(Uri.parse('$baseUrl/user-balance'));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to fetch user balances');
    }
  }

  // static Future<List<dynamic>> getCashflow() async {
  //   final res = await http.get(Uri.parse('$baseUrl/cashflow'));
  //   if (res.statusCode == 200) {
  //     return json.decode(res.body);
  //   } else {
  //     throw Exception('Failed to fetch cashflow data');
  //   }
  // }

  static Future<List<WeeklySummary>> getWeeklyBreakdown() async {
    final res = await http.get(Uri.parse('$baseUrl/weekly-chart'));
    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      final data = jsonData['data'];

      return (data as List)
          .map((item) => WeeklySummary.fromJson(item))
          .toList();
    } else {
      throw Exception("Failed to load weekly breakdown");
    }
  }

  static Future<void> generateProfit(String month) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profit-share/generate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'month': month,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed with status ${response.statusCode}: ${response.body}");
      }

    } catch (e) {
      throw Exception("Failed to generate profit: $e");
    }
  }


}
