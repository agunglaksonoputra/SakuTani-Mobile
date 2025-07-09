import 'package:intl/intl.dart';

class UserBalance {
  final String name;
  final double balance;

  UserBalance({
    required this.name,
    required this.balance,
  });

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

  factory UserBalance.fromJson(Map<String, dynamic> json) {
    return UserBalance(
      name: json['name'],
      balance: double.parse(json['balance'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'balance': balance,
    };
  }
}