import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/sale_transaction.dart';
import '../models/sales_response.dart';

final String baseUrl = dotenv.env['BASE_URL_EMULATOR'] ?? dotenv.env['BASE_URL_DEVICE'] ?? '';

class SalesService {
  static Future<SalesResponse> fetchSales({
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

    final uri = Uri.parse('$baseUrl/sales?').replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);

      final List<SaleTransaction> sales = (jsonBody['data'] as List)
          .map((e) => SaleTransaction.fromJson(e))
          .toList();

      final int totalPrice = jsonBody['total_price'] ?? 0;
      final double totalWeightKg = (jsonBody['total_weight_kg'] ?? 0).toDouble();

      return SalesResponse(
        sales: sales,
        totalPrice: totalPrice,
        totalWeightKg: totalWeightKg,
      );
    } else {
      throw Exception('Gagal mengambil data sales (Status ${response.statusCode})');
    }
  }

  static Future<void> softDeleteSaleTransaction(int id) async {
    final uri = Uri.parse('$baseUrl/sales/soft-delete/$id');

    final response = await http.put(uri);

    if (response.statusCode != 200) {
      // Coba print dulu untuk debugging
      print("Response body: ${response.body}");

      // Cek apakah response body bisa didecode jadi JSON
      try {
        final error = json.decode(response.body);
        throw Exception('Gagal menghapus transaksi: ${error['message']}');
      } catch (e) {
        // Fallback jika response bukan JSON
        throw Exception('Gagal menghapus transaksi: ${response.body}');
      }
    }
  }

  static Future<bool> createSalesTransaction(SaleTransaction transaction) async {
    final uri = Uri.parse('$baseUrl/sales/');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(transaction.toJson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("Failed to create sales transaction. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      try {
        final error = json.decode(response.body);
        print('Error message: ${error['message']}');
      } catch (_) {
        print('Unable to parse error response.');
      }

      return false;
    }
  }
}
