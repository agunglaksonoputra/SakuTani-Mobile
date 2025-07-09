import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dio_client.dart';
import 'logger_service.dart';

class AuthService {
  /// Login user dan simpan token
  static Future<String> login(String username, String password) async {
    try {
      final response = await DioClient.dio.post('/auth/login/', data: {
        'username': username,
        'password': password,
      });

      final data = response.data;
      final token = data['token'];

      if (response.statusCode == 200 && data['success'] == true && token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await DioClient.initialize();

        LoggerService.info('[LOGIN] Login successful. Token stored.');

        return token;
      } else {
        final message = data['message'] ?? 'Unknown error';
        LoggerService.warning('[LOGIN] Login failed: $message');
        throw Exception("Login gagal: ${data['message'] ?? 'Unknown error'}");
      }
    } on DioException catch (e, stackTrace) {
      final errorMessage = e.response?.data['message'] ?? e.message;
      LoggerService.error('[LOGIN] DioException occurred', error: errorMessage, stackTrace: stackTrace);
      throw Exception('[LOGIN] Login failed: $errorMessage');
    } catch (e, stackTrace) {
      LoggerService.error('[LOGIN] Unexpected error', error: e, stackTrace: stackTrace);
      throw Exception('[LOGIN] Unexpected error: $e');
    }
  }

  /// Register user baru
  static Future<void> register(String username, String password, String validationCode) async {
    try {
      final response = await DioClient.dio.post('/register', data: {
        'username': username,
        'password': password,
        'validationCode': validationCode,
      });

      if (response.statusCode != 200) {
        final data = response.data;
        final msg = data['message'] ?? 'Unknown error';

        LoggerService.warning('[REGISTER] Registration failed: $msg');

        throw Exception("Register gagal: ${data['message']}");
      }

      LoggerService.info('[REGISTER] User registered successfully.');
    } on DioException catch (e, stackTrace) {
      final msg = e.response?.data['message'] ?? e.message;
      LoggerService.error('[REGISTER] DioException during registration', error: msg, stackTrace: stackTrace);
      throw Exception("Registration error: $msg");
    } catch (e, stackTrace) {
      LoggerService.error('[REGISTER] Unexpected error', error: e, stackTrace: stackTrace);
      throw Exception("Unexpected registration error: $e");
    }
  }

  /// Verifikasi token yang tersimpan
  static Future<Map<String, dynamic>> verifyToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      LoggerService.warning('[TOKEN] No token found in local storage.');
      throw Exception("Tidak ada token tersimpan.");
    }

    try {
      final response = await DioClient.dio.get('/auth/verify');

      final data = response.data;
      if (response.statusCode == 200 && data['success'] == true) {
        LoggerService.info('[TOKEN] Token verification successful.');
        return data['user'];
      } else {
        final msg = data['message'] ?? 'Invalid token';
        LoggerService.warning('[TOKEN] Token verification failed: $msg');
        throw Exception("Token tidak valid: ${data['message']}");
      }
    } on DioException catch (e, stackTrace) {
      final msg = e.response?.data['message'] ?? e.message;
      LoggerService.error('[TOKEN] DioException during token verification', error: msg, stackTrace: stackTrace);
      throw Exception("Token verification error: $msg");
    } catch (e, stackTrace) {
      LoggerService.error('[TOKEN] Unexpected error during token verification', error: e, stackTrace: stackTrace);
      throw Exception("Unexpected token verification error: $e");
    }
  }

  /// Logout: hapus token
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await DioClient.initialize();
    LoggerService.info('[LOGOUT] Token removed from local storage.');
  }
}
