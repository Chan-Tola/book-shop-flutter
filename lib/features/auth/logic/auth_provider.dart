import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/services/auth_service.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  UserModel? _user;
  bool _isLoading = false;
  bool _initialized = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
      if (_user?.token != null) {
        // Save token to secure storage
        await _storage.write(key: 'jwt_token', value: _user!.token);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.register(name, email, password);
      if (_user?.token != null) {
        await _storage.write(key: 'jwt_token', value: _user!.token);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null && token.isNotEmpty) {
      try {
        await _authService.logout(token);
      } catch (_) {
        // Ignore API logout failures; still clear local session.
      }
    }
    await _storage.delete(key: 'jwt_token');
    _user = null;
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    if (_initialized) return;
    _initialized = true;

    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      _user = await _authService.getMe(token);
    } catch (_) {
      await _storage.delete(key: 'jwt_token');
      _user = null;
    } finally {
      notifyListeners();
    }
  }
}
