import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../data/services/auth_service.dart';
import '../data/models/user_model.dart';
import '../../../shared/widgets/global_loading.dart';
import '../../../shared/widgets/global_toast.dart' hide GlobalLoading;

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  UserModel? _user;
  bool _isLoading = false;
  bool _initialized = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> login(
    String email,
    String password, {
    BuildContext? context,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Show global loading
    if (context != null) {
      GlobalLoading.show(context, message: 'Signing in...');
    }

    try {
      _user = await _authService.login(email, password);
      if (_user?.token != null) {
        // Save token to secure storage
        await _storage.write(key: 'jwt_token', value: _user!.token);
      }
    } catch (e) {
      if (context != null) {
        context.showErrorToast(_extractErrorMessage(e));
      }
      rethrow;
    } finally {
      _isLoading = false;
      // Hide global loading
      if (context != null) {
        GlobalLoading.hide();
      }
      notifyListeners();
    }
  }

  Future<void> register(
    String name,
    String email,
    String password, {
    BuildContext? context,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Show global loading
    if (context != null) {
      GlobalLoading.show(context, message: 'Creating account...');
    }

    try {
      _user = await _authService.register(name, email, password);
      if (_user?.token != null) {
        await _storage.write(key: 'jwt_token', value: _user!.token);
      }
    } catch (e) {
      if (context != null) {
        context.showErrorToast(_extractErrorMessage(e));
      }
      rethrow;
    } finally {
      _isLoading = false;
      // Hide global loading
      if (context != null) {
        GlobalLoading.hide();
      }
      notifyListeners();
    }
  }

  Future<void> logout({BuildContext? context}) async {
    // Show global loading
    if (context != null) {
      GlobalLoading.show(context, message: 'Signing out...');
    }

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

    // Hide global loading
    if (context != null) {
      GlobalLoading.hide();
    }

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

  String _extractErrorMessage(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == 401) {
        return "Invalid email or password";
      }
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (data is String && data.trim().isNotEmpty) {
        return data;
      }
      if (error.message != null && error.message!.trim().isNotEmpty) {
        return error.message!;
      }
    }
    return "Something went wrong. Please try again.";
  }
}
