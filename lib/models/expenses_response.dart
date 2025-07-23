import 'package:saku_tani_mobile/models/expenses_transaction.dart';

class ExpensesResponse {
  final List<ExpensesTransaction> expenses;
  final int totalAmount;
  // final double totalWeightKg;

  ExpensesResponse({
    required this.expenses,
    required this.totalAmount,
    // required this.totalWeightKg,
  });
}