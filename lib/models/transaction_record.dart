import 'sale_transaction.dart';
import 'expenses_transaction.dart';

enum TransactionType { sale, expense }

class TransactionRecord {
  final DateTime date;
  final DateTime createdAt;
  final TransactionType type;
  final Object data;

  TransactionRecord({
    required this.date,
    required this.createdAt,
    required this.type,
    required this.data,
  });

  SaleTransaction? get asSale =>
      type == TransactionType.sale ? data as SaleTransaction : null;

  ExpensesTransaction? get asExpense =>
      type == TransactionType.expense ? data as ExpensesTransaction : null;
}

