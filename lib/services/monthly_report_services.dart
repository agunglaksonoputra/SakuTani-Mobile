import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saku_tani_mobile/models/monthly_combine_response.dart';
import 'package:saku_tani_mobile/models/monthly_report_response.dart';
import 'package:saku_tani_mobile/models/monthly_report_summary.dart';
import '../helper/permission_handler.dart';
import 'dio_client.dart';
import 'logger_service.dart';

class MonthlyReportServices {

  final dio = DioClient.dio;

  static Future<List<MonthlyReportResponse>> fetchMonthly() async {
    try {
      final res = await DioClient.dio.get('report/');
      final data = res.data['data'] as List;
      LoggerService.info('[FINANCE] Fetched monthly report breakdown');
      return data.map((item) => MonthlyReportResponse.fromJson(item)).toList();
    } catch (e) {
      LoggerService.error('[FINANCE] Failed to fetch monthly report breakdown', error: e);
      throw Exception("Failed to load monthly report breakdown: $e");
    }
  }

  static Future<MonthlyCombinedResponse> fetchMonthlyCombined(int id) async {
    try {
      final res = await DioClient.dio.get('/report/$id/details');
      final data = res.data;

      LoggerService.info('[SERVICE] Fetched monthly sales & expenses');

      return MonthlyCombinedResponse.fromJson(data);
    } catch (e, stackTrace) {
      LoggerService.error('[SERVICE] Failed to fetch monthly data', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<String> downloadExcelReport() async {
    try {
      // ✅ Minta izin storage (Android 11+ dan di bawahnya)
      await requestStoragePermissions();

      // ✅ Tentukan direktori /Download
      Directory directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory(); // untuk iOS
      }

      final now = DateTime.now();
      final filename = 'Laporan Bisnis Sayur ${now.year}-${now.month.toString().padLeft(2, '0')}.xlsx';
      final filePath = '${directory.path}/$filename';

      // ✅ Ambil data dari API
      final response = await DioClient.dio.get<List<int>>(
        '/excel/export',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      // ✅ Tulis ke file
      final file = File(filePath);
      await file.writeAsBytes(response.data!);

      LoggerService.info('[SERVICE] Report file successfully saved at: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      LoggerService.error('[SERVICE] Failed to download report file', error: e, stackTrace: stackTrace);
      throw Exception("Failed to download report: $e");
    }
  }

  static Future<MonthlyReportSummary> fetchMonthlySummary() async {
    try {
      final res = await DioClient.dio.get('v2/report/summary');
      final data = res.data;
      LoggerService.info('[FINANCE] Fetched monthly report summary');
      return MonthlyReportSummary.fromJson(data);
    } catch (e) {
      LoggerService.error('[FINANCE] Failed to fetch monthly report summary', error: e);
      throw Exception("Failed to load monthly report summary: $e");
    }
  }

}