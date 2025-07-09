import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import '../services/logger_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isLoading = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController validationController = TextEditingController();

  String? get token => _token;
  bool get isLoading => _isLoading;

  /// Load token from local storage and verify its validity
  Future<void> loadToken() async {
    try {
      final user = await AuthService.verifyToken();
      _token = user['token'];
      LoggerService.info('[AUTH] Token is valid. Logged in as: ${user['username']}');
    } catch (e, st) {
      _token = null;
      LoggerService.error('[AUTH] Failed to load token.', error: e, stackTrace: st);
    }
    notifyListeners();
  }

  /// Perform login and store token
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.debug('[AUTH] Attempting login for user: $username');
      _token = await AuthService.login(username, password);
      usernameController.clear();
      passwordController.clear();
      LoggerService.info('[AUTH] Login successful.');
      return true;
    } catch (e, st) {
      _token = null;
      LoggerService.error('[AUTH] Login failed.', error: e, stackTrace: st);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new user
  Future<bool> register() async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.debug('[AUTH] Registering new user: ${usernameController.text}');
      await AuthService.register(
        usernameController.text,
        passwordController.text,
        validationController.text,
      );
      usernameController.clear();
      passwordController.clear();
      validationController.clear();
      LoggerService.info('[AUTH] Registration successful.');
      return true;
    } catch (e, st) {
      LoggerService.error('[AUTH] Registration failed.', error: e, stackTrace: st);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if token is still valid
  Future<bool> checkTokenValid() async {
    try {
      final user = await AuthService.verifyToken();
      LoggerService.info('[AUTH] Token is valid. Logged in as: ${user['username']}');
      return true;
    } catch (e, st) {
      _token = null;
      LoggerService.error('[AUTH] Invalid token.', error: e, stackTrace: st);
      return false;
    }
  }

  /// Logout and clear token
  Future<void> logout() async {
    LoggerService.info('[AUTH] Logging out...');
    await AuthService.logout();
    _token = null;
    notifyListeners();
    LoggerService.info('[AUTH] Logout successful.');
  }

  /// Dispose text controllers
  void disposeControllers() {
    usernameController.dispose();
    passwordController.dispose();
    validationController.dispose();
    LoggerService.debug('[AUTH] Text controllers disposed.');
  }
}