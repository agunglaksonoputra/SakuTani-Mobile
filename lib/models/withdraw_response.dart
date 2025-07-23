import 'package:intl/intl.dart';
import 'package:saku_tani_mobile/models/withdraw_log.dart';

class WithdrawResponse {
  final String? month;
  final double? totalAmount;
  final List<WithdrawLog>? withdrawLog;

  WithdrawResponse({
    this.month,
    this.totalAmount,
    this.withdrawLog
  });

  String formatCurrency(double? value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value ?? 0);
  }

  String get formattedDate {
    if (month == null) return '-';
    DateTime parsedDate = DateTime.parse("${month!}-01");
    String formatted = DateFormat("MMMM yyyy", 'id_ID').format(parsedDate);
    return formatted;
  }

  factory WithdrawResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawResponse(
      month: json['month'],
      totalAmount: double.tryParse(json['totalAmount']),
      withdrawLog: (json['data'] as List)
          .map((item) => WithdrawLog.fromJson(item))
          .toList(),
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'name': name,
  //     'amount': amount,
  //   };
  // }
}