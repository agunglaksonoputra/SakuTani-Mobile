import 'package:intl/intl.dart';

class ExpensesTransaction {
  final int? id;
  final DateTime? date;
  final String? name;
  final double? quantity;
  final String? unit;
  final double? pricePerUnit;
  final double? shippingCost;
  final double? discount;
  final double? totalAmount;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExpensesTransaction({
    this.id,
    this.date,
    this.name,
    this.quantity,
    this.unit,
    this.pricePerUnit,
    this.shippingCost,
    this.discount,
    this.totalAmount,
    this.notes,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  String get formattedDate {
    if (date == null) return '-';
    return DateFormat('d MMMM yyyy', 'id_ID').format(date!);
  }

  String formatDouble(double? value) {
    if (value == null || value == 0) return '0';

    final formatter = NumberFormat("#,##0.##", "id_ID");

    return formatter.format(value);
  }

  String formatCurrency(double? value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value ?? 0);
  }

  factory ExpensesTransaction.fromJson(Map<String, dynamic> json) {
    return ExpensesTransaction(
      id: json['id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      name: json['name'],
      quantity: double.tryParse(json['quantity']),
      unit: json['unit'],
      pricePerUnit: double.tryParse(json['price_per_unit']),
      shippingCost: double.tryParse(json['shipping_cost']),
      discount: double.tryParse(json['discount']),
      totalAmount: double.tryParse(json['total_price']),
      notes: json['notes'],
      createdBy: json['created_by'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date != null ? DateFormat('yyyy-MM-dd').format(date!) : null,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price_per_unit': pricePerUnit,
      'shipping_cost': shippingCost,
      'discount': discount,
      'total_price': totalAmount,
      'notes': notes,
    };
  }
}