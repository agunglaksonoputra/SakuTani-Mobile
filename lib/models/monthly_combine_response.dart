import 'package:saku_tani_mobile/models/expenses_transaction.dart';
import 'package:saku_tani_mobile/models/sale_transaction.dart';

class MonthlyCombinedResponse {
  final List<SaleTransaction> sales;
  final List<ExpensesTransaction> expenses;

  MonthlyCombinedResponse({required this.sales, required this.expenses});

  factory MonthlyCombinedResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyCombinedResponse(
      sales: (json['sales'] as List).map((e) => SaleTransaction.fromJson(e)).toList(),
      expenses: (json['expenses'] as List).map((e) => ExpensesTransaction.fromJson(e)).toList(),
    );
  }
}
