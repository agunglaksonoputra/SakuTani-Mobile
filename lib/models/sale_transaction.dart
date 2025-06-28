import 'package:intl/intl.dart';

class SaleTransaction {
  final int? id;
  final DateTime? date;
  final String? customerName;
  final String? itemName;
  final int? quantity;
  final String? unit;
  final double? weightPerUnitGram;
  final double? totalWeightKg;
  final double? pricePerUnit;
  final double? totalPrice;
  final String? notes;
  final bool? isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SaleTransaction({
    this.id,
    this.date,
    this.customerName,
    this.itemName,
    this.quantity,
    this.unit,
    this.weightPerUnitGram,
    this.totalWeightKg,
    this.pricePerUnit,
    this.totalPrice,
    this.notes,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String get formattedDate {
    if (date == null) return '-';
    return DateFormat('d MMMM yyyy').format(date!);
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

  factory SaleTransaction.fromJson(Map<String, dynamic> json) {
    return SaleTransaction(
      id: json['id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      customerName: json['customer_name'],
      itemName: json['item_name'],
      quantity: json['quantity'],
      unit: json['unit'],
      weightPerUnitGram: double.tryParse(json['weight_per_unit_gram']),
      totalWeightKg: double.tryParse(json['total_weight_kg']),
      pricePerUnit: double.tryParse(json['price_per_unit']),
      totalPrice: double.tryParse(json['total_price']),
      notes: json['notes'],
      isDeleted: json['is_deleted'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'item_name': itemName,
      'quantity': quantity,
      'unit': unit,
      'weight_per_unit_gram': weightPerUnitGram,
      'total_weight_kg': totalWeightKg,
      'price_per_unit': pricePerUnit,
      'total_price': totalPrice,
      'notes': notes,
    };
  }
}