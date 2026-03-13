import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  UserModel _parseUser(dynamic root, {String? tokenOverride}) {
    if (root is! Map) {
      throw Exception('Unexpected response: ${root.runtimeType}');
    }

    final dynamic dataNode = root['data'] is Map ? root['data'] : root;
    if (dataNode is! Map) {
      throw Exception('Unexpected response shape: ${dataNode.runtimeType}');
    }

    final dynamic userData = dataNode['user'];
    final dynamic token = dataNode['token'] ?? tokenOverride;

    if (userData is Map) {
      return UserModel.fromJson(
        Map<String, dynamic>.from(userData),
        token is String ? token : null,
      );
    }

    // Some backends return the user fields at the root of data.
    final bool looksLikeUser =
        dataNode.containsKey('_id') ||
        dataNode.containsKey('id') ||
        dataNode.containsKey('email');
    if (looksLikeUser) {
      return UserModel.fromJson(
        Map<String, dynamic>.from(dataNode),
        token is String ? token : null,
      );
    }

    // Some backends return token only without a user object.
    if (token is String) {
      return UserModel(id: '', email: '', token: token);
    }

    throw Exception('Response missing user object');
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return _parseUser(response.data);
      }
    } on DioException catch (e) {
      print("Login Error: ${e.response?.data['message'] ?? e.message}");
      rethrow;
    }
    return null;
  }

  Future<UserModel?> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseUser(response.data);
      }
    } on DioException catch (e) {
      print("Register Error: ${e.response?.data['message'] ?? e.message}");
      rethrow;
    }
    return null;
  }

  Future<UserModel?> getMe(String token) async {
    try {
      final response = await _dio.get(
        ApiConstants.me,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return _parseUser(response.data, tokenOverride: token);
      }
    } on DioException catch (e) {
      print("Me Error: ${e.response?.data['message'] ?? e.message}");
      rethrow;
    }
    return null;
  }

  Future<void> logout(String token) async {
    try {
      await _dio.post(
        ApiConstants.logout,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      print("Logout Error: ${e.response?.data['message'] ?? e.message}");
      rethrow;
    }
  }
}
