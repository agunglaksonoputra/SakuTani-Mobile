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
  List<SaleTransaction> get transactions => _transactions;
  SalesSummary get summary => _summary;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  SalesProvider() {
    fetchInitialData();
  }

  /// Fetch awal (tanpa filter)
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

  /// Refresh data (gunakan ulang filter jika ada)
  Future<void> refreshData() async {
    LoggerService.debug('[SALES] Refreshing sales data...');
    await Future.delayed(const Duration(milliseconds: 300));

    if (_selectedDateRange != null) {
      await fetchFilteredData(_selectedDateRange!);
    } else {
      await fetchInitialData();
    }
  }

  /// Load more data (dengan atau tanpa filter)
  Future<void> loadMoreData() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _page++;
      LoggerService.debug('[SALES] Loading more data (page: $_page)...');

      final response = await SalesService.fetchSales(
        page: _page,
        limit: _limit,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      );

      _transactions.addAll(response.sales);
      _hasMore = response.sales.length >= _limit;

      LoggerService.info('[SALES] Loaded ${response.sales.length} more records.');
    } catch (e, st) {
      _page--;
      LoggerService.error('[SALES] Failed to load more data.', error: e, stackTrace: st);
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Delete transaksi
  Future<void> deleteTransaction(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.debug('[SALES] Deleting transaction ID: $id...');
      await SalesService.softDeleteSaleTransaction(id);
      await refreshData();
      LoggerService.info('[SALES] Transaction deleted.');
    } catch (e, st) {
      LoggerService.error('[SALES] Failed to delete transaction.', error: e, stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Set filter tanggal (memfetch data baru)
  Future<void> setDateFilter(DateTimeRange range) async {
    _selectedDateRange = range;
    await fetchFilteredData(range);
  }

  /// Hapus filter tanggal dan fetch ulang data awal
  Future<void> clearDateFilter() async {
    _selectedDateRange = null;
    LoggerService.debug('[SALES] Date filter cleared.');
    await fetchInitialData();
  }

  /// Fetch berdasarkan filter
  Future<void> fetchFilteredData(DateTimeRange range) async {
    _isLoading = true;
    notifyListeners();

    try {
      _page = 1;
      _hasMore = true;

      LoggerService.debug('[SALES] Fetching filtered data from ${range.start} to ${range.end}...');

      final response = await SalesService.fetchSales(
        page: _page,
        limit: _limit,
        startDate: range.start,
        endDate: range.end,
      );

      _transactions = response.sales;
      _hasMore = response.sales.length >= _limit;

      _summary = SalesSummary(
        totalSales: response.totalPrice.toDouble(),
        totalWeight: response.totalWeightKg,
        totalTransactions: response.sales.length,
      );

      LoggerService.info('[SALES] Fetched ${response.sales.length} filtered records.');
    } catch (e, st) {
      LoggerService.error('[SALES] Failed to fetch filtered data.', error: e, stackTrace: st);
    }

    _isLoading = false;
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