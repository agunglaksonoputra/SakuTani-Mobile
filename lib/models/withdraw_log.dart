import 'package:intl/intl.dart';

class WithdrawLog {
  final int? id;
  final String? userName;
  final double? amount;
  final DateTime? date;
  // final String notes;

  WithdrawLog({
    this.id,
    this.userName,
    this.amount,
    this.date,
    // required this.notes,
  });

  String get formattedDate {
    if (date == null) return '-';
    return DateFormat('d MMMM yyyy', 'id_ID').format(date!);
  }

  String formatCurrency(double? value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value ?? 0);
  }

  factory WithdrawLog.fromJson(Map<String, dynamic> json) {
    return WithdrawLog(
      id: json['id'],
      userName: json['name'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      // notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': userName,
      'amount': amount,
      // 'notes': notes,
    };
  }
}
