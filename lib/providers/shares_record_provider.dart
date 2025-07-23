import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saku_tani_mobile/models/withdraw_log.dart';
import 'package:saku_tani_mobile/models/withdraw_response.dart';
import '../models/user_balance.dart';
import '../services/data_master_service.dart';
import '../services/shares_services.dart';
import '../services/logger_service.dart';

class SharesRecordProvider with ChangeNotifier {
  final List<UserBalance> _userBalances = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? selectedDate;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  List<String> ownerOptions = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<UserBalance> get userBalances => _userBalances;

  SharesRecordProvider() {
    nameController.addListener(() {
      notifyListeners();
    });
  }

  String formatDecimal(double? value) {
    if (value == null || value == 0) return '0';
    final formatter = NumberFormat("#,##0.##", "id");
    return formatter.format(value);
  }

  double parseNumber(String input) {
    return double.tryParse(input.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
  }

  UserBalance? get selectedUserBalance {
    final selected = nameController.text;
    LoggerService.debug('[SHARES-RECORD] Selected name: $selected');

    if (selected.isEmpty) return null;

    final result = _userBalances.firstWhere(
          (item) => item.name == selected,
      orElse: () {
        LoggerService.warning('[SHARES-RECORD] No user found for name: $selected');
        return UserBalance(name: selected, balance: 0.0);
      },
    );

    LoggerService.info('[SHARES-RECORD] Selected user balance: ${result.name} - ${result.balance}');
    return result;
  }

  Future<bool> submitWithdrawRecord() async {
    if (!_validateForm()) {
      _errorMessage = 'Required fields must be filled.';
      notifyListeners();
      LoggerService.warning('[SHARES-RECORD] Form validation failed.');
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final withdraw = WithdrawLog(
        userName: nameController.text,
        amount: parseNumber(amountController.text),
      );

      LoggerService.debug('[SHARES-RECORD] Submitting withdraw: ${withdraw.toJson()}');
      final success = await ShareService.createWithdrawTransaction(withdraw);

      if (success) {
        LoggerService.info('[SHARES-RECORD] Withdraw transaction submitted successfully.');
        clearForm();
      }

      return success;
    } catch (e, st) {
      _errorMessage = e.toString();
      LoggerService.error('[SHARES-RECORD] Failed to submit withdraw transaction.', error: e, stackTrace: st);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserBalances() async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.debug('[SHARES-RECORD] Fetching user balances...');
      final response = await ShareService.getUserBalances();
      _userBalances
        ..clear()
        ..addAll(response);
      LoggerService.info('[SHARES-RECORD] User balances loaded.');
    } catch (e, st) {
      _userBalances.clear();
      LoggerService.error('[SHARES-RECORD] Failed to load user balances.', error: e, stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOptions() async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.debug('[SHARES-RECORD] Fetching owner options...');
      final options = await DataMasterService.fetchOptions();
      ownerOptions = options['owners'] ?? [];
      _errorMessage = null;
      LoggerService.info('[SHARES-RECORD] Owner options fetched: ${ownerOptions.length} items.');
    } catch (e, st) {
      _errorMessage = e.toString();
      LoggerService.error('[SHARES-RECORD] Failed to fetch owner options.', error: e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _validateForm() {
    final amount = parseNumber(amountController.text);
    final isValid = nameController.text.isNotEmpty && amount > 0;

    LoggerService.debug(
        '[SHARES-RECORD] Form validation: name="${nameController.text}", amount=$amount, valid=$isValid');

    return isValid;
  }

  void clearForm() {
    selectedDate = null;
    nameController.clear();
    amountController.clear();
    notifyListeners();
    LoggerService.debug('[SHARES-RECORD] Form cleared.');
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
    LoggerService.info('[SHARES-RECORD] Provider disposed.');
  }
}