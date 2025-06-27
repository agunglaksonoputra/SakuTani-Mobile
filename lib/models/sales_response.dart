import 'package:saku_tani_mobile/models/sale_transaction.dart';

class SalesResponse {
  final List<SaleTransaction> sales;
  final int totalPrice;
  final double totalWeightKg;

  SalesResponse({
    required this.sales,
    required this.totalPrice,
    required this.totalWeightKg,
  });
}