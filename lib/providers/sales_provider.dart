import 'package:flutter/material.dart';
import '../models/sale_transaction.dart';
import '../models/sales_summary.dart';
import '../services/sales_services.dart';

class SalesProvider extends ChangeNotifier {
  List<SaleTransaction> _transactions = [];
  SalesSummary _summary = SalesSummary(totalSales: 0, totalWeight: 0, totalTransactions: 0);

  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;

  DateTimeRange? _selectedDateRange;

  // Getters
  List<SaleTransaction> get transactions => _transactions.where((t) => t.isDeleted == false).toList();
  List<SaleTransaction> get filteredTransactions {
    if (_selectedDateRange == null) return transactions;
    return transactions.where((tx) {
      if (tx.date == null) return false;
      return tx.date!.isAfter(_selectedDateRange!.start.subtract(Duration(days: 1))) &&
          tx.date!.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
    }).toList();
  }

  SalesSummary get summary => _summary;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  SalesProvider() {
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    _isLoading = true;
    _page = 1;
    _hasMore = true;
    notifyListeners();

    try {
      final response = await SalesService.fetchSales(page: _page, limit: _limit);
      _transactions = response.sales;
      _hasMore = response.sales.length >= _limit;

      _summary = SalesSummary(
        totalSales: response.totalPrice.toDouble(),
        totalWeight: response.totalWeightKg,
        totalTransactions: response.sales.length,
      );
      print("data berhasil diambil");
    } catch (e) {
      print("❌ Gagal ambil data awal: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    fetchInitialData();
    loadMoreData();
  }

  Future<void> loadMoreData() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _page++;
      final response = await SalesService.fetchSales(page: _page, limit: _limit);
      _transactions.addAll(response.sales);
      _hasMore = response.sales.length >= _limit;

      // update summary total juga kalau ingin akurat
      _summary = SalesSummary(
        totalSales: response.totalPrice.toDouble(),
        totalWeight: response.totalWeightKg,
        totalTransactions: _transactions.length,
      );
    } catch (e) {
      print("❌ Gagal load more data: $e");
      _page--;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // Commands
  Future<void> addTransaction(SaleTransaction transaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      // await SalesService.addSale(transaction);
      await fetchInitialData();
    } catch (e) {
      print("❌ Gagal menambahkan transaksi: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTransaction(int id, SaleTransaction updatedTransaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      // await SalesService.updateSale(id, updatedTransaction);
      await fetchInitialData();
    } catch (e) {
      print("❌ Gagal mengupdate transaksi: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteTransaction(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await SalesService.softDeleteSaleTransaction(id);
      await fetchInitialData();
    } catch (e) {
      print("❌ Gagal menghapus transaksi: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Date Filter
  void setDateFilter(DateTimeRange range) {
    _selectedDateRange = range;
    notifyListeners();
  }

  void clearDateFilter() {
    _selectedDateRange = null;
    notifyListeners();
  }

  // Formatter
  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}';
  }

  String formatWeight(double weight) {
    return '${weight.toStringAsFixed(2)} kg';
  }
}