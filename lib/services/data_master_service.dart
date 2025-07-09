import 'dio_client.dart';
import 'logger_service.dart';

class DataMasterService {
  /// Fetch master data options (customers, vegetables, units, owners)
  static Future<Map<String, List<String>>> fetchOptions() async {
    final dio = DioClient.dio;

    try {
      LoggerService.debug('[DATA_MASTER] Fetching master data options...');

      final response = await dio.get('/data-master');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          LoggerService.info('[DATA_MASTER] Options fetched successfully.');

          return {
            'customers': List<String>.from(data['customers'] ?? []),
            'vegetables': List<String>.from(data['vegetables'] ?? []),
            'units': List<String>.from(data['units'] ?? []),
            'owners': List<String>.from(data['owners'] ?? []),
          };
        } else {
          LoggerService.warning('[DATA_MASTER] Server responded with success = false');
          throw Exception('Server responded with success = false');
        }
      } else {
        LoggerService.error('[DATA_MASTER] Failed to fetch options. Status: ${response.statusCode}');
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      LoggerService.error('[DATA_MASTER] Exception occurred while fetching options.',
          error: e, stackTrace: stackTrace);
      throw Exception('An error occurred while fetching options: $e');
    }
  }
}