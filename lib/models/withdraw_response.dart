import 'package:intl/intl.dart';

class WithdrawResponse {
  final int? id;
  final String? name;
  final double? amount;
  final DateTime? date;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  WithdrawResponse({
    this.id,
    this.name,
    this.amount,
    this.date,
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

  factory WithdrawResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawResponse(
      id: json['id'],
      name: json['name'],
      amount: double.tryParse(json['amount']),
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
    };
  }
}