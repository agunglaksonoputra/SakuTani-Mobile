import 'package:dio/dio.dart';
import '../models/sale_transaction.dart';
import '../models/sales_response.dart';
import 'dio_client.dart';
import '../services/logger_service.dart';

class SalesService {
  static Future<SalesResponse> fetchSales({
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
      LoggerService.debug('[SALES] Fetching sales with query: $queryParams');

      final response = await dio.get(
        '/sales',
        queryParameters: queryParams,
      );

      final data = response.data;
      final List<dynamic> rawSales = data['data'] ?? [];
      final List<SaleTransaction> sales =
      rawSales.map((e) => SaleTransaction.fromJson(e)).toList();

      final int totalPrice = int.tryParse(data['totalPrice']?.toString() ?? '0') ?? 0;
      final double totalWeightKg = double.tryParse(data['totalWeightKg']?.toString() ?? '0') ?? 0.0;

      LoggerService.info('[SALES] Successfully fetched ${sales.length} transactions');

      return SalesResponse(
        sales: sales,
        totalPrice: totalPrice,
        totalWeightKg: totalWeightKg,
      );
    } on DioException catch (e, stackTrace) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data?['message'] ?? e.message;

      LoggerService.error(
        '[SALES] Failed to fetch sales data',
        error: 'Status $statusCode: $message',
        stackTrace: stackTrace,
      );

      throw Exception('Failed to fetch sales data (Status $statusCode): $message');
    } catch (e, stackTrace) {
      LoggerService.error(
        '[SALES] Unexpected error while fetching sales',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Unexpected error while fetching sales data: $e');
    }
  }

  static Future<void> softDeleteSaleTransaction(int id) async {
    final dio = DioClient.dio;

    try {
      LoggerService.debug('[SALES] Attempting to delete sale transaction ID: $id');

      final response = await dio.delete('/sales/$id');

      if (response.statusCode != 200) {
        final data = response.data;
        final msg = data['message'] ?? 'Unknown error';
        LoggerService.warning('[SALES] Failed to delete transaction: $msg');
        throw Exception('Failed to delete transaction: $msg');
      }

      LoggerService.info('[SALES] Transaction ID $id deleted successfully');
    } on DioException catch (e, stackTrace) {
      final msg = e.response?.data['message'] ?? e.message;
      LoggerService.error(
        '[SALES] DioException while deleting transaction',
        error: msg,
        stackTrace: stackTrace,
      );
      throw Exception('Delete transaction failed: $msg');
    } catch (e, stackTrace) {
      LoggerService.error(
        '[SALES] Unexpected error while deleting transaction',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Unexpected error while deleting transaction: $e');
    }
  }

  static Future<bool> createSalesTransaction(SaleTransaction transaction) async {
    final dio = DioClient.dio;

    try {
      LoggerService.debug('[SALES] Creating sales transaction with payload: ${transaction.toJson()}');

      final response = await dio.post(
        '/sales/',
        data: transaction.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        LoggerService.info('[SALES] Transaction created successfully');
        return true;
      } else {
        LoggerService.warning(
          '[SALES] Failed to create transaction. Status: ${response.statusCode}, Body: ${response.data}',
        );
        return false;
      }
    } on DioException catch (e, stackTrace) {
      LoggerService.error(
        '[SALES] DioException while creating transaction',
        error: e.response?.data ?? e.message,
        stackTrace: stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      LoggerService.error(
        '[SALES] Unexpected error while creating transaction',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
