import 'package:flutter/material.dart';
import 'package:saku_tani_mobile/models/expenses_transaction.dart';
import 'package:saku_tani_mobile/services/expenses_services.dart';
import 'package:saku_tani_mobile/services/logger_service.dart';

class ExpensesProvider extends ChangeNotifier {
  List<ExpensesTransaction> _transactions = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;
  DateTimeRange? _selectedDateRange;

  List<ExpensesTransaction> get transactions => _transactions;
  Map<String, dynamic> get summary => _summary;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  // List<ExpensesTransaction> get filteredTransactions {
  //   if (_selectedDateRange == null) return transactions;
  //   return transactions.where((tx) {
  //     final date = tx.date;
  //     if (date == null) return false;
  //     return date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
  //         date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
  //   }).toList();
  // }

  Future<void> fetchInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _page = 1;
      _hasMore = true;

      LoggerService.debug('[EXPENSES] Fetching initial data...');
      final response = await ExpensesServices.fetchExpenses(page: _page, limit: _limit);

      _transactions = response.expenses;
      _hasMore = response.expenses.length >= _limit;

      _summary = {'totalAmount': response.totalAmount};

      LoggerService.info('[EXPENSES] Initial data fetched successfully. '
          'Total: ${_transactions.length}, Summary: $_summary');
    } catch (e, stackTrace) {
      LoggerService.error('[EXPENSES] Failed to fetch initial data.', error: e, stackTrace: stackTrace);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    LoggerService.debug('[EXPENSES] Refreshing data...');
    await Future.delayed(const Duration(milliseconds: 300));

    if (_selectedDateRange != null) {
      await fetchFilteredData(_selectedDateRange!);
    } else {
      await fetchInitialData();
    }
  }

  Future<void> loadMoreData() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _page++;
      LoggerService.debug('[EXPENSES] Loading more data (page $_page)...');

      final response = await ExpensesServices.fetchExpenses(
        page: _page,
        limit: _limit,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      );

      _transactions.addAll(response.expenses);
      _hasMore = response.expenses.length >= _limit;

      LoggerService.info('[EXPENSES] Loaded more data. Total now: ${_transactions.length}');
    } catch (e, st) {
      _page--;
      LoggerService.error('[EXPENSES] Failed to load more data.', error: e, stackTrace: st);
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> deleteTransaction(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.debug('[EXPENSES] Deleting transaction ID: $id');
      await ExpensesServices.softDeleteExpensesTransaction(id);
      await fetchInitialData();
      LoggerService.info('[EXPENSES] Transaction deleted and data refreshed.');
    } catch (e, st) {
      LoggerService.error('[EXPENSES] Failed to delete transaction.', error: e, stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
  }

  void setDateFilter(DateTimeRange range) async {
    _selectedDateRange = range;
    LoggerService.debug('[EXPENSES] Date filter set: $range');
    await fetchFilteredData(range);
  }

  Future<void> fetchFilteredData(DateTimeRange range) async {
    _isLoading = true;
    notifyListeners();

    try {
      _page = 1;
      _hasMore = true;

      LoggerService.debug('[EXPENSES] Fetching filtered data from ${range.start} to ${range.end}...');

      final response = await ExpensesServices.fetchExpenses(
        page: _page,
        limit: _limit,
        startDate: range.start,
        endDate: range.end,
      );

      _transactions = response.expenses;
      _hasMore = response.expenses.length >= _limit;

      _summary = {'totalAmount': response.totalAmount};

      LoggerService.info('[EXPENSES] Fetched ${response.expenses.length} filtered records.');
    } catch (e, st) {
      LoggerService.error('[EXPENSES] Failed to fetch filtered data.', error: e, stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearDateFilter() async {
    _selectedDateRange = null;
    LoggerService.debug('[EXPENSES] Date filter cleared.');
    await fetchInitialData();
  }

  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}';
  }
}
