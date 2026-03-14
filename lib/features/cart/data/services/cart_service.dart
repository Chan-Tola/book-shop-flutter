import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/cart_model.dart';

class CartService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  CartModel _parseCart(dynamic root) {
    if (root is! Map) {
      throw Exception('Unexpected response: ${root.runtimeType}');
    }

    dynamic dataNode = root['data'] ?? root['cart'] ?? root;
    if (dataNode is Map && dataNode['cart'] is Map) {
      dataNode = dataNode['cart'];
    }

    if (dataNode is! Map) {
      throw Exception(
        'Unexpected cart response shape: ${dataNode.runtimeType}',
      );
    }

    return CartModel.fromJson(Map<String, dynamic>.from(dataNode));
  }

  Future<CartModel> getCart(String token) async {
    try {
      final response = await _dio.get(
        ApiConstants.cart,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return _parseCart(response.data);
      }
    } on DioException catch (e) {
      print("Get Cart Error: ${e.response?.data['message'] ?? e.message}");
      rethrow;
    }
    throw Exception('Failed to get cart');
  }

  Future<CartModel> addToCart(String token, String bookId, int quantity) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.cart}/add',
        data: {'bookId': bookId, 'quantity': quantity},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseCart(response.data);
      }
    } on DioException catch (e) {
      print("Add to Cart Error: ${e.response?.data['message'] ?? e.message}");
      rethrow;
    }
    throw Exception('Failed to add item to cart');
  }

  Future<CartModel> updateCartItem(
    String token,
    String bookId,
    int quantity,
  ) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.cart}/update',
        data: {'bookId': bookId, 'quantity': quantity},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return _parseCart(response.data);
      }
    } on DioException catch (e) {
      print("Update Cart Error: ${e.response?.data['message'] ?? e.message}");
      rethrow;
    }
    throw Exception('Failed to update cart item');
  }

  Future<CartModel> removeFromCart(String token, String bookId) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.cart}/remove/$bookId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return _parseCart(response.data);
      }
    } on DioException catch (e) {
      print(
        "Remove from Cart Error: ${e.response?.data['message'] ?? e.message}",
      );
      rethrow;
    }
    throw Exception('Failed to remove item from cart');
  }

  Future<CartModel> clearCart(String token) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.cart}/clear',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return _parseCart(response.data);
      }
    } on DioException catch (e) {
      print("Clear Cart Error: ${e.response?.data['message'] ?? e.message}");
      rethrow;
    }
    throw Exception('Failed to clear cart');
  }
}
