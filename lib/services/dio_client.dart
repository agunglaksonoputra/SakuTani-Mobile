import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

final String baseUrl =
    dotenv.env['BASE_URL_EMULATOR'] ?? dotenv.env['BASE_URL_DEVICE'] ?? '';

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
    _dio.interceptors.clear(); // Hindari double interceptor

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Token expired: hapus dan arahkan ke login
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('auth_token');

            print('⚠️ Token expired. Silakan login kembali.');

            // Arahkan ke login (jika navigatorKey digunakan)
            final context = navigatorKey.currentContext;
            if (context != null) {
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/login',
                    (route) => false,
              );
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}