import 'dart:convert';
import 'package:saku_tani_mobile/models/expenses_transaction.dart';
import '../models/expenses_response.dart';
import 'dio_client.dart';
import 'logger_service.dart';

class ExpensesServices {
  /// Fetch expenses transactions with optional filters
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
      LoggerService.debug('[EXPENSES] Fetching expenses with query: $queryParams');

      final response = await dio.get(
        '/expenses',
        queryParameters: queryParams,
      );

      LoggerService.info('[EXPENSES] Expenses fetched successfully.');
      return ExpensesResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      LoggerService.error('[EXPENSES] Failed to fetch expenses.', error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch expenses: $e');
    }
  }

  /// Create a new expense transaction
  static Future<bool> createExpensesTransaction(ExpensesTransaction transaction) async {
    final dio = DioClient.dio;

    try {
      LoggerService.debug('[EXPENSES] Creating transaction: ${transaction.toJson()}');

      final response = await dio.post(
        '/expenses',
        data: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 201) {
        LoggerService.info('[EXPENSES] Transaction created successfully.');
        return true;
      } else {
        LoggerService.warning('[EXPENSES] Failed to create transaction. Status: ${response.statusCode}');
        LoggerService.debug('Response: ${response.data}');

        try {
          final error = response.data;
          LoggerService.error('Server message: ${error['message']}');
        } catch (_) {
          LoggerService.warning('Unable to parse error response from server.');
        }

        return false;
      }
    } catch (e, stackTrace) {
      LoggerService.error('[EXPENSES] Exception occurred during transaction creation.', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Soft delete an expense transaction by ID
  static Future<void> softDeleteExpensesTransaction(int id) async {
    final dio = DioClient.dio;

    try {
      LoggerService.debug('[EXPENSES] Attempting to delete transaction with ID: $id');

      final response = await dio.delete('/expenses/$id');

      if (response.statusCode == 200) {
        LoggerService.info('[EXPENSES] Transaction deleted successfully.');
      } else {
        final message = response.data['message'] ?? 'Unknown error';
        LoggerService.error('[EXPENSES] Failed to delete transaction. Message: $message');
        throw Exception('Failed to delete transaction: $message');
      }
    } catch (e, stackTrace) {
      LoggerService.error('[EXPENSES] Exception occurred during deletion.', error: e, stackTrace: stackTrace);
      throw Exception('Failed to delete transaction: $e');
    }
  }
}
