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
  final bool? isDeleted;
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
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  String get formattedDate {
    if (date == null) return '-';
    return DateFormat('d MMMM yyyy', 'id_ID').format(date!);
  }

  String formatDouble(double? value) {
    if (value == null || value == 0) return '0';

    // Format dengan 2 desimal dulu
    String result = value.toStringAsFixed(2);

    // Hilangkan nol di belakang koma jika tidak diperlukan (contoh: 1.50 -> 1.5, 1.00 -> 1)
    result = result.replaceFirst(RegExp(r'\.?0+$'), '');
    return result;
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
      totalAmount: double.tryParse(json['total_amount']),
      notes: json['notes'],
      isDeleted: json['is_deleted'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price_per_unit': pricePerUnit,
      'shipping_cost': shippingCost,
      'discount': discount,
      'total_amount': totalAmount,
      'notes': notes,
    };
  }
}