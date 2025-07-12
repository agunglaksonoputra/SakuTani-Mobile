import 'package:flutter/material.dart';
import 'package:saku_tani_mobile/models/withdraw_response.dart';
import 'package:saku_tani_mobile/services/shares_services.dart';
import '../models/user_balance.dart';
import '../services/logger_service.dart';

class SharesProvider with ChangeNotifier {
  List<WithdrawResponse> _withdrawLog = [];
  List<UserBalance> _userBalances = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;

  DateTimeRange? _selectedDateRange;

  // Getters
  List<WithdrawResponse> get transactions =>
      _withdrawLog.where((t) => t.deletedAt == null).toList();

  List<WithdrawResponse> get filteredTransactions {
    if (_selectedDateRange == null) return transactions;
    return transactions.where((tx) {
      if (tx.date == null) return false;
      return tx.date!.isAfter(_selectedDateRange!.start.subtract(Duration(days: 1))) &&
          tx.date!.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
    }).toList();
  }

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  double get totalBalance =>
      _userBalances.fold(0, (sum, item) => sum + item.balance);

  List<UserBalance> get userBalances => _userBalances;

  DateTimeRange? get selectedDateRange => _selectedDateRange;

  UserBalance get zakatBalance {
    return _userBalances.firstWhere(
          (item) => item.name == 'Zakat',
      orElse: () => UserBalance(name: 'Zakat', balance: 0.0),
    );
  }

  List<UserBalance> get otherUserBalances {
    return _userBalances
        .where((item) => item.name != 'Zakat')
        .toList();
  }

  /// Refresh both balances and withdraw logs
  Future<void> refreshData() async {
    LoggerService.info('[SHARES] Refreshing balances and withdrawal logs...');
    await Future.wait([
      loadUserBalances(),
      loadMoreWithdrawLog(),
    ]);
  }

  /// Load all user balances
  Future<void> loadUserBalances() async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.debug('[SHARES] Fetching user balances...');
      final List<UserBalance> response = await ShareService.getUserBalances();
      _userBalances = response;
      LoggerService.info('[SHARES] User balances loaded.');
    } catch (e, st) {
      _userBalances = [];
      LoggerService.error('[SHARES] Failed to fetch user balances.', error: e, stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load paginated withdraw log
  Future<void> loadMoreWithdrawLog() async {
    _isLoading = true;
    _isLoadingMore = true;
    _page = 1;
    _hasMore = true;
    notifyListeners();

    try {
      LoggerService.debug('[SHARES] Fetching withdraw log (Page $_page)...');
      final response = await ShareService.getWithdrawLog(page: _page, limit: _limit);
      _withdrawLog = response;
      _hasMore = response.length >= _limit;

      LoggerService.info('[SHARES] Withdraw log loaded: ${response.length} records.');
    } catch (e, st) {
      _hasMore = false;
      LoggerService.error('[SHARES] Failed to fetch withdraw log.', error: e, stackTrace: st);
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  /// Delete transaksi dan refresh data (termasuk filter)
  Future<void> deleteTransaction(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.debug('[WITHDRAW] Deleting transaction ID: $id...');
      await ShareService.softDeleteWithdrawTransaction(id);
      await refreshData();
      LoggerService.info('[WITHDRAW] Transaction deleted.');
    } catch (e, st) {
      LoggerService.error('[WITHDRAW] Failed to delete transaction.', error: e, stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Set date range filter
  void setDateFilter(DateTimeRange range) {
    _selectedDateRange = range;
    notifyListeners();
    LoggerService.debug('[SHARES] Date filter applied: ${range.start} - ${range.end}');
  }

  /// Clear date filter
  void clearDateFilter() {
    _selectedDateRange = null;
    notifyListeners();
    LoggerService.debug('[SHARES] Date filter cleared.');
  }

  /// Format currency to Rupiah
  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}';
  }
}