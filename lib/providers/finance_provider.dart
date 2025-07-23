import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saku_tani_mobile/services/monthly_report_services.dart';
import '../models/finance.dart';
import '../services/finance_services.dart';
import '../services/logger_service.dart';

class FinanceProvider with ChangeNotifier {
  List<FinanceData> _financeCards = [];
  List<ProfitShareData> _profitShares = [];
  List<MonthlySummary> _monthlyBreakdown = [];
  Map<String, List<Map<String, dynamic>>> _monthlyData = {};
  bool _isLoading = false;

  List<FinanceData> get financeCards => _financeCards;
  List<ProfitShareData> get profitShares => _profitShares;
  List<MonthlySummary> get monthlyBreekdown => _monthlyBreakdown;
  Map<String, List<Map<String, dynamic>>> get monthlyData => _monthlyData;
  bool get isLoading => _isLoading;

  FinanceProvider() {
    refreshAll(); // Automatically load all finance data on init
  }

  /// Format ISO date string to readable format
  String formatDateString(String? isoDateString, {String locale = 'en_US'}) {
    if (isoDateString == null) return '';
    final parsedDate = DateTime.tryParse(isoDateString);
    if (parsedDate == null) return '';
    return DateFormat('d MMMM yyyy', locale).format(parsedDate);
  }

  /// Fetch financial summary for the current month
  Future<void> fetchFinanceSummary() async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.info("[FINANCE] Fetching current month summary...");
      final response = await FinanceService.getCurrentMonthSummary();
      final data = response['data'];

      _financeCards = [
        FinanceData(
          title: 'Laba',
          amount: (data['total_profit'] ?? 0).toDouble(),
          color: const Color(0xFF10B981),
        ),
        FinanceData(
          title: 'Pendapatan',
          amount: (data['total_sales'] ?? 0).toDouble(),
          color: const Color(0xFF8B5CF6),
        ),
        FinanceData(
          title: 'Pengeluaran',
          amount: (data['total_expenses'] ?? 0).toDouble(),
          color: const Color(0xFFF43F5E),
        ),
      ];

      LoggerService.info("[FINANCE] Summary fetched successfully.");
    } catch (e) {
      LoggerService.error("[FINANCE] Failed to fetch summary.", error: e);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch balance share for each user
  Future<void> fetchProfitShares() async {
    try {
      LoggerService.info("[FINANCE] Fetching profit shares...");
      final data = await FinanceService.getUserBalances();

      _profitShares = data.map((item) {
        return ProfitShareData(
          name: item['name'],
          amount: double.tryParse(item['balance'].toString()) ?? 0,
        );
      }).toList();

      LoggerService.info("[FINANCE] Profit shares fetched.");
      notifyListeners();
    } catch (e) {
      LoggerService.error("[FINANCE] Failed to fetch profit shares.", error: e);
    }
  }

  /// Fetch weekly income & expenses breakdown
  Future<void> fetchMonthlyBreakdown() async {
    try {
      LoggerService.info("[FINANCE] Fetching weekly breakdown...");
      _monthlyBreakdown = await FinanceService.getMonthlyBreakdown();
      LoggerService.info("[FINANCE] Weekly breakdown fetched.");
      notifyListeners();
    } catch (e) {
      LoggerService.error("[FINANCE] Failed to fetch weekly breakdown.", error: e);
    }
  }

  /// Trigger monthly profit generation
  Future<void> generateCurrentMonthProfit() async {
    final now = DateTime.now();
    final formattedMonth = DateFormat('yyyy-MM').format(now);
    try {
      LoggerService.info("[FINANCE] Generating profit for $formattedMonth...");
      await FinanceService.generateProfit(formattedMonth);
      LoggerService.info("[FINANCE] Profit generated successfully.");
    } catch (e) {
      LoggerService.error("[FINANCE] Failed to generate profit.", error: e);
    }
  }

  /// Combine income & expense per week for charts
  List<CashflowData> get cashflowData => _monthlyBreakdown.map((monthly) {
    return CashflowData(
      income: monthly.totalSales,
      expense: monthly.totalExpenses,
      label: DateFormat('MMM').format(monthly.date),
    );
  }).toList();

  /// Refresh all finance data (summary, shares, breakdown)
  Future<void> refreshAll() async {
    _isLoading = true;
    notifyListeners();

    LoggerService.info("[FINANCE] Refreshing all finance data...");
    try {
      await generateCurrentMonthProfit();
      await Future.wait([
        fetchFinanceSummary(),
        fetchProfitShares(),
        fetchMonthlyBreakdown(),
      ]);
      LoggerService.info("[FINANCE] All data refreshed.");
    } catch (e) {
      LoggerService.error("[FINANCE] Error while refreshing all data.", error: e);
    }

    _isLoading = false;
    notifyListeners();
  }
}
