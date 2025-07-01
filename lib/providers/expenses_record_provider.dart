import 'package:flutter/material.dart';
import 'package:saku_tani_mobile/models/expenses_transaction.dart';
import 'package:saku_tani_mobile/services/expenses_services.dart';

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

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<bool> submitExpensesRecord() async {
    if (!_validateForm()) {
      _errorMessage = 'Field wajib diisi!';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ExpensesRecord = ExpensesTransaction(
        name: nameController.text,
        quantity: double.parse(quantityController.text),
        unit: unitController.text,
        // weightPerUnitGram: double.parse(weightPerUnitController.text),
        pricePerUnit: double.parse(pricePerUnitController.text),
        shippingCost: double.parse(shippingCostController.text),
        discount: double.parse(discountController.text),
        totalAmount: double.parse(totalAmountController.text),
        notes: noteController.text.isEmpty ? null : noteController.text,

      );

      final success = await ExpensesServices.createExpensesTransaction(ExpensesRecord);

      if (success) {
        clearForm();
      }
      // print('Berhasil terkirim');
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

  }

  bool _validateForm() {
    return nameController.text.isNotEmpty &&
        quantityController.text.isNotEmpty &&
        unitController.text.isNotEmpty &&
        totalAmountController.text.isNotEmpty;
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
    notifyListeners();
  }
}