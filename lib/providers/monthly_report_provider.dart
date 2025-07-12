import 'package:flutter/material.dart';
import 'package:saku_tani_mobile/models/expenses_transaction.dart';
import 'package:saku_tani_mobile/models/monthly_report_response.dart';
import 'package:saku_tani_mobile/models/sale_transaction.dart';
import 'package:saku_tani_mobile/services/monthly_report_services.dart';

import '../models/transaction_record.dart';
import '../services/logger_service.dart';

class MonthlyReportProvider with ChangeNotifier {
  List<MonthlyReportResponse> _monthlyReports = [];
  List<TransactionRecord> _combinedTransactions = [];
  bool _isLoading = false;

  List<MonthlyReportResponse> get monthlyReports => _monthlyReports;
  List<TransactionRecord> get combinedTransactions => _combinedTransactions;

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

    // Sort berdasarkan field 'date', bukan 'createdAt'
    combined.sort((a, b) {
      final dateA = a.date;
      final dateB = b.date;

      // Urutkan dulu berdasarkan date
      int compareDate = dateB.compareTo(dateA);
      if (compareDate != 0) return compareDate;

      // Jika tanggal sama, bandingkan berdasarkan createdAt
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
      final sales = response.sales;
      final expenses = response.expenses;
      combineTransactions(salesList: sales, expensesList: expenses);

      LoggerService.info('[MONTHLY REPORT] Successfully fetched and combined data for ID: $id');
    } catch (e, stackTrace) {
      LoggerService.error(
        '[MONTHLY REPORT] Failed to fetch detail for ID: $id',
        error: e,
        stackTrace: stackTrace,
      );
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
        SnackBar(content: Text('Report successfully downloaded to: $filePath')),
      );
    } catch (e) {
      LoggerService.error('[PROVIDER] Failed to download report file', error: e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download report: $e')),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await fetchInitialData();
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void clearData() {
    _monthlyReports = [];
    notifyListeners();
  }
}