import 'package:intl/intl.dart';

class MonthlyReportResponse {
  final int? id;
  final DateTime? date;
  final double? totalSales;
  final double? totalExpenses;
  final double? totalProfit;

  MonthlyReportResponse({
    this.id,
    this.date,
    this.totalSales,
    this.totalExpenses,
    this.totalProfit
  });

  String get formattedDate {
    if (date == null) return '-';
    return DateFormat('MMMM yyyy', 'id_ID').format(date!);
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

  factory MonthlyReportResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyReportResponse(
      id: json['id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      totalSales: double.tryParse(json['total_sales']),
      totalExpenses: double.tryParse(json['total_expenses']),
      totalProfit: double.tryParse(json['total_profit']),
    );
  }

}