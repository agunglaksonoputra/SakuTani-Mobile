import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isLoading = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController validationController = TextEditingController();

  String? get token => _token;
  bool get isLoading => _isLoading;

  /// Inisialisasi token dari penyimpanan
  Future<void> loadToken() async {
    try {
      final user = await AuthService.verifyToken(); // akan throw jika tidak valid
      _token = user['token']; // simpan ulang jika perlu
      debugPrint("Token valid. User: ${user['username']}");
    } catch (e) {
      _token = null;
      debugPrint("Gagal load token: $e");
    }
    notifyListeners();
  }

  /// Login dan simpan token
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _token = await AuthService.login(username, password);
      usernameController.clear();
      passwordController.clear();
      return true;
    } catch (e) {
      _token = null;
      debugPrint("Login error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register user baru
  Future<bool> register() async {
    _isLoading = true;
    notifyListeners();
    try {
      await AuthService.register(
        usernameController.text,
        passwordController.text,
        validationController.text,
      );
      usernameController.clear();
      passwordController.clear();
      validationController.clear();
      return true;
    } catch (e) {
      debugPrint("Register error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cek validitas token
  Future<bool> checkTokenValid() async {
    try {
      final user = await AuthService.verifyToken();
      debugPrint("Token valid. Logged in as: ${user['username']}");
      return true;
    } catch (e) {
      debugPrint("Token tidak valid: $e");
      _token = null;
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await AuthService.logout();
    _token = null;
    notifyListeners();
  }

  void disposeControllers() {
    usernameController.dispose();
    passwordController.dispose();
    validationController.dispose();
  }
}