import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/app_routes.dart';

/// Determine the base URL (either from emulator or device config)
final String baseUrl = (() {
  final emulator = dotenv.env['BASE_URL_EMULATOR'];
  final device = dotenv.env['BASE_URL_DEVICE'];
  final test = dotenv.env['BASE_URL_TEST'];
  final production =  dotenv.env['BASE_URL'];
  final selected = emulator ?? device ?? test ?? production ?? '';
  final url = selected.endsWith('/') ? selected : '$selected/';

  debugPrint('Base URL: $url');
  return url;
})();


class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  /// Optional: Use this for global navigation (e.g., redirect on 401)
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Public getter to access Dio instance
  static Dio get dio => _dio;

  /// Initialize Dio with interceptors (e.g., for auth header, error handling)
  static Future<void> initialize() async {
    _dio.interceptors.clear();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Don't attach token for login and register
          final excludedPaths = ['/auth/login', '/auth/register'];

          if (!excludedPaths.any((path) => options.path.contains(path))) {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');

            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          return handler.next(options);
        },
          onError: (DioException e, handler) async {
            final statusCode = e.response?.statusCode;

            if (statusCode == 401 || statusCode == 403) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');

              final context = DioClient.navigatorKey.currentContext;
              if (context != null) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                      (route) => false,
                );
              }
            }

            return handler.next(e);
          }
      ),
    );
  }
}