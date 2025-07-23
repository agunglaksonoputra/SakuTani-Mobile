import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:saku_tani_mobile/models/expenses_transaction.dart';
import 'package:saku_tani_mobile/models/monthly_report_response.dart';
import 'package:saku_tani_mobile/models/monthly_report_summary.dart';
import 'package:saku_tani_mobile/models/sale_transaction.dart';
import 'package:saku_tani_mobile/services/monthly_report_services.dart';

import '../models/transaction_record.dart';
import '../services/logger_service.dart';

class MonthlyReportProvider with ChangeNotifier {
  List<MonthlyReportResponse> _monthlyReports = [];
  List<TransactionRecord> _combinedTransactions = [];
  List<ReportSummaryData> _reportSummaryCards = [];
  int _totalSales = 0;
  int _totalExpenses = 0;
  bool _isLoading = false;

  List<ReportSummaryData> get reportSummaryCards => _reportSummaryCards;
  List<MonthlyReportResponse> get monthlyReports => _monthlyReports;
  List<TransactionRecord> get combinedTransactions => _combinedTransactions;
  int get totalSales => _totalSales;
  int get totalExpenses => _totalExpenses;
  bool get isLoading => _isLoading;

  MonthlyReportProvider();

  Future<void> fetchMenu() async {
    await fetchInitialData();
    await Future.delayed(const Duration(milliseconds: 100));
    notifyListeners();
  }

  Future<void> fetchMonthlyDetail(int id) async {
    await fetchMonthlyById(id);
    await Future.delayed(const Duration(milliseconds: 100));
    notifyListeners();
  }

  Future<void> fetchInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await MonthlyReportServices.fetchMonthly();
      _monthlyReports = response;
      LoggerService.info('[MONTHLY REPORT PROVIDER] Monthly data loaded successfully');
    } catch (e, stackTrace) {
      LoggerService.error('[MONTHLY REPORT PROVIDER] Failed to load data', error: e, stackTrace: stackTrace);
    }

    _isLoading = false;
    notifyListeners();
  }



  Future<void> fetchFinanceSummary() async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.info("[MONTHLY REPORT PROVIDER] Fetching current month summary...");
      final data = await MonthlyReportServices.fetchMonthlySummary();

      _reportSummaryCards = [
        ReportSummaryData(
          title: "Total Pendapatan",
          value: data.formatCurrencyInt(data.totalSales),
          color: const Color(0xFF10B981).withOpacity(0.1),
          textColor: const Color(0xFF10B981),
          icon: FontAwesomeIcons.wallet,
        ),
        ReportSummaryData(
          title: "Rata-rata/Bulan",
          value: data.formatCurrency(data.avgSales),
          color: const Color(0xFF8B5CF6).withOpacity(0.1),
          textColor: const Color(0xFF8B5CF6),
          icon: FontAwesomeIcons.sackDollar,
        ),
        ReportSummaryData(
          title: "Tertinggi",
          value: data.formatCurrencyInt(data.highestIncome?.amount),
          description: data.highestIncome?.formattedDate,
          color: const Color(0xFF3B82F6).withOpacity(0.1),
          textColor: const Color(0xFF3B82F6),
          icon: FontAwesomeIcons.arrowTrendUp,
        ),
        ReportSummaryData(
          title: "Terendah",
          value: data.formatCurrencyInt(data.lowestIncome?.amount),
          description: data.lowestIncome?.formattedDate,
          color: const Color(0xFFEF4444).withOpacity(0.1),
          textColor: const Color(0xFFEF4444),
          icon: FontAwesomeIcons.arrowTrendDown,
        ),

      ];
      LoggerService.info("[MONTHLY REPORT PROVIDER] Summary data updated");
    } catch (e, stackTrace) {
      LoggerService.error('[MONTHLY REPORT PROVIDER] Failed to fetch summary data', error: e, stackTrace: stackTrace);
    }

    _isLoading = false;
    notifyListeners();
  }

  void combineTransactions({
    required List<SaleTransaction> salesList,
    required List<ExpensesTransaction> expensesList,
  }) {
    List<TransactionRecord> combined = [];

    combined.addAll(salesList.map((sale) => TransactionRecord(
      date: sale.date!,
      createdAt: sale.createdAt!,
      type: TransactionType.sale,
      data: sale,
    )));

    combined.addAll(expensesList.map((expense) => TransactionRecord(
      date: expense.date!,
      createdAt: expense.createdAt!,
      type: TransactionType.expense,
      data: expense,
    )));

    combined.sort((a, b) {
      int compareDate = b.date.compareTo(a.date);
      if (compareDate != 0) return compareDate;
      return b.createdAt.compareTo(a.createdAt);
    });

    _combinedTransactions = combined;
    notifyListeners();
  }

  Future<void> fetchMonthlyById(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.info('[MONTHLY REPORT] Fetching detail for ID: $id');

      final response = await MonthlyReportServices.fetchMonthlyCombined(id);
      combineTransactions(
        salesList: response.sales,
        expensesList: response.expenses,
      );

      setTotals(
        sales: response.totalSales,
        expenses: response.totalExpenses,
      );

      LoggerService.info('[MONTHLY REPORT] Successfully fetched and combined data for ID: $id');
    } catch (e, stackTrace) {
      LoggerService.error('[MONTHLY REPORT] Failed to fetch detail for ID: $id', error: e, stackTrace: stackTrace);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> downloadExcelFile(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final filePath = await MonthlyReportServices.downloadExcelReport();

      LoggerService.info('[PROVIDER] Report file successfully saved at $filePath');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report berhasil diunduh: $filePath')),
      );
    } catch (e) {
      LoggerService.error('[PROVIDER] Failed to download report file', error: e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunduh laporan: $e')),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await fetchInitialData();
    await fetchFinanceSummary();
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void setTotals({required int sales, required int expenses}) {
    _totalSales = sales;
    _totalExpenses = expenses;
    notifyListeners();
  }

  String formatCurrencyInt(int? value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value ?? 0);
  }

  void clearData() {
    _monthlyReports = [];
    _combinedTransactions = [];
    _reportSummaryCards = [];
    notifyListeners();
  }
}
