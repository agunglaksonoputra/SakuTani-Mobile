import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/finance.dart';
import '../services/finance_services.dart';
import '../services/logger_service.dart';

class FinanceProvider with ChangeNotifier {
  List<FinanceData> _financeCards = [];
  List<ProfitShareData> _profitShares = [];
  List<WeeklySummary> _weeklyBreakdown = [];
  Map<String, List<Map<String, dynamic>>> _monthlyData = {};
  bool _isLoading = false;

  List<FinanceData> get financeCards => _financeCards;
  List<ProfitShareData> get profitShares => _profitShares;
  List<WeeklySummary> get weeklyBreakdown => _weeklyBreakdown;
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
          title: 'Total Balance',
          amount: (data['total_user_balance'] ?? 0).toDouble(),
          color: const Color(0xFF10B981),
        ),
        FinanceData(
          title: 'Monthly Profit',
          amount: (data['total_profit'] ?? 0).toDouble(),
          color: const Color(0xFF10B981),
        ),
        FinanceData(
          title: 'Income',
          amount: (data['total_sales'] ?? 0).toDouble(),
          color: const Color(0xFF8B5CF6),
        ),
        FinanceData(
          title: 'Expenses',
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
  Future<void> fetchWeeklyBreakdown() async {
    try {
      LoggerService.info("[FINANCE] Fetching weekly breakdown...");
      _weeklyBreakdown = await FinanceService.getWeeklyBreakdown();
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
  List<CashflowData> get cashflowData => _weeklyBreakdown.map((week) {
    return CashflowData(
      income: week.totalSales,
      expense: week.totalExpenses,
      label: DateFormat('d MMM').format(DateTime.parse(week.weekEnd)),
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
        fetchWeeklyBreakdown(),
      ]);
      LoggerService.info("[FINANCE] All data refreshed.");
    } catch (e) {
      LoggerService.error("[FINANCE] Error while refreshing all data.", error: e);
    }

    _isLoading = false;
    notifyListeners();
  }
}
