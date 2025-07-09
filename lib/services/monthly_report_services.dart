import 'package:saku_tani_mobile/models/monthly_combine_response.dart';
import 'package:saku_tani_mobile/models/monthly_report_response.dart';

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
}