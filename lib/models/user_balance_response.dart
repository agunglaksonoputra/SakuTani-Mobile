import 'package:saku_tani_mobile/models/user_balance.dart';

class UserBalanceResponse {
  final double totalBalance;
  final List<UserBalance> data;

  UserBalanceResponse({
    required this.totalBalance,
    required this.data,
  });

  factory UserBalanceResponse.fromJson(Map<String, dynamic> json) {
    return UserBalanceResponse(
      totalBalance: json['total_balance'].toDouble(),
      data: (json['data'] as List)
          .map((item) => UserBalance.fromJson(item))
          .toList(),
    );
  }
}