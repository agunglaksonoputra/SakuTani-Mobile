import 'package:intl/intl.dart';

class SaleTransaction {
  final int? id;
  final DateTime? date;
  final String? customerName;
  final String? itemName;
  final double? quantity;
  final String? unit;
  final double? weightPerUnitGram;
  final double? totalWeightKg;
  final double? pricePerUnit;
  final double? totalPrice;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

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
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
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

  static String _capitalize(String? value) {
    if (value == null || value.isEmpty) return '-';
    return value[0].toUpperCase() + value.substring(1);
  }

  factory SaleTransaction.fromJson(Map<String, dynamic> json) {
    return SaleTransaction(
      id: json['id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      customerName: json['customer'],
      itemName: _capitalize(json['item_name']),
      quantity: double.tryParse(json['quantity']),
      unit: json['unit'],
      weightPerUnitGram: double.tryParse(json['weight_per_unit_gram']),
      totalWeightKg: double.tryParse(json['total_weight_kg']),
      pricePerUnit: double.tryParse(json['price_per_unit']),
      totalPrice: double.tryParse(json['total_price']),
      notes: json['notes'],
      createdBy: json['created_by'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer': customerName,
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