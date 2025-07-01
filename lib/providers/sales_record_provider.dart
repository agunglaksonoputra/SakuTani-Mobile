import 'package:flutter/material.dart';
import 'package:saku_tani_mobile/models/sale_transaction.dart';
import 'package:saku_tani_mobile/services/sales_services.dart';

class SalesRecordProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController customerController = TextEditingController();
  final TextEditingController vegetableController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController weightPerUnitController = TextEditingController();
  final TextEditingController pricePerUnitController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController totalPriceController = TextEditingController();
  final TextEditingController totalWeightPerKgController = TextEditingController();

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  double get totalPriceCount {
    final quantity = double.tryParse(quantityController.text) ?? 0;
    final price = double.tryParse(pricePerUnitController.text) ?? 0;
    return quantity * price;
  }

  double get totalWeightKgCount {
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final weight = double.tryParse(weightPerUnitController.text) ?? 0;
    return (quantity * weight) / 1000;
  }

  Future<bool> submitSalesRecord() async {
    if (!_validateForm()) {
      _errorMessage = 'Field wajib diisi!';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final SalesRecord = SaleTransaction(
        customerName: customerController.text,
        itemName: vegetableController.text,
        quantity: int.parse(quantityController.text),
        unit: unitController.text,
        weightPerUnitGram: double.parse(weightPerUnitController.text),
        totalWeightKg: double.parse(totalWeightPerKgController.text),
        pricePerUnit: double.parse(pricePerUnitController.text),
        totalPrice: double.parse(totalPriceController.text),
        notes: noteController.text.isEmpty ? null : noteController.text,
      );

      final success = await SalesService.createSalesTransaction(SalesRecord);

      if (success) {
        clearForm();
      }
      print('Berhasil terkirim');
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
    return customerController.text.isNotEmpty &&
      vegetableController.text.isNotEmpty &&
      quantityController.text.isNotEmpty &&
      unitController.text.isNotEmpty &&
      totalPriceController.text.isNotEmpty &&
      totalWeightPerKgController.text.isNotEmpty;
  }

  void clearForm() {
    customerController.clear();
    vegetableController.clear();
    quantityController.clear();
    unitController.clear();
    weightPerUnitController.clear();
    pricePerUnitController.clear();
    noteController.clear();
    totalPriceController.clear();
    totalWeightPerKgController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    customerController.dispose();
    vegetableController.dispose();
    quantityController.dispose();
    unitController.dispose();
    weightPerUnitController.dispose();
    pricePerUnitController.dispose();
    noteController.dispose();
    totalPriceController.dispose();
    totalWeightPerKgController.dispose();
    super.dispose();
  }
}