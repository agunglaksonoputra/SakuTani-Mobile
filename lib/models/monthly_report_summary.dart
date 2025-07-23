import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyReportSummary {
  final int? totalSales;
  final int? totalExpenses;
  final int? totalProfit;
  final double? avgSales;
  final HighestIncome? highestIncome;
  final LowestIncome? lowestIncome;

  MonthlyReportSummary({
    this.totalSales,
    this.totalExpenses,
    this.totalProfit,
    this.avgSales,
    this.highestIncome,
    this.lowestIncome
  });



  String formatCurrency(double? value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value ?? 0);
  }

  String formatCurrencyInt(int? value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value ?? 0);
  }

  factory MonthlyReportSummary.fromJson(Map<String, dynamic> json) {
    return MonthlyReportSummary(
      // date: json['date'] != null ? DateTime.parse(json['date']) : null,
      totalSales: json['total_sales'],
      totalExpenses: json['total_expenses'],
      totalProfit: json['total_profit'],
      avgSales: (json['average_sales'] as num?)?.toDouble(),
      highestIncome: json['highest_income'] != null
          ? HighestIncome.fromJson(json['highest_income'])
          : null,
      lowestIncome: json['lowest_income'] != null
          ? LowestIncome.fromJson(json['lowest_income'])
          : null,
    );
  }
}

class HighestIncome {
  final int? amount;
  final DateTime? date;

  HighestIncome({
    this.amount,
    this.date
  });

  String get formattedDate {
    if (date == null) return '-';
    return DateFormat('MMMM yyyy', 'id_ID').format(date!);
  }

  factory HighestIncome.fromJson(Map<String, dynamic> json) {
    return HighestIncome(
      amount: json['amount'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

}

class LowestIncome {
  final int? amount;
  final DateTime? date;

  LowestIncome({
    this.amount,
    this.date
  });

  String get formattedDate {
    if (date == null) return '-';
    return DateFormat('MMMM yyyy', 'id_ID').format(date!);
  }

  factory LowestIncome.fromJson(Map<String, dynamic> json) {
    return LowestIncome(
      amount: json['amount'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }
}

class ReportSummaryData {
  final String title;
  final String value;
  final String? description;
  final Color color;
  final Color textColor;
  final IconData icon;

  ReportSummaryData({
    required this.title,
    required this.value,
    this.description,
    required this.color,
    required this.textColor,
    required this.icon,
  });
}