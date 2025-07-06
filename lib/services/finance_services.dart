import '../models/finance.dart';
import 'dio_client.dart';

class FinanceService {
  /// Ringkasan bulan ini (income, expense, balance)
  static Future<Map<String, dynamic>> getCurrentMonthSummary() async {
    try {
      final res = await DioClient.dio.get('report/current');
      return res.data;
    } catch (e) {
      throw Exception('Failed to fetch finance summary: $e');
    }
  }

  /// List pembagian keuntungan
  static Future<List<dynamic>> getProfitShares() async {
    try {
      final res = await DioClient.dio.get('/profit-shares');
      return res.data;
    } catch (e) {
      throw Exception('Failed to fetch profit shares: $e');
    }
  }

  /// Saldo user per user
  static Future<List<dynamic>> getUserBalances() async {
    try {
      final res = await DioClient.dio.get('/user-balance');
      return res.data;
    } catch (e) {
      throw Exception('Failed to fetch user balances: $e');
    }
  }

  /// Breakdown mingguan (misal income per minggu)
  static Future<List<WeeklySummary>> getWeeklyBreakdown() async {
    try {
      final res = await DioClient.dio.get('/transactions/weekly-summary');
      final data = res.data['data'] as List;
      return data.map((item) => WeeklySummary.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to load weekly breakdown: $e");
    }
  }

  /// Trigger perhitungan dan pembagian profit
  static Future<void> generateProfit(String month) async {
    try {
      final res = await DioClient.dio.post(
        '/profit-share/generate',
        data: {'month': month}, // Dio otomatis jsonEncode
      );

      if (res.statusCode != 200) {
        throw Exception("Failed with status ${res.statusCode}: ${res.data}");
      }
    } catch (e) {
      throw Exception("Failed to generate profit: $e");
    }
  }
}