import 'package:flutter/material.dart';
import 'package:saku_tani_mobile/services/shares_services.dart';

import '../models/user_balance.dart';

class SharesProvider with ChangeNotifier {
  final ShareService _shareService = ShareService();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<UserBalance> _userBalances = [];
  double _totalBalance = 0;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  List<UserBalance> get userBalances => _userBalances;
  double get totalBalance => _totalBalance;

  UserBalance get zakatBalance {
    return _userBalances.firstWhere(
          (u) => u.userName.toLowerCase() == 'zakat',
      orElse: () => UserBalance(userName: 'Zakat', balance: 0),
    );
  }

  List<UserBalance> get otherUserBalances {
    return _userBalances
        .where((u) => u.userName.toLowerCase() != 'zakat')
        .toList();
  }

  Future<void> refreshData() async {
    loadUserBalances();
  }

  Future<void> loadUserBalances() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ShareService.getUserBalances();
      _totalBalance = response.totalBalance;
      _userBalances = response.data;
    } catch (e) {
      print("Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}';
  }
}