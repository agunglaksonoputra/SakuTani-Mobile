import 'package:flutter/material.dart';
import 'package:saku_tani_mobile/models/expenses_transaction.dart';
import 'package:saku_tani_mobile/services/expenses_services.dart';
import 'package:saku_tani_mobile/services/data_master_service.dart';
import 'package:saku_tani_mobile/services/logger_service.dart';

class ExpensesRecordProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController pricePerUnitController = TextEditingController();
  final TextEditingController shippingCostController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();

  List<String> unitOptions = [];

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  double parseIndoNumber(String input) {
    final cleaned = input.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }

  Future<bool> submitExpensesRecord() async {
    if (!_validateForm()) {
      _errorMessage = 'Required fields are missing or invalid.';
      LoggerService.warning('[EXPENSES RECORD] Form validation failed.');
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final record = ExpensesTransaction(
        name: nameController.text,
        quantity: parseIndoNumber(quantityController.text),
        unit: unitController.text,
        pricePerUnit: parseIndoNumber(pricePerUnitController.text),
        shippingCost: parseIndoNumber(shippingCostController.text),
        discount: parseIndoNumber(discountController.text),
        totalAmount: parseIndoNumber(totalAmountController.text),
        notes: noteController.text.isEmpty ? null : noteController.text,
      );

      LoggerService.debug('[EXPENSES RECORD] Submitting data: ${record.toJson()}');

      final success = await ExpensesServices.createExpensesTransaction(record);

      if (success) {
        clearForm();
        LoggerService.info('[EXPENSES RECORD] Record submitted and form cleared.');
      } else {
        LoggerService.warning('[EXPENSES RECORD] Failed to submit expenses record.');
      }

      return success;
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      LoggerService.error('[EXPENSES RECORD] Exception during submission.', error: e, stackTrace: stackTrace);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOptions() async {
    try {
      _isLoading = true;
      notifyListeners();

      LoggerService.debug('[EXPENSES RECORD] Fetching unit options...');
      final options = await DataMasterService.fetchOptions();

      unitOptions = options['units'] ?? [];
      _errorMessage = null;
      LoggerService.info('[EXPENSES RECORD] Options fetched: ${unitOptions.length} units');
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      LoggerService.error('[EXPENSES RECORD] Failed to fetch options.', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _validateForm() {
    final quantity = parseIndoNumber(quantityController.text);
    final pricePerUnit = parseIndoNumber(pricePerUnitController.text);
    final totalAmount = parseIndoNumber(totalAmountController.text);

    final isValid = nameController.text.isNotEmpty &&
        unitController.text.isNotEmpty &&
        quantity > 0 &&
        pricePerUnit > 0 &&
        totalAmount > 0;

    return isValid;
  }

  void clearForm() {
    nameController.clear();
    quantityController.clear();
    unitController.clear();
    pricePerUnitController.clear();
    shippingCostController.clear();
    discountController.clear();
    noteController.clear();
    totalAmountController.clear();

    LoggerService.debug('[EXPENSES RECORD] Form cleared.');
    notifyListeners();
  }
}
