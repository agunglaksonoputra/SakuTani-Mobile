import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:saku_tani_mobile/models/user_balance.dart';
import 'package:saku_tani_mobile/models/withdraw_response.dart';
import 'dio_client.dart';
import 'logger_service.dart';

class ShareService {
  static Future<List<UserBalance>> getUserBalances() async {
    try {
      LoggerService.debug('Fetching user balances...');

      final res = await DioClient.dio.get('/user-balance');

      if (res.statusCode == 200) {
        final List<dynamic> data = res.data;
        LoggerService.debug('Successfully fetched ${data.length} user balances.');
        return data.map((item) => UserBalance.fromJson(item)).toList();
      } else {
        LoggerService.warning(
          'Failed to fetch user balances. Status: ${res.statusCode}, Body: ${res.data}',
        );
        throw Exception('Failed to load user balances');
      }
    } catch (e, stackTrace) {
      LoggerService.error('Exception while fetching user balances', error: e, stackTrace: stackTrace);
      throw Exception('Error fetching user balances: $e');
    }
  }

  static Future<List<WithdrawResponse>> getWithdrawLog({
    int page = 1,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (startDate != null) 'startDate': startDate.toIso8601String().split('T').first,
      if (endDate != null) 'endDate': endDate.toIso8601String().split('T').first,
    };

    try {
      LoggerService.debug("Fetching withdraw logs with query: $queryParams");

      final res = await DioClient.dio.get(
          '/withdraw',
          queryParameters: queryParams
      );

      final data = res.data;

      if (res.statusCode == 200) {
        final List<dynamic> rawWithdraw = data['data'] ?? [];
        final List<WithdrawResponse> withdraw = rawWithdraw
            .map((e) => WithdrawResponse.fromJson(e))
            .toList();
        LoggerService.debug("Successfully retrieved ${withdraw.length} withdraw logs.");
        return withdraw;
      } else {
        LoggerService.warning(
          "Failed to fetch withdraw logs. Status: ${res.statusCode}, Body: ${res.data}",
        );
        throw Exception('Failed to load withdraw log');
      }
    } catch (e, stackTrace) {
      LoggerService.error('Exception occurred while fetching withdraw logs', error: e, stackTrace: stackTrace);
      throw Exception('Error fetching withdraw log: $e');
    }
  }

  static Future<bool> createWithdrawTransaction(WithdrawResponse transaction) async {
    final dio = DioClient.dio;

    try {
      final response = await dio.post(
        '/withdraw',
        data: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        LoggerService.warning("Gagal membuat withdraw. Status: ${response.statusCode}");
        LoggerService.warning("Response body: ${response.data}");
        // print("Failed to create expenses transaction. Status code: ${response.statusCode}");
        // print("Response body: ${response.data}");

        try {
          final error = response.data;
          LoggerService.warning('Error message: ${error['message']}');
          // print('Error message: ${error['message']}');
        } catch (_) {
          LoggerService.warning('Unable to parse error response.');
          // print('Unable to parse error response.');
        }

        return false;
      }
    } catch (e, stackTrace) {
      LoggerService.error('Exception saat createWithdrawTransaction', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  static Future<void> softDeleteWithdrawTransaction(int id) async {
    final dio = DioClient.dio;

    try {
      LoggerService.debug('[WITHDRAW] Attempting to delete withdraw transaction ID: $id');

      final response = await dio.delete('/withdraw/$id');

      if (response.statusCode != 200) {
        final data = response.data;
        final msg = data['message'] ?? 'Unknown error';
        LoggerService.warning('[WITHDRAW] Failed to delete transaction: $msg');
        throw Exception('Failed to delete transaction: $msg');
      }

      LoggerService.info('[WITHDRAW] Transaction ID $id deleted successfully');
    } on DioException catch (e, stackTrace) {
      final msg = e.response?.data['message'] ?? e.message;
      LoggerService.error(
        '[WITHDRAW] DioException while deleting transaction',
        error: msg,
        stackTrace: stackTrace,
      );
      throw Exception('Delete transaction failed: $msg');
    } catch (e, stackTrace) {
      LoggerService.error(
        '[WITHDRAW] Unexpected error while deleting transaction',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Unexpected error while deleting transaction: $e');
    }
  }
}