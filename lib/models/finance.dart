import 'package:flutter/material.dart';

class FinanceData {
  final String title;
  final double amount;
  final Color color;

  FinanceData({
    required this.title,
    required this.amount,
    required this.color,
  });
}

class ProfitShareData {
  final String name;
  final double amount;

  ProfitShareData({
    required this.name,
    required this.amount,
  });
}


class CashflowData {
  final double income;
  final double expense;
  final String label;

  CashflowData({
    required this.income,
    required this.expense,
    required this.label,
  });
}

class MonthlySummary {
  final DateTime date;
  final double totalSales;
  final double totalExpenses;

  MonthlySummary({
    required this.date,
    required this.totalSales,
    required this.totalExpenses,
  });

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      date: DateTime.parse(json['date']), // fix: parse dari String ke DateTime
      totalSales: double.tryParse(json['total_sales'].toString()) ?? 0,
      totalExpenses: double.tryParse(json['total_expenses'].toString()) ?? 0,
    );
  }
}




