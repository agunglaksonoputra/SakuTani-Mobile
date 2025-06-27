class SaleTransaction {
  final int? id;
  final DateTime? date;
  final String? customerName;
  final String? itemName;
  final int? quantity;
  final String unit;
  final double? weightPerUnitGram;
  final double? totalWeightKg;
  final double? pricePerUnit;
  final double? totalPrice;
  final String? notes;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  SaleTransaction({
    this.id,
    this.date,
    this.customerName,
    this.itemName,
    this.quantity,
    required this.unit,
    this.weightPerUnitGram,
    this.totalWeightKg,
    this.pricePerUnit,
    this.totalPrice,
    this.notes,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }


  factory SaleTransaction.fromJson(Map<String, dynamic> json) {
    return SaleTransaction(
      id: json['id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      customerName: json['customer_name'],
      itemName: json['item_name'],
      quantity: json['quantity'],
      unit: json['unit'] ?? '',
      weightPerUnitGram: double.tryParse(json['weight_per_unit_gram']),
      totalWeightKg: double.tryParse(json['total_weight_kg']),
      pricePerUnit: double.tryParse(json['price_per_unit']),
      totalPrice: double.tryParse(json['total_price']),
      notes: json['notes'],
      isDeleted: json['is_deleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String().split('T')[0],
      'customer_name': customerName,
      'item_name': itemName,
      'quantity': quantity,
      'unit': unit,
      'weight_per_unit_gram': weightPerUnitGram,
      'total_weight_kg': totalWeightKg,
      'price_per_unit': pricePerUnit,
      'total_price': totalPrice,
      'notes': notes,
      'is_deleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}