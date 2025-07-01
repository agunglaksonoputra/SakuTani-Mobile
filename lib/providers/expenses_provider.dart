import 'package:flutter/material.dart';
import 'package:saku_tani_mobile/models/expenses_transaction.dart';
import 'package:saku_tani_mobile/services/expenses_services.dart';

class ExpensesProvider extends ChangeNotifier {
  List<ExpensesTransaction> _transactions = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;
  DateTimeRange? _selectedDateRange;

  List<ExpensesTransaction> get transactions => _transactions.where((t) => t.isDeleted == false).toList();
  List<ExpensesTransaction> get filteredTransactions {
    if (_selectedDateRange == null) return transactions;
    return transactions.where((tx) {
      if (tx.date == null) return false;
      return tx.date!.isAfter(_selectedDateRange!.start.subtract(Duration(days: 1))) &&
          tx.date!.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
    }).toList();
  }
  Map<String, dynamic> get summary => _summary;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  Future<void> fetchInitialData() async {
    _isLoading = true;
    _page = 1;
    _hasMore = true;
    notifyListeners();

    try {
      final response = await ExpensesServices.fetchExpenses(page: _page, limit: _limit);
      _transactions = response.expenses;
      _hasMore = response.expenses.length >= _limit;

      _summary = {
        'totalAmount': response.totalAmount
      };
    } catch (e) {
      print("Gagal ambil data awal: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    fetchInitialData();
    loadMoreData();
  }

  Future<void> deleteTransaction(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ExpensesServices.softDeleteExpensesTransaction(id);
      await fetchInitialData();
    } catch (e) {
      print("Gagal menghapus transaksi: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreData() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _page++;
      final response = await ExpensesServices.fetchExpenses(page: _page, limit: _limit);
      _transactions.addAll(response.expenses);
      _hasMore = response.expenses.length >= _limit;

    } catch (e) {
      print("Gagal load more data: $e");
      _page--;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  void setDateFilter(DateTimeRange range) {
    _selectedDateRange = range;
    notifyListeners();
  }

  void clearDateFilter() {
    _selectedDateRange = null;
    notifyListeners();
  }

  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}';
  }

}