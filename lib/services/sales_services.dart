import 'dart:convert';
import '../models/sale_transaction.dart';
import '../models/sales_response.dart';
import 'dio_client.dart';

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
      final response = await dio.get(
        '/sales',
        queryParameters: queryParams,
      );

      final data = response.data;
      final List<SaleTransaction> sales = (data['data'] as List)
          .map((e) => SaleTransaction.fromJson(e))
          .toList();

      final int totalPrice = data['total_price'] ?? 0;
      final double totalWeightKg = (data['total_weight_kg'] ?? 0).toDouble();

      return SalesResponse(
        sales: sales,
        totalPrice: totalPrice,
        totalWeightKg: totalWeightKg,
      );
    } catch (e) {
      throw Exception('Gagal mengambil data sales: $e');
    }
  }

  static Future<void> softDeleteSaleTransaction(int id) async {
    final dio = DioClient.dio;

    try {
      final response = await dio.put('/sales/soft-delete/$id');

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception('Gagal menghapus transaksi: ${data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Gagal menghapus transaksi: $e');
    }
  }

  static Future<bool> createSalesTransaction(SaleTransaction transaction) async {
    final dio = DioClient.dio;

    try {
      final response = await dio.post(
        '/sales/',
        data: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Failed to create sales transaction. Status code: ${response.statusCode}");
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
}
