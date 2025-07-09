import 'package:saku_tani_mobile/models/expenses_transaction.dart';

class ExpensesResponse {
  final List<ExpensesTransaction> expenses;
  final double totalAmount;
  // final double totalWeightKg;

  ExpensesResponse({
    required this.expenses,
    required this.totalAmount,
    // required this.totalWeightKg,
  });

  factory ExpensesResponse.fromJson(Map<String, dynamic> json) {
    double parseToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return ExpensesResponse(
      expenses: (json['data'] as List)
          .map((e) => ExpensesTransaction.fromJson(e))
          .toList(),
      totalAmount: parseToDouble(json['total_price'] ?? json['totalPrice']),
    );
  }

}