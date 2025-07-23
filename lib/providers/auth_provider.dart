import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_services.dart';
import '../services/logger_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _role;
  bool _isLoading = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController validationController = TextEditingController();

  String? get token => _token;
  String? get role => _role;
  bool get isLoading => _isLoading;

  /// Load token and role from local storage and verify
  Future<void> loadToken() async {
    try {
      final user = await AuthService.verifyToken();
      _token = user['token'];
      _role = user['role'];
      LoggerService.info('[AUTH] Token valid. Logged in as ${user['username']} with role $_role');
    } catch (e, st) {
      _token = null;
      _role = null;
      LoggerService.error('[AUTH] Failed to load token.', error: e, stackTrace: st);
    }
    notifyListeners();
  }

  /// Perform login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.debug('[AUTH] Attempting login for user: $username');
      final result = await AuthService.login(username, password);
      _token = result['token'];
      _role = result['role'];
      usernameController.clear();
      passwordController.clear();
      LoggerService.info('[AUTH] Login successful. Role: $_role');
      return true;
    } catch (e, st) {
      _token = null;
      _role = null;
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

  /// Check token validity
  Future<bool> checkTokenValid() async {
    try {
      final user = await AuthService.verifyToken();
      _token = user['token'];
      _role = user['role'];
      LoggerService.info('[AUTH] Token is valid. User: ${user['username']}, Role: $_role');
      return true;
    } catch (e, st) {
      _token = null;
      _role = null;
      LoggerService.error('[AUTH] Invalid token.', error: e, stackTrace: st);
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    LoggerService.info('[AUTH] Logging out...');
    await AuthService.logout();
    _token = null;
    _role = null;
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
