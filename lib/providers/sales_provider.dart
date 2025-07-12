import 'package:flutter/material.dart';
import '../models/sale_transaction.dart';
import '../models/sales_summary.dart';
import '../services/sales_services.dart';
import '../services/logger_service.dart';

class SalesProvider extends ChangeNotifier {
  // Data utama
  List<SaleTransaction> _transactions = [];
  SalesSummary _summary = SalesSummary(totalSales: 0, totalWeight: 0, totalTransactions: 0);

  // State
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;

  // Filter
  DateTimeRange? _selectedDateRange;

  // Getters
  List<SaleTransaction> get transactions =>
      _transactions.where((t) => t.deletedAt == null).toList();

  List<SaleTransaction> get filteredTransactions {
    if (_selectedDateRange == null) return transactions;

    return transactions.where((tx) {
      if (tx.date == null) return false;
      return tx.date!.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
          tx.date!.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
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

  /// Fetch awal (reset page, summary, hasMore)
  Future<void> fetchInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _page = 1;
      _hasMore = true;

      LoggerService.info('[SALES] Fetching initial sales data (page: $_page)...');

      final response = await SalesService.fetchSales(page: _page, limit: _limit);

      _transactions = response.sales;
      _hasMore = response.sales.length >= _limit;

      _summary = SalesSummary(
        totalSales: response.totalPrice.toDouble(),
        totalWeight: response.totalWeightKg,
        totalTransactions: response.sales.length,
      );

      LoggerService.info('[SALES] Successfully fetched ${response.sales.length} records.');
    } catch (e, st) {
      LoggerService.error('[SALES] Failed to fetch initial sales data.', error: e, stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh data dan langsung loadMore untuk page berikutnya
  Future<void> refreshData() async {
    LoggerService.debug('[SALES] Refreshing sales data...');
    await Future.delayed(const Duration(milliseconds: 300));
    await fetchInitialData();
  }

  /// Load halaman berikutnya jika masih ada
  Future<void> loadMoreData() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _page++;
      LoggerService.debug('[SALES] Loading more data (page: $_page)...');

      final response = await SalesService.fetchSales(page: _page, limit: _limit);
      _transactions.addAll(response.sales);
      _hasMore = response.sales.length >= _limit;

      LoggerService.info('[SALES] Loaded ${response.sales.length} more records.');
    } catch (e, st) {
      _page--; // rollback page jika error
      LoggerService.error('[SALES] Failed to load more data.', error: e, stackTrace: st);
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Delete transaksi dan refresh data (termasuk filter)
  Future<void> deleteTransaction(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.debug('[SALES] Deleting transaction ID: $id...');
      await SalesService.softDeleteSaleTransaction(id);
      await fetchInitialData();
      LoggerService.info('[SALES] Transaction deleted.');
    } catch (e, st) {
      LoggerService.error('[SALES] Failed to delete transaction.', error: e, stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Set filter tanggal
  void setDateFilter(DateTimeRange range) {
    _selectedDateRange = range;
    LoggerService.debug('[SALES] Filter set: ${range.start} to ${range.end}');
    notifyListeners();
  }

  /// Hapus filter tanggal
  void clearDateFilter() {
    _selectedDateRange = null;
    LoggerService.debug('[SALES] Date filter cleared.');
    notifyListeners();
  }

  /// Format tampilan rupiah
  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}';
  }

  /// Format berat
  String formatWeight(double weight) {
    return '${weight.toStringAsFixed(2)} kg';
  }
}