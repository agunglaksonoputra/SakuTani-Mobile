import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/finance.dart';
import '../services/finance_services.dart';

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
    refreshAll();// agar lebih deskriptif
  }

  String formatDateString(String? isoDateString, {String locale = 'en_US'}) {
    if (isoDateString == null) return '';
    final parsedDate = DateTime.tryParse(isoDateString);
    if (parsedDate == null) return '';
    return DateFormat('d MMMM yyyy', locale).format(parsedDate);
  }

  /// Ambil data ringkasan keuangan bulan ini (profit, sales, expenses)
  Future<void> fetchFinanceSummary() async {
    _isLoading = true;
    try {
      final data = await FinanceService.getCurrentMonthSummary();

      _financeCards = [
        FinanceData(
          title: 'Total Saldo',
          amount: data['total_balance']?.toDouble() ?? 0,
          color: const Color(0xFF10B981),
        ),
        FinanceData(
          title: 'Profit Bulan Ini',
          amount: data['profit']?.toDouble() ?? 0,
          color: const Color(0xFF10B981),
        ),
        FinanceData(
          title: 'Pendapatan',
          amount: data['total_sales']?.toDouble() ?? 0,
          color: const Color(0xFF8B5CF6),
        ),
        FinanceData(
          title: 'Pengeluaran',
          amount: data['total_expenses']?.toDouble() ?? 0,
          color: const Color(0xFFF43F5E),
        ),
      ];
      print("Summary dipanggil");
      notifyListeners();
    } catch (e) {
      print("fetchFinanceSummary error: $e");
    }
    _isLoading = false;
  }

  /// Ambil saldo profit share untuk masing-masing user
  Future<void> fetchProfitShares() async {
    print("Profit dipanggil");
    try {
      final data = await FinanceService.getUserBalances();

      _profitShares = data.map((item) {
        return ProfitShareData(
          name: item['user_name'],
          amount: double.tryParse(item['balance'].toString()) ?? 0,
          date: formatDateString("2025-06-28", locale: 'id_ID')
        );
      }).toList().cast<ProfitShareData>();

      notifyListeners();
      print("Profit dipanggil");
    } catch (e) {
      print("fetchProfitShares error: $e");
    }
  }

  List<CashflowData> get cashflowData => _weeklyBreakdown
      .map((week) => CashflowData(
    income: week.totalSales,
    expense: week.totalExpenses,
    label: DateFormat('d MMM').format(DateTime.parse(week.weekEnd)),
  ))
      .toList();

  Future<void> fetchWeeklyBreakdown() async {
    try {
      _weeklyBreakdown = await FinanceService.getWeeklyBreakdown();
      notifyListeners();
    } catch (e) {
      print("fetchWeeklyBreakdown error: $e");
    }
  }

  Future<void> generateCurrentMonthProfit() async {
    try {
      final now = DateTime.now();
      final formattedMonth = DateFormat('yyyy-MM').format(now);

      await FinanceService.generateProfit(formattedMonth);
      print("Profit berhasil digenerate untuk bulan: $formattedMonth");
    } catch (e) {
      print("generateCurrentMonthProfit error: $e");
    }
  }


  /// Untuk me-refresh semua data (jika diperlukan)
  Future<void> refreshAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      await generateCurrentMonthProfit();
      await Future.wait([
        fetchFinanceSummary(),
        fetchProfitShares(),
        fetchWeeklyBreakdown(),
      ]);
    } catch (e) {
      print("refreshAll error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}