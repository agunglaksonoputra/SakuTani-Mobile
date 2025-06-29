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
  final String date;

  ProfitShareData({
    required this.name,
    required this.amount,
    required this.date,
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

class WeeklySummary {
  final String weekEnd;
  final double totalSales;
  final double totalExpenses;

  WeeklySummary({
    required this.weekEnd,
    required this.totalSales,
    required this.totalExpenses,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    return WeeklySummary(
      weekEnd: json['week_end'],
      totalSales: (json['total_sales'] as num).toDouble(),
      totalExpenses: (json['total_expenses'] as num).toDouble(),
    );
  }
}

