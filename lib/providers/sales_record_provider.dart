import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saku_tani_mobile/models/sale_transaction.dart';
import 'package:saku_tani_mobile/services/sales_services.dart';
import '../services/data_master_service.dart';
import '../services/logger_service.dart';

class SalesRecordProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? selectedDate;

  final TextEditingController customerController = TextEditingController();
  final TextEditingController vegetableController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController weightPerUnitController = TextEditingController();
  final TextEditingController pricePerUnitController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController totalPriceController = TextEditingController();
  final TextEditingController totalWeightPerKgController = TextEditingController();

  List<String> customerOptions = [];
  List<String> vegetableOptions = [];
  List<String> unitOptions = [];

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Capitalize the first letter of a string
  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  // Format decimal numbers in Indonesian format
  String formatDecimal(double? value) {
    if (value == null || value == 0) return '0';
    final formatter = NumberFormat("#,##0.##", "id");
    return formatter.format(value);
  }

  // Convert string with dot/comma separator to double
  double parseIndoNumber(String input) {
    return double.tryParse(input.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
  }

  DateTime? convertToIsoDate(String text) {
    final parts = text.split(' ');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final monthName = parts[1];
      final year = int.tryParse(parts[2]);

      const bulan = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final month = bulan.indexOf(monthName) + 1;

      if (day != null && month > 0 && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  // Auto-calculation: total price = quantity * price/unit
  double get totalPriceCount {
    final quantity = parseIndoNumber(quantityController.text);
    final price = parseIndoNumber(pricePerUnitController.text);
    return quantity * price;
  }

  // Auto-calculation: total weight in KG = (quantity * weight/unit) / 1000
  double get totalWeightKgCount {
    final quantity = parseIndoNumber(quantityController.text);
    final weight = parseIndoNumber(weightPerUnitController.text);
    return (quantity * weight) / 1000;
  }

  /// Submit new sales transaction
  Future<bool> submitSalesRecord() async {
    if (!validateForm()) {
      _errorMessage = 'All required fields must be filled.';
      notifyListeners();
      LoggerService.warning('[SALES] Submission failed: Validation failed.');
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sale = SaleTransaction(
        date: selectedDate,
        customerName: customerController.text,
        itemName: vegetableController.text,
        quantity: parseIndoNumber(quantityController.text),
        unit: unitController.text,
        weightPerUnitGram: parseIndoNumber(weightPerUnitController.text),
        totalWeightKg: parseIndoNumber(totalWeightPerKgController.text),
        pricePerUnit: parseIndoNumber(pricePerUnitController.text),
        totalPrice: parseIndoNumber(totalPriceController.text),
        notes: noteController.text.isEmpty ? null : noteController.text,
      );

      LoggerService.info('[SALES] Sending transaction data to backend...');
      LoggerService.debug('Transaction Payload: ${jsonEncode(sale.toJson())}');
      final success = await SalesService.createSalesTransaction(sale);

      if (success) {
        LoggerService.info('[SALES] Sales transaction submitted successfully.');
        clearForm();
      } else {
        LoggerService.warning('[SALES] Failed to submit sales transaction.');
      }

      return success;
    } catch (e, st) {
      _errorMessage = e.toString();
      LoggerService.error('[SALES] Exception occurred while submitting transaction.', error: e, stackTrace: st);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch options (customer, vegetable, unit)
  Future<void> fetchOptions() async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.info('[SALES] Fetching form options...');
      final options = await DataMasterService.fetchOptions();

      customerOptions = options['customers'] ?? [];
      vegetableOptions = (options['vegetables'] ?? []).map<String>((v) => _capitalize(v)).toList();
      unitOptions = options['units'] ?? [];

      LoggerService.info('[SALES] Options fetched successfully.');
      _errorMessage = null;
    } catch (e, st) {
      _errorMessage = e.toString();
      LoggerService.error('[SALES] Failed to fetch options.', error: e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Form validation
  bool validateForm() {
    final quantity = parseIndoNumber(quantityController.text);
    final totalPrice = parseIndoNumber(totalPriceController.text);
    final totalWeight = parseIndoNumber(totalWeightPerKgController.text);

    return customerController.text.isNotEmpty &&
        vegetableController.text.isNotEmpty &&
        unitController.text.isNotEmpty &&
        quantity > 0 &&
        totalPrice > 0 &&
        totalWeight > 0;
  }

  /// Clear all form fields
  void clearForm() {
    selectedDate = null;
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

    LoggerService.debug('[SALES] Form cleared.');
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