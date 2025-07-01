import 'dart:convert';
import 'package:saku_tani_mobile/models/expenses_transaction.dart';

import '../models/expenses_response.dart';
import 'dio_client.dart';

class ExpensesServices {
  static Future<ExpensesResponse> fetchExpenses({
    int page = 1,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dio = DioClient.dio;

    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (startDate != null) 'startDate': startDate.toIso8601String().split('T').first,
      if (endDate != null) 'endDate': endDate.toIso8601String().split('T').first,
    };

    try {
      final response = await dio.get(
        '/expenses',
        queryParameters: queryParams,
      );

      final data = response.data;
      final List<ExpensesTransaction> expenses = (data['data'] as List)
          .map((e) => ExpensesTransaction.fromJson(e))
          .toList();

      final int totalAmount = data['total_amount'] ?? 0;

      return ExpensesResponse(
        expenses: expenses,
        totalAmount: totalAmount,
      );
    } catch (e) {
      throw Exception('Gagal mengambil data sales: $e');
    }
  }

  static Future<bool> createExpensesTransaction(ExpensesTransaction transaction) async {
    final dio = DioClient.dio;

    try {
      final response = await dio.post(
        '/expenses/',
        data: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Failed to create expenses transaction. Status code: ${response.statusCode}");
        print("Response body: ${response.data}");

        try {
          final error = response.data;
          print('Error message: ${error['message']}');
        } catch (_) {
          print('Unable to parse error response.');
        }

        return false;
      }
    } catch (e) {
      print('Exception saat createSalesTransaction: $e');
      return false;
    }
  }


  static Future<void> softDeleteExpensesTransaction(int id) async {
    final dio = DioClient.dio;

    try {
      final response = await dio.put('/expenses/soft-delete/$id');

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception('Gagal menghapus transaksi: ${data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Gagal menghapus transaksi: $e');
    }
  }
}