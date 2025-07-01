import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dio_client.dart';

final String baseUrl = dotenv.env['BASE_URL_EMULATOR'] ?? dotenv.env['BASE_URL_DEVICE'] ?? '';

class AuthService {
  /// Login user dan simpan token
  static Future<String> login(String username, String password) async {
    try {
      final response = await DioClient.dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      print('[DEBUG] Base URL: $baseUrl');

      final data = response.data;
      final token = data['token'];

      if (response.statusCode == 200 && data['success'] == true && token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        print('[LOGIN] Token disimpan: $token');

        // Refresh header dio dengan token baru
        await DioClient.initialize();

        return token;
      } else {
        throw Exception("Login gagal: ${data['message'] ?? 'Unknown error'}");
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? e.message;
      throw Exception('[ERROR] Login gagal: $errorMessage');
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
        throw Exception("Register gagal: ${data['message']}");
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message;
      throw Exception("Register error: $msg");
    }
  }

  /// Verifikasi token yang tersimpan
  static Future<Map<String, dynamic>> verifyToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception("Tidak ada token tersimpan.");
    }

    try {
      final response = await DioClient.dio.get('/auth/verify');

      final data = response.data;
      if (response.statusCode == 200 && data['success'] == true) {
        return data['user'];
      } else {
        throw Exception("Token tidak valid: ${data['message']}");
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message;
      throw Exception("Verifikasi token gagal: $msg");
    }
  }

  /// Logout: hapus token
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await DioClient.initialize();
    print("[LOGOUT] Token dihapus");
  }
}
