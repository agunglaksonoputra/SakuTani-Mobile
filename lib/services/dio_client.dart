import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:saku_tani_mobile/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

final String baseUrl = (() {
  final emulator = dotenv.env['BASE_URL_EMULATOR'];
  final device = dotenv.env['BASE_URL_DEVICE'];
  final selected = emulator ?? device ?? '';
  return selected.endsWith('/') ? selected : '$selected/';
})();

class DioClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static Dio get dio => _dio;

  static Future<void> initialize() async {
    _dio.interceptors.clear(); // Clear dulu

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final excludedPaths = ['/auth/login', '/auth/register'];

          if (!excludedPaths.any((path) => options.path.contains(path))) {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');

            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
              print('[AUTH] Header injected: Bearer $token');
            }
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('auth_token');
            print('⚠️ Token expired, removed');

            // Jika ingin redirect ke login, tambahkan navigatorKey seperti sebelumnya
          }
          return handler.next(e);
        },
      ),
    );
  }
}