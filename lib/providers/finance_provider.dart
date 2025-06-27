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
  final String status;
  final double amount;
  final String date;

  ProfitShareData({
    required this.name,
    required this.status,
    required this.amount,
    required this.date,
  });
}

class CashflowData {
  final String date;
  final double income;
  final double expense;

  CashflowData({
    required this.date,
    required this.income,
    required this.expense,
  });
}

class FinanceProvider with ChangeNotifier {
  List<FinanceData> _financeCards = [
    FinanceData(
      title: 'Saldo Usaha',
      amount: 1000000,
      color: Color(0xFF4CAF50),
    ),
    FinanceData(
      title: 'Profit Bulan Ini',
      amount: 1000000,
      color: Color(0xFF4CAF50),
    ),
    FinanceData(
      title: 'Pendapatan',
      amount: 3500000,
      color: Color(0xFF9C27B0),
    ),
    FinanceData(
      title: 'Pengeluaran',
      amount: 1500000,
      color: Color(0xFFE91E63),
    ),
  ];

  List<ProfitShareData> _profitShares = [
    ProfitShareData(
      name: 'Joko',
      status: 'Bagi Hasil Tersedia',
      amount: 264973,
      date: '1 Juni 2025',
    ),
    ProfitShareData(
      name: 'Pardi',
      status: 'Bagi Hasil Tersedia',
      amount: 264973,
      date: '1 Juni 2025',
    ),
    ProfitShareData(
      name: 'Zakat',
      status: 'Bagi Hasil Tersedia',
      amount: 857082,
      date: '1 Juni 2025',
    ),
  ];

  List<CashflowData> _cashflowData = [
    CashflowData(date: '1 May', income: 250000, expense: 100000),
    CashflowData(date: '2 May', income: 300000, expense: 150000),
    CashflowData(date: '3 May', income: 280000, expense: 120000),
    CashflowData(date: '4 May', income: 320000, expense: 180000),
    CashflowData(date: '5 May', income: 400000, expense: 200000),
    CashflowData(date: '6 May', income: 350000, expense: 170000),
    CashflowData(date: '7 May', income: 300000, expense: 140000),
    // Add more data points...
  ];

  Map<String, List<Map<String, dynamic>>> _monthlyData = {
    'Pendapatan Bulan Ini': [
      {'name': 'Kangkung', 'amount': 200000},
      {'name': 'Bayam', 'amount': 200000},
      {'name': 'Selada', 'amount': 200000},
      {'name': 'Pokcoy', 'amount': 200000},
    ],
    'Pengeluaran Bulan Ini': [
      {'name': 'Nutrisi & Pupuk', 'amount': 200000},
      {'name': 'Bayam', 'amount': 200000},
      {'name': 'Selada', 'amount': 200000},
      {'name': 'Pokcoy', 'amount': 200000},
    ],
  };

  List<FinanceData> get financeCards => _financeCards;
  List<ProfitShareData> get profitShares => _profitShares;
  List<CashflowData> get cashflowData => _cashflowData;
  Map<String, List<Map<String, dynamic>>> get monthlyData => _monthlyData;

  void updateFinanceData() {
    // Update logic here
    notifyListeners();
  }
}