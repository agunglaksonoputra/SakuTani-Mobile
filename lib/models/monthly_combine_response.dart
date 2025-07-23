import 'package:intl/intl.dart';
import 'package:saku_tani_mobile/models/expenses_transaction.dart';
import 'package:saku_tani_mobile/models/sale_transaction.dart';

class MonthlyCombinedResponse {
  final int totalSales;
  final int totalExpenses;
  final List<SaleTransaction> sales;
  final List<ExpensesTransaction> expenses;

  MonthlyCombinedResponse({
    required this.totalSales,
    required this.totalExpenses,
    required this.sales,
    required this.expenses
  });

  factory MonthlyCombinedResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyCombinedResponse(
      totalSales: json['totalSales'],
      totalExpenses: json['totalExpenses'],
      sales: (json['sales'] as List).map((e) => SaleTransaction.fromJson(e)).toList(),
      expenses: (json['expenses'] as List).map((e) => ExpensesTransaction.fromJson(e)).toList(),
    );
  }
}
