import '../models/finance.dart';
import 'dio_client.dart';
import 'logger_service.dart';

class FinanceService {
  /// Get monthly summary (income, expense, balance)
  static Future<Map<String, dynamic>> getCurrentMonthSummary() async {
    try {
      final res = await DioClient.dio.get('report/current');
      LoggerService.info('[FINANCE] Fetched current month summary');
      return res.data;
    } catch (e) {
      LoggerService.error('[FINANCE] Failed to fetch current month summary', error: e);
      throw Exception('Failed to fetch finance summary: $e');
    }
  }

  /// Get list of profit shares
  static Future<List<dynamic>> getProfitShares() async {
    try {
      final res = await DioClient.dio.get('/profit-shares');
      LoggerService.info('[FINANCE] Fetched profit shares');
      return res.data;
    } catch (e) {
      LoggerService.error('[FINANCE] Failed to fetch profit shares', error: e);
      throw Exception('Failed to fetch profit shares: $e');
    }
  }

  /// Get user balances
  static Future<List<dynamic>> getUserBalances() async {
    try {
      final res = await DioClient.dio.get('/user-balance');
      LoggerService.info('[FINANCE] Fetched user balances');
      return res.data;
    } catch (e) {
      LoggerService.error('[FINANCE] Failed to fetch user balances', error: e);
      throw Exception('Failed to fetch user balances: $e');
    }
  }

  /// Get weekly breakdown (e.g., weekly income)
  static Future<List<WeeklySummary>> getWeeklyBreakdown() async {
    try {
      final res = await DioClient.dio.get('/transactions/weekly-summary');
      final data = res.data['data'] as List;
      LoggerService.info('[FINANCE] Fetched weekly breakdown');
      return data.map((item) => WeeklySummary.fromJson(item)).toList();
    } catch (e) {
      LoggerService.error('[FINANCE] Failed to fetch weekly breakdown', error: e);
      throw Exception("Failed to load weekly breakdown: $e");
    }
  }

  /// Trigger profit share calculation
  static Future<void> generateProfit(String month) async {
    try {
      final res = await DioClient.dio.post(
        '/profit-share/generate',
        data: {'month': month}, // Dio otomatis jsonEncode
      );

      if (res.statusCode == 200) {
        LoggerService.info('[FINANCE] Profit generation triggered for $month');
      } else {
        LoggerService.warning(
          '[FINANCE] Unexpected response during profit generation: ${res.statusCode}',
        );
        throw Exception('Failed with status ${res.statusCode}: ${res.data}');
      }
    } catch (e) {
      LoggerService.error('[FINANCE] Failed to generate profit for $month', error: e);
      throw Exception("Failed to generate profit: $e");
    }
  }
}