import 'dart:convert';
import 'package:saku_tani_mobile/models/user_balance_response.dart';
import 'dio_client.dart';

class ShareService {
  static Future<UserBalanceResponse> getUserBalances() async {
    try {
      final res = await DioClient.dio.get('/profit-share/balance');

      if (res.statusCode == 200) {
        final data = res.data;
        return UserBalanceResponse.fromJson(data);
      } else {
        throw Exception('Failed to load user balances');
      }
    } catch (e) {
      throw Exception('Error fetching user balances: $e');
    }
  }
}